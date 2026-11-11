import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/admin_auth_provider.dart';
import '../../widgets/vkart_button.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'An Error Occurred',
              style: TextStyle(fontSize: 24, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              Provider.of<AdminAuthProvider>(context).error ??
                  'Unknown error',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            VKartButton(
              text: 'Try Again',
              onPressed: () {
                Provider.of<AdminAuthProvider>(context, listen: false)
                    .performLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
