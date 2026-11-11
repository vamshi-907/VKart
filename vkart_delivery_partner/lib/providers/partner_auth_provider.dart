import 'package:flutter/material.dart';
import '../config/delivery_partner_auth_config.dart';
import '../services/partner_auth_service.dart';
import '../services/smtp_otp_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  otpSent,
  accessDenied,
  loading,
  error,
}

class PartnerAuthProvider extends ChangeNotifier {
  final PartnerAuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  String? _error;
  String? _pendingEmail;
  String? _pendingName;
  String? _partnerName;
  String? _partnerEmail;
  String? _partnerId;
  String? _partnerRole;

  PartnerAuthProvider({PartnerAuthService? authService})
      : _authService = authService ?? PartnerAuthService() {
    _kickOffRestore();
  }

  AuthStatus get status => _status;
  String? get error => _error;
  String? get pendingEmail => _pendingEmail;
  String? get pendingName => _pendingName;
  String? get partnerName => _partnerName;
  String? get partnerEmail => _partnerEmail;
  String? get partnerId => _partnerId;
  String? get partnerRole => _partnerRole;

  Future<void> _kickOffRestore() async {
    notifyListeners();
    try {
      final session = await _authService.restoreSession();
      if (session != null) {
        _pendingEmail = session['email'];
        _pendingName = session['name'];
        _partnerEmail = session['email'];
        _partnerName = session['name'];
        _partnerId = session['id'];
        _partnerRole = session['role'];
        _status = AuthStatus.authenticated;
      } else {
        _pendingEmail = null;
        _pendingName = null;
        _partnerEmail = null;
        _partnerName = null;
        _partnerId = null;
        _partnerRole = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> sendOtp({
    required String name,
    required String email,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.sendOtp(name: name, email: email);
      switch (result) {
        case OtpSendStatus.success:
          _pendingEmail = email.trim().toLowerCase();
          _pendingName = name.trim();
          _status = AuthStatus.otpSent;
          break;
        case OtpSendStatus.unauthorized:
          _pendingEmail = null;
          _pendingName = null;
          _status = AuthStatus.accessDenied;
          _error = 'This email is not registered as a VKart Delivery Partner.';
          break;
        case OtpSendStatus.locked:
          _status = AuthStatus.otpSent;
          _error = 'Please wait 30 seconds before requesting another code.';
          break;
        case OtpSendStatus.deliveryFailed:
          _status = AuthStatus.error;
          _error = 'Failed to deliver the verification code. Please try again.';
          break;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> resendOtp() async {
    final email = _pendingEmail;
    final name = _pendingName ?? '';
    if (email == null) return;
    await sendOtp(name: name, email: email);
  }

  Future<void> verifyOtp(String otp) async {
    debugPrint('[PARTNER AUTH] OTP verification started');
    final email = _pendingEmail;
    if (email == null) {
      _status = AuthStatus.error;
      _error = 'No pending verification. Please log in again.';
      notifyListeners();
      return;
    }

    debugPrint('[PARTNER AUTH] Current state BEFORE verify: ${_status.name}');
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.verifyOtp(
        email: email,
        name: _pendingName ?? '',
        otp: otp,
      );

      switch (result) {
        case OtpVerifyStatus.success:
          debugPrint('[PARTNER AUTH] OTP verification successful');
          final normalizedEmail = email.trim().toLowerCase();

          // Persist the partner document (stable id = normalized email) and
          // read the authoritative name/role back from Firestore, so the
          // saved session never stores the throwaway login-screen name.
          String persistedName;
          String persistedRole;
          try {
            await _authService.savePartner(email: normalizedEmail);
            final partnerData =
                await _authService.getPartnerByEmail(normalizedEmail);
            persistedName =
                (partnerData?['name'] ?? '').toString().trim().isNotEmpty
                    ? (partnerData?['name'] ?? '').toString().trim()
                    : DeliveryPartnerAuthConfig.partnerName;
            persistedRole =
                (partnerData?['role'] ?? '').toString().trim().isNotEmpty
                    ? (partnerData?['role'] ?? '').toString().trim()
                    : 'delivery_partner';
          } catch (e) {
            // Firestore flake after a verified OTP must not block login; the
            // partners document is synced on the next restore.
            debugPrint('[PARTNER AUTH] partners doc sync failed: $e');
            persistedName = DeliveryPartnerAuthConfig.partnerName;
            persistedRole = 'delivery_partner';
          }

          debugPrint('[PARTNER AUTH] Saving partner session');
          var sessionSaved = false;
          try {
            await _authService.saveSession(
              email: normalizedEmail,
              name: persistedName,
              partnerId: normalizedEmail,
              role: persistedRole,
            );
            sessionSaved = true;
          } catch (e) {
            debugPrint('[PARTNER AUTH] Session save failed: $e');
          }
          debugPrint('[PARTNER AUTH] Partner session saved = $sessionSaved');

          _partnerEmail = normalizedEmail;
          _partnerName = persistedName;
          _partnerId = normalizedEmail;
          _partnerRole = persistedRole;
          _pendingEmail = null;
          _pendingName = null;
          _status = AuthStatus.authenticated;
          debugPrint('[PARTNER AUTH] Authentication state = authenticated');
          break;
        case OtpVerifyStatus.invalid:
          _status = AuthStatus.otpSent;
          _error = 'Invalid OTP. Please try again.';
          break;
        case OtpVerifyStatus.expired:
          _status = AuthStatus.otpSent;
          _error = 'OTP expired. Please request a new OTP.';
          break;
        case OtpVerifyStatus.locked:
          _status = AuthStatus.otpSent;
          _error = 'Too many failed attempts. A new secure code has been sent to your email.';
          break;
        case OtpVerifyStatus.notRequested:
          // Never fall back to the login screen here; keep the partner on the
          // OTP screen with a clear error message.
          _status = AuthStatus.otpSent;
          _error =
              'No OTP was requested for this email. Please request a new OTP.';
          break;
      }
      debugPrint('[PARTNER AUTH] Current state AFTER verify: ${_status.name}');
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('[PARTNER AUTH] Verification failed: ${_status.name}');
    }
    notifyListeners();
  }

  Future<String?> getPartnerEmail() async {
    if (_partnerEmail != null && _partnerEmail!.isNotEmpty) {
      return _partnerEmail;
    }
    final session = await _authService.restoreSession();
    return session?['email'];
  }

  Future<int> otpSecondsRemaining() {
    final email = _pendingEmail;
    if (email == null) return Future.value(0);
    return _authService.otpSecondsRemaining(email);
  }

  Future<int> resendSecondsRemaining() {
    return _authService.resendSecondsRemaining();
  }

  Future<void> performLogout(BuildContext context) async {
    await _authService.clearSession();
    _pendingEmail = null;
    _pendingName = null;
    _partnerName = null;
    _partnerEmail = null;
    _partnerId = null;
    _partnerRole = null;
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
