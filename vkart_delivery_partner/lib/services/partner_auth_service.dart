import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/delivery_partner_auth_config.dart';
import 'smtp_otp_service.dart';

class PartnerAuthService {
  /// Top-level Firestore collection holding persistent delivery partner
  /// accounts. Document id = normalized email (stable, deterministic — the
  /// same document on every login, no random ids).
  static const String partnersCollection = 'partners';

  // Persistent session keys (survive app restarts via SharedPreferences).
  static const _kSessionToken = 'partner_session_token';
  static const _kSessionId = 'partner_id';
  static const _kSessionName = 'partner_name';
  static const _kSessionEmail = 'partner_email';
  static const _kSessionRole = 'partner_role';

  // Legacy session keys from the previous implementation; kept as a read
  // fallback so an already-saved session still restores after the upgrade.
  static const _kLegacySessionEmail = 'partner_session_email';
  static const _kLegacySessionName = 'partner_session_name';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Single, long-lived OTP service instance. The generated OTP plus its
  /// expiry/cooldown state live on this instance, so every auth call MUST
  /// reuse the same instance. Creating a new instance per call would discard
  /// the OTP before it can ever be verified (the bug this replaces).
  final SmtpOtpService _otpService;

  PartnerAuthService({SmtpOtpService? otpService})
      : _otpService = otpService ?? SmtpOtpService();

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  bool isAuthorizedEmail(String email) =>
      DeliveryPartnerAuthConfig.isAuthorizedEmail(email);

  // -------------------------------------------------------------------
  // Firestore partner repository (`partners` collection)
  // -------------------------------------------------------------------

  DocumentReference<Map<String, dynamic>> _partnerRef(String email) =>
      _firestore.collection(partnersCollection).doc(normalizeEmail(email));

  /// Reads the persistent partner document by email (normalized).
  Future<Map<String, dynamic>?> getPartnerByEmail(String email) async {
    final doc = await _partnerRef(email).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Reads the persistent partner document by its stable id (document id).
  Future<Map<String, dynamic>?> getPartner(String partnerId) =>
      getPartnerByEmail(partnerId);

  /// Authorization gate used BEFORE the OTP is sent (and on session restore).
  ///
  /// Only the single configured partner email may pass. The Firestore
  /// `partners` document must additionally confirm `active == true` and
  /// `role == 'delivery_partner'`. A missing document is seeded on the very
  /// first login (stable id = normalized email) so an empty Firestore never
  /// locks the authorized partner out; arbitrary emails are rejected before
  /// any Firestore write happens.
  Future<bool> isAuthorizedPartner(String email) async {
    final normalized = normalizeEmail(email);
    if (!isAuthorizedEmail(normalized)) return false;

    final doc = await _partnerRef(normalized).get();
    if (doc.exists) {
      return _isAuthorizedPartnerData(doc.data() ?? {});
    }

    try {
      await savePartner(email: normalized);
    } catch (_) {
      // Firestore write unavailable: the config-level email check above
      // already confirmed this is the one authorized partner, still allow OTP.
    }
    return true;
  }

  bool _isAuthorizedPartnerData(Map<String, dynamic> data) {
    final active = data['active'] ?? data['isActive'] ?? false;
    if (active != true) return false;

    final storedEmail = (data['email'] ?? '').toString().trim().toLowerCase();
    if (storedEmail.isNotEmpty &&
        !DeliveryPartnerAuthConfig.isAuthorizedEmail(storedEmail)) {
      return false;
    }

    final role = (data['role'] ?? '').toString().trim().toLowerCase();
    if (role.isNotEmpty && role != 'delivery_partner') return false;
    return true;
  }

  /// Creates the partner document if it does not exist (using the stable
  /// partner name) and otherwise updates only transient/schema fields.
  /// Existing fields such as `name` are never overwritten by login input.
  Future<void> savePartner({
    required String email,
    String? name,
    String? role,
    bool? active,
  }) async {
    final normalized = normalizeEmail(email);
    final docRef = _partnerRef(normalized);
    final doc = await docRef.get();
    final now = FieldValue.serverTimestamp();

    if (!doc.exists) {
      await docRef.set({
        'name': (name ?? DeliveryPartnerAuthConfig.partnerName).trim(),
        'email': normalized,
        'active': active ?? true,
        'role': role ?? 'delivery_partner',
        'createdAt': now,
        'lastLoginAt': now,
      });
      return;
    }

    final data = doc.data() ?? {};
    final updates = <String, dynamic>{'lastLoginAt': now};
    if ((data['role'] ?? '').toString().trim().isEmpty) {
      updates['role'] = role ?? 'delivery_partner';
    }
    if (data['active'] == null) {
      updates['active'] = active ?? true;
    }
    await docRef.update(updates);
  }

  Future<dynamic> sendOtp({required String name, required String email}) async {
    // Persistent authorization FIRST: only send an OTP when the Firestore
    // `partners` document authorizes this email. Unauthorized emails never
    // reach the SMTP service.
    if (!await isAuthorizedPartner(email)) {
      return OtpSendStatus.unauthorized;
    }
    return _otpService.sendOtp(name: name, email: email);
  }

  Future<dynamic> verifyOtp({
    required String email,
    required String name,
    required String otp,
  }) async {
    return _otpService.verifyOtp(email: email, name: name, otp: otp);
  }

  Future<dynamic> resendOtp({required String name, required String email}) async {
    return _otpService.resendOtp(name: name, email: email);
  }

  Future<int> otpSecondsRemaining(String email) async {
    return _otpService.otpSecondsRemaining(email);
  }

  Future<int> resendSecondsRemaining() async {
    return _otpService.resendSecondsRemaining();
  }

  Future<Map<String, String>?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kSessionToken);
    final email = prefs.getString(_kSessionEmail) ??
        prefs.getString(_kLegacySessionEmail);
    final name = prefs.getString(_kSessionName) ??
        prefs.getString(_kLegacySessionName) ??
        '';
    final id = prefs.getString(_kSessionId) ?? '';
    final role = prefs.getString(_kSessionRole) ?? 'delivery_partner';

    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return null;
    }

    final normalizedEmail = normalizeEmail(email);
    if (!isAuthorizedEmail(normalizedEmail)) {
      await clearSession();
      return null;
    }

    try {
      final doc = await _partnerRef(normalizedEmail).get();
      if (!doc.exists || !_isAuthorizedPartnerData(doc.data() ?? {})) {
        await clearSession();
        return null;
      }
      // The persistent Firestore document is the source of truth for the
      // partner name/role displayed on the dashboard.
      final data = doc.data() ?? {};
      final docName = (data['name'] ?? '').toString().trim();
      final docRole = (data['role'] ?? '').toString().trim();
      return {
        'email': normalizedEmail,
        'name': docName.isNotEmpty ? docName : name,
        'token': token,
        'id': id.isNotEmpty ? id : normalizedEmail,
        'role': docRole.isNotEmpty ? docRole : role,
      };
    } catch (_) {
      // Firestore temporarily unreachable: keep the stored session instead of
      // logging the partner out. Authorization is re-validated on the next
      // successful restore.
      return {
        'email': normalizedEmail,
        'name': name,
        'token': token,
        'id': id.isNotEmpty ? id : normalizedEmail,
        'role': role,
      };
    }
  }

  Future<void> saveSession({
    required String email,
    required String name,
    String? partnerId,
    String? role,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSessionToken,
      'partner_session_${normalizedEmail}_${DateTime.now().millisecondsSinceEpoch}',
    );
    await prefs.setString(_kSessionId, partnerId ?? normalizedEmail);
    await prefs.setString(_kSessionEmail, normalizedEmail);
    await prefs.setString(_kSessionName, name.trim());
    await prefs.setString(_kSessionRole, role ?? 'delivery_partner');
    // Drop legacy session keys so the new schema is authoritative.
    await prefs.remove(_kLegacySessionEmail);
    await prefs.remove(_kLegacySessionName);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionToken);
    await prefs.remove(_kSessionId);
    await prefs.remove(_kSessionName);
    await prefs.remove(_kSessionEmail);
    await prefs.remove(_kSessionRole);
    await prefs.remove(_kLegacySessionEmail);
    await prefs.remove(_kLegacySessionName);
  }
}
