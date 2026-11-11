/// Centralized SMTP configuration for VKart Admin Gmail delivery.
class SmtpConfig {
  SmtpConfig._();

  static const String host = 'smtp.gmail.com';
  static const int port = 587;
  static const bool tls = true;

  static const String username = '2200030907cseh@gmail.com';
  /// Replace with the actual Gmail App Password for 2200030907cseh@gmail.com.
  static const String password = 'afaq mqcv fuuq uhhs';
  static const String senderName = 'VKart Team';
  static const String senderEmail = '2200030907cseh@gmail.com';
}