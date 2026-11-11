import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/partner_auth_provider.dart';
import '../screens/auth/partner_login_screen.dart';
import '../screens/auth/partner_otp_screen.dart';
import '../screens/auth/partner_access_denied_screen.dart';
import '../screens/dashboard/partner_dashboard_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartnerAuthProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.status) {
          case AuthStatus.authenticated:
            return const PartnerDashboardScreen();
          case AuthStatus.unauthenticated:
            return const PartnerLoginScreen();
          case AuthStatus.otpSent:
            return const PartnerOtpScreen();
          case AuthStatus.accessDenied:
            return const AccessDeniedScreen();
          case AuthStatus.error:
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53935)),
                    const SizedBox(height: 16),
                    Text(authProvider.error ?? 'Something went wrong',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1F2937))),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => authProvider.performLogout(context),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            );
          case AuthStatus.initial:
          case AuthStatus.loading:
            return Scaffold(
              backgroundColor: Color(0xFFF8F9FA),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration
                      (color: Color(0xFFFF6530), 
                      borderRadius: BorderRadius.circular(20)),
                      child: Icon(Icons.delivery_dining, color: Colors.white, size: 40),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: Color(0xFFFF6530)),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
