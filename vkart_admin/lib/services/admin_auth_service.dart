import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../config/admin_auth_config.dart';
import '../config/smtp_config.dart';
import '../models/admin_model.dart';

enum OtpSendStatus { success, unauthorized, locked, deliveryFailed }
enum OtpVerifyStatus { success, invalid, expired, locked, notRequested }

class AdminAuthService {
  static const _kSessionToken = 'admin_session_token';
  static const _kSessionEmail = 'admin_session_email';
  static const _kSessionName = 'admin_session_name';

  String? _generatedOtp;
  DateTime? _otpCreatedAt;
  int _failedAttempts = 0;
  DateTime? _lastSendTime;

  String? _pendingEmail;

  AdminAuthService();

  bool isAuthorizedEmail(String email) => AdminAuthConfig.isAuthorizedEmail(email);
  String _generateSecureOtp() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10).toString()).join();
  }

  Future<OtpSendStatus> sendOtp({required String name, required String email}) async {
    final normalized = email.trim().toLowerCase();
    if (!isAuthorizedEmail(normalized)) return OtpSendStatus.unauthorized;

    final now = DateTime.now();
    if (_lastSendTime != null && now.difference(_lastSendTime!) < AdminAuthConfig.resendCooldown) {
      return OtpSendStatus.locked;
    }

    final otp = _generateSecureOtp();
    try {
      // Configure Gmail SMTP directly for TLS on port 587.
      final server = SmtpServer(
        SmtpConfig.host,
        port: SmtpConfig.port,
        username: SmtpConfig.username,
        password: SmtpConfig.password,
      );

      final message = Message()
        ..from = const Address(SmtpConfig.senderEmail, SmtpConfig.senderName)
        ..recipients.add(normalized)
        ..subject = 'VKart Admin Login OTP'
        ..text = 'Hello $name\n\nYour VKart Admin Login OTP is\n\n$otp\n\nThis OTP is valid for 5 minutes.\nPlease do not share this OTP.\n\nVKart Team';

      await send(message, server).timeout(const Duration(seconds: 15));

      _generatedOtp = otp;
      _otpCreatedAt = now;
      _failedAttempts = 0;
      _lastSendTime = now;
      _pendingEmail = normalized;
      return OtpSendStatus.success;
    } on TimeoutException {
      throw TimeoutException('The connection timed out. Please check your internet connection.');
    } on SocketException {
      throw const SocketException('Internet is unavailable. Please check your network.');
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('authentication') || errorStr.contains('535') || errorStr.contains('Authentication') || errorStr.contains('535')) {
        throw Exception('SMTP Authentication Failed. Verify your Gmail App Password.');
      }
      throw Exception('Failed to send verification code: $e');
    }
  }

  Future<OtpSendStatus> resendOtp({required String name, required String email}) {
    _generatedOtp = null;
    _otpCreatedAt = null;
    return sendOtp(name: name, email: email);
  }
  Future<OtpVerifyStatus> verifyOtp({required String email, required String name, required String otp}) async {
    final normalized = email.trim().toLowerCase();
    if (_generatedOtp == null || _pendingEmail != normalized) return OtpVerifyStatus.notRequested;

    final now = DateTime.now();
    if (_otpCreatedAt == null || now.difference(_otpCreatedAt!) > AdminAuthConfig.otpExpiry) {
      _generatedOtp = null;
      return OtpVerifyStatus.expired;
    }

    if (otp.trim() == _generatedOtp) {
      _generatedOtp = null;
      _otpCreatedAt = null;
      _failedAttempts = 0;
      await _saveSession(
        email: normalized,
        name: name.trim(),
        token: 'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}',
      );
      return OtpVerifyStatus.success;
    }

    _failedAttempts++;
    if (_failedAttempts >= AdminAuthConfig.maxAttempts) {
      _generatedOtp = null;
      _otpCreatedAt = null;
      unawaited(sendOtp(name: name, email: normalized).catchError((_) => OtpSendStatus.deliveryFailed));
      return OtpVerifyStatus.locked;
    }
    return OtpVerifyStatus.invalid;
  }

  Future<int> otpSecondsRemaining(String email) async {
    if (_otpCreatedAt == null || _pendingEmail != email.trim().toLowerCase()) return 0;
    final diff = DateTime.now().difference(_otpCreatedAt!).inSeconds;
    return (AdminAuthConfig.otpExpiry.inSeconds - diff).clamp(0, AdminAuthConfig.otpExpiry.inSeconds);
  }

  Future<int> resendSecondsRemaining() async {
    if (_lastSendTime == null) return 0;
    final diff = DateTime.now().difference(_lastSendTime!).inSeconds;
    return (AdminAuthConfig.resendCooldown.inSeconds - diff).clamp(0, AdminAuthConfig.resendCooldown.inSeconds);
  }

  Future<int> lockoutRemaining(String email) async => 0;

  Future<AdminModel?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kSessionToken);
    final email = prefs.getString(_kSessionEmail);
    final name = prefs.getString(_kSessionName);

    if (token == null || email == null) return null;
    if (!isAuthorizedEmail(email)) {
      await clearSession();
      return null;
    }

    return AdminModel(
      uid: email,
      email: email,
      name: name ?? '',
      role: 'super_admin',
      active: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionToken);
    await prefs.remove(_kSessionEmail);
    await prefs.remove(_kSessionName);
  }

  Future<void> logout() async {
    await clearSession();
    _generatedOtp = null;
    _otpCreatedAt = null;
    _failedAttempts = 0;
    _lastSendTime = null;
    _pendingEmail = null;
  }

  Future<void> _saveSession({required String email, required String name, required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionToken, token);
    await prefs.setString(_kSessionEmail, email);
    await prefs.setString(_kSessionName, name);
  }
}