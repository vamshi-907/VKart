import 'package:flutter/material.dart';
import 'package:vkart_admin/services/admin_auth_service.dart';
import 'package:vkart_admin/models/admin_model.dart';

/// The current authentication state of the app.
enum AuthStatus {
  /// App just started; checking for a persisted session.
  initial,

  /// A valid session was restored (or OTP verified) — show the dashboard.
  authenticated,

  /// No session and no pending login — show the login form.
  unauthenticated,

  /// A valid authorized email has submitted and is waiting for OTP entry.
  otpSent,

  /// The entered email is not authorized — show access denied.
  accessDenied,

  /// A transient operation is in progress (sending/verifying).
  loading,

  /// An unexpected error occurred.
  error,
}

/// State and business orchestration for the Email OTP authentication flow.
///
/// This provider keeps the UI thin: widgets only call [sendOtp], [verifyOtp],
/// [resendOtp], and [performLogout], then react to [status] / [error].
///
/// SECURITY: The provider never generates, stores, or prints the OTP. All OTP
/// logic lives in the Cloud Functions (server-side). After successful
/// verification the server issues a session token which the provider persists
/// via the service.
class AdminAuthProvider extends ChangeNotifier {
  final AdminAuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  String? _error;
  AdminModel? _currentAdmin;
  String? _pendingEmail;
  String? _pendingName;

  AdminAuthProvider({AdminAuthService? authService})
      : _authService = authService ?? AdminAuthService() {
    _kickOffRestore();
  }

  AuthStatus get status => _status;
  String? get error => _error;
  AdminModel? get currentAdmin => _currentAdmin;
  String? get pendingEmail => _pendingEmail;

  /// Attempts to restore a saved session on app launch.
  Future<void> _kickOffRestore() async {
    notifyListeners();
    try {
      final admin = await _authService.restoreSession();
      if (admin != null) {
        _currentAdmin = admin;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  /// Validates authorization and requests an OTP for [email] (for [name]).
  ///
  /// - Unauthorized emails are rejected immediately -> [AuthStatus.accessDenied]
  ///   and NO OTP is generated or sent (enforced server-side).
  /// - Authorized emails -> [AuthStatus.otpSent] and the OTP is emailed via SMTP.
  Future<void> sendOtp({
    required String name,
    required String email,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final normalized = email.trim().toLowerCase();
      final result = await _authService.sendOtp(name: name, email: normalized);

      switch (result) {
        case OtpSendStatus.success:
          _pendingEmail = normalized;
          _pendingName = name.trim();
          _status = AuthStatus.otpSent;
        case OtpSendStatus.unauthorized:
          _pendingEmail = null;
          _pendingName = null;
          _status = AuthStatus.accessDenied;
          _error = 'You are not authorized as a VKart Administrator.';
        case OtpSendStatus.locked:
          _status = AuthStatus.otpSent;
          _error = 'Please wait 30 seconds before requesting another code.';
        case OtpSendStatus.deliveryFailed:
          _status = AuthStatus.error;
          _error = 'Failed to deliver the verification code. Please try again.';
      }
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  /// Resends a fresh OTP for the currently pending email.
  Future<void> resendOtp() async {
    final email = _pendingEmail;
    final name = _pendingName ?? '';
    if (email == null) return;
    await sendOtp(name: name, email: email);
  }

  /// Verifies the submitted [otp]. On success, persists the server-issued
  /// session and transitions to [AuthStatus.authenticated].
  Future<void> verifyOtp(String otp) async {
    final email = _pendingEmail;
    if (email == null) {
      _status = AuthStatus.error;
      _error = 'No pending verification. Please log in again.';
      notifyListeners();
      return;
    }

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
          final admin = await _authService.restoreSession();
          _currentAdmin = admin;
          _pendingEmail = null;
          _pendingName = null;
          _status = AuthStatus.authenticated;
        case OtpVerifyStatus.invalid:
          _status = AuthStatus.otpSent;
          _error = 'Invalid OTP. Please check the code and try again.';
        case OtpVerifyStatus.expired:
          _status = AuthStatus.otpSent;
          _error = 'OTP expired. Please request a new code.';
        case OtpVerifyStatus.locked:
          _status = AuthStatus.otpSent;
          _error = 'Too many failed attempts. A new secure code has been sent to your email.';
        case OtpVerifyStatus.notRequested:
          _status = AuthStatus.unauthenticated;
          _error = 'No OTP was requested for this email.';
      }
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  /// Seconds remaining for the current OTP (for the countdown UI).
  Future<int> otpSecondsRemaining() {
    final email = _pendingEmail;
    if (email == null) return Future.value(0);
    return _authService.otpSecondsRemaining(email);
  }

  Future<int> lockoutRemaining() {
    final email = _pendingEmail;
    if (email == null) return Future.value(0);
    return _authService.lockoutRemaining(email);
  }

  Future<int> resendSecondsRemaining() {
    return _authService.resendSecondsRemaining();
  }

  /// Clears the session and returns the app to the login screen.
  /// Uses [pushNamedAndRemoveUntil] so the back button can never reopen the
  /// dashboard.
  Future<void> performLogout(BuildContext context) async {
    await _authService.logout();
    _currentAdmin = null;
    _pendingEmail = null;
    _pendingName = null;
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
