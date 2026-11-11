import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/admin_auth_provider.dart';
import '../../materials/vkart_colors.dart';
import '../../widgets/vkart_button.dart';
import '../../widgets/vkart_text_field.dart';

/// Login screen: Full Name + Official Email + Continue.
///
/// The email is validated for format, then passed to [AdminAuthProvider.sendOtp]
/// which checks authorization. Unauthorized emails are rejected (no OTP is
/// generated or sent) and the app transitions to the access-denied screen.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _continuePressed() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    await context.read<AdminAuthProvider>().sendOtp(name: name, email: email);
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VKartColors.background,
      body: SafeArea(
        child: Consumer<AdminAuthProvider>(
          builder: (context, auth, _) {
            if (auth.status == AuthStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: VKartColors.primary),
              );
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Branding
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: VKartColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.storefront,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'VKart Admin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: VKartColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enter your details to receive a secure verification code.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: VKartColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Full Name
                        VKartTextField(
                          label: 'Full Name',
                          hint: 'e.g. Vamsi',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                              RegExp(r'^\s+'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Official Email Address
                        VKartTextField(
                          label: 'Official Email Address',
                          hint: 'you@example.com',
                          controller: _emailController,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.email],
                          validator: _validateEmail,
                          onSubmitted: (_) => _continuePressed(),
                        ),
                        const SizedBox(height: 28),

                        // Continue Button
                        VKartButton(
                          text: 'Continue',
                          prefixIcon: Icons.arrow_forward_rounded,
                          height: 52,
                          onPressed: _continuePressed,
                        ),

                        if (auth.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            auth.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: VKartColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
