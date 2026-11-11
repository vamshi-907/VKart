import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/admin_auth_provider.dart';
import '../../materials/vkart_colors.dart';
import '../../widgets/vkart_button.dart';

/// Shown when the submitted email is not one of the two authorized super
/// admin emails. No OTP is generated or sent for unauthorized emails.
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VKartColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: VKartColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Access Denied',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: VKartColors.error,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You are not an authorized VKart Administrator.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: VKartColors.primaryText,
                  ),
                ),
                const SizedBox(height: 32),
                VKartButton(
                  text: 'Return to Login',
                  width: 220,
                  height: 48,
                  onPressed: () {
                    context.read<AdminAuthProvider>().performLogout(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
