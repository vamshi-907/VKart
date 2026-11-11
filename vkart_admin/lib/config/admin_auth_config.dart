/// Centralized configuration for the VKart Admin Email OTP authentication.
///
/// FUTURE-READY: To add another authorized admin email, add it to
/// [authorizedAdminEmails] below. No other code needs to change — the login
/// flow, OTP generation, and authorization checks all read from this single
/// source of truth.
library;

class AdminAuthConfig {
  AdminAuthConfig._();

  // ---------------------------------------------------------------------
  // Authorized Super Admin emails
  // ---------------------------------------------------------------------
  /// The only email addresses allowed to log into VKart Admin.
  ///
  /// Lowercased at the source so the case-insensitive comparison in
  /// [isAuthorizedEmail] is always exact.
  static final Set<String> authorizedAdminEmails = {
    'venkatasaivamshi23@gmail.com',
    'vsv8639243604@gmail.com',
  };

  /// Returns true only when [email] matches one of the authorized admin
  /// emails exactly (after trimming whitespace and lowercasing — so
  /// "VSV8639243604@gmail.com" works but "vsv8639243604@example.com" does
  /// not).
  static bool isAuthorizedEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return authorizedAdminEmails.contains(normalized);
  }

  // ---------------------------------------------------------------------
  // OTP security parameters
  // ---------------------------------------------------------------------
  /// Number of digits in the generated OTP.
  static const int otpLength = 6;

  /// OTP validity window, in minutes.
  static const Duration otpExpiry = Duration(minutes: 5);

  /// Maximum number of failed verification attempts before lockout.
  static const int maxAttempts = 5;

  /// Lockout duration after too many failed attempts.
  static const Duration lockoutDuration = Duration(minutes: 10);

  /// Resend cooldown applied on the OTP screen.
  static const Duration resendCooldown = Duration(seconds: 30);


}
