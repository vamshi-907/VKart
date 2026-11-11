import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/partner_auth_provider.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: const Icon(Icons.block_rounded, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 24),
                const Text('Access Denied', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                const SizedBox(height: 12),
                const Text('This email is not registered as a VKart Delivery Partner.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF1F2937))),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.read<PartnerAuthProvider>().performLogout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6530),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Return to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
