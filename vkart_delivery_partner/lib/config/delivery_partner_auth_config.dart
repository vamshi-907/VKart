/// Centralized configuration for the VKart Delivery Partner Email OTP authentication.
library;

class DeliveryPartnerAuthConfig {
  DeliveryPartnerAuthConfig._();

  // ---------------------------------------------------------------------
  // Authorized Delivery Partner email
  // ---------------------------------------------------------------------
  static const String allowedEmail = 'maleyrameshbabu113@gmail.com';

  /// Stable, persistent partner name stored in the Firestore `partners`
  /// document for [allowedEmail]. The dashboard reads the name from the
  /// persistent session / Firestore document, never from login input.
  static const String partnerName = 'Ramesh Babu';

  /// Returns true only when [email] matches the authorized delivery partner
  /// email exactly (after trimming whitespace and lowercasing).
  static bool isAuthorizedEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return normalized == allowedEmail;
  }

  // ---------------------------------------------------------------------
  // OTP security parameters
  // ---------------------------------------------------------------------
  static const int otpLength = 6;
  static const Duration otpExpiry = Duration(minutes: 5);
  static const int maxAttempts = 5;
  static const Duration resendCooldown = Duration(seconds: 30);
}
