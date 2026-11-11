import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../config/delivery_partner_auth_config.dart';
import '../config/smtp_config.dart';

enum OtpSendStatus { success, unauthorized, locked, deliveryFailed }
enum OtpVerifyStatus { success, invalid, expired, locked, notRequested }

class SmtpOtpService {
  String? _generatedOtp;
  DateTime? _otpCreatedAt;
  int _failedAttempts = 0;
  DateTime? _lastSendTime;
  String? _pendingEmail;

  bool isAuthorizedEmail(String email) =>
      DeliveryPartnerAuthConfig.isAuthorizedEmail(email);

  String _generateSecureOtp() {
    final random = Random.secure();
    return List.generate(
      DeliveryPartnerAuthConfig.otpLength,
      (_) => random.nextInt(10).toString(),
    ).join();
  }

  Future<OtpSendStatus> sendOtp({
    required String name,
    required String email,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!isAuthorizedEmail(normalized)) return OtpSendStatus.unauthorized;

    final now = DateTime.now();
    if (_lastSendTime != null &&
        now.difference(_lastSendTime!) <
            DeliveryPartnerAuthConfig.resendCooldown) {
      return OtpSendStatus.locked;
    }

    final otp = _generateSecureOtp();

    try {
      final server = SmtpServer(
        SmtpConfig.host,
        port: SmtpConfig.port,
        username: SmtpConfig.username,
        password: SmtpConfig.password,
      );

      final message = Message()
        ..from = const Address(
          SmtpConfig.senderEmail,
          SmtpConfig.senderName,
        )
        ..recipients.add(normalized)
        ..subject = 'VKart Delivery Partner Login OTP'
        ..text = 'Hello $name,\n\nYour VKart Delivery Partner Login OTP is\n\n$otp\n\nThis OTP is valid for 5 minutes.\nPlease do not share this OTP.\n\nVKart Team';

      await send(message, server).timeout(const Duration(seconds: 15));

      // Do NOT log the actual OTP
      _generatedOtp = otp;
      _otpCreatedAt = now;
      _failedAttempts = 0;
      _lastSendTime = now;
      _pendingEmail = normalized;
      return OtpSendStatus.success;
    } on TimeoutException {
      throw TimeoutException(
        'The connection timed out. Please check your internet connection.',
      );
    } on SocketException {
      throw const SocketException(
        'Internet is unavailable. Please check your network.',
      );
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('authentication') ||
          errorStr.contains('535') ||
          errorStr.contains('Authentication')) {
        throw Exception('SMTP Authentication Failed. Verify your Gmail App Password.');
      }
      throw Exception('Failed to send verification code: $e');
    }
  }

  Future<OtpSendStatus> resendOtp({
    required String name,
    required String email,
  }) {
    _generatedOtp = null;
    _otpCreatedAt = null;
    return sendOtp(name: name, email: email);
  }

  Future<OtpVerifyStatus> verifyOtp({
    required String email,
    required String name,
    required String otp,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (_generatedOtp == null || _pendingEmail != normalized) {
      return OtpVerifyStatus.notRequested;
    }

    final now = DateTime.now();
    if (_otpCreatedAt == null ||
        now.difference(_otpCreatedAt!) >
            DeliveryPartnerAuthConfig.otpExpiry) {
      _generatedOtp = null;
      return OtpVerifyStatus.expired;
    }

    if (otp.trim() == _generatedOtp) {
      _generatedOtp = null;
      _otpCreatedAt = null;
      _failedAttempts = 0;
      return OtpVerifyStatus.success;
    }

    _failedAttempts++;
    if (_failedAttempts >= DeliveryPartnerAuthConfig.maxAttempts) {
      _generatedOtp = null;
      _otpCreatedAt = null;
      unawaited(
        sendOtp(name: name, email: normalized).catchError(
              (_) => OtpSendStatus.deliveryFailed,
            ),
      );
      return OtpVerifyStatus.locked;
    }
    return OtpVerifyStatus.invalid;
  }

  Future<int> otpSecondsRemaining(String email) async {
    if (_otpCreatedAt == null ||
        _pendingEmail != email.trim().toLowerCase()) {
      return 0;
    }
    final diff = DateTime.now().difference(_otpCreatedAt!).inSeconds;
    return (DeliveryPartnerAuthConfig.otpExpiry.inSeconds - diff)
        .clamp(0, DeliveryPartnerAuthConfig.otpExpiry.inSeconds);
  }

  Future<int> resendSecondsRemaining() async {
    if (_lastSendTime == null) return 0;
    final diff = DateTime.now().difference(_lastSendTime!).inSeconds;
    return (DeliveryPartnerAuthConfig.resendCooldown.inSeconds - diff)
        .clamp(0, DeliveryPartnerAuthConfig.resendCooldown.inSeconds);
  }

  Future<int> lockoutRemaining(String email) async => 0;
}
