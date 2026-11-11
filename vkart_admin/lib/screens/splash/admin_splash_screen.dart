import 'package:flutter/material.dart';
import '../../materials/vkart_colors.dart';

/// Splash screen shown only while the app is restoring a saved session.
/// Navigation to the login or dashboard is handled by the [AuthGate].
class AdminSplashScreen extends StatelessWidget {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VKartColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: VKartColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.storefront,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'VKart Admin',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: VKartColors.primaryText,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: VKartColors.primary),
          ],
        ),
      ),
    );
  }
}
