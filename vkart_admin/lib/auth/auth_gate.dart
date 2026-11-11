import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/admin_auth_provider.dart';
import '../screens/main_shell.dart';
import '../screens/login/admin_login_screen.dart';
import '../screens/login/admin_otp_screen.dart';
import '../screens/login/access_denied_screen.dart';
import '../screens/login/error_screen.dart';
import '../screens/splash/admin_splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, authProvider, _) {
        final status = authProvider.status;

        switch (status) {
          case AuthStatus.authenticated:
            return const MainShell();
          case AuthStatus.unauthenticated:
            return const AdminLoginScreen();
          case AuthStatus.otpSent:
            return const AdminOtpScreen();
          case AuthStatus.accessDenied:
            return const AccessDeniedScreen();
          case AuthStatus.error:
            return const ErrorScreen();
          case AuthStatus.loading:
          case AuthStatus.initial:
            return const AdminSplashScreen();
        }
      },
    );
  }
}
