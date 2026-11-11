import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/partner_auth_provider.dart';

class PartnerLoginScreen extends StatefulWidget {
  const PartnerLoginScreen({super.key});
  @override
  State<PartnerLoginScreen> createState() => _PartnerLoginScreenState();
}

class _PartnerLoginScreenState extends State<PartnerLoginScreen> {
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
    await context.read<PartnerAuthProvider>().sendOtp(name: name, email: email);
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<PartnerAuthProvider>(
          builder: (context, auth, _) {
            if (auth.status == AuthStatus.loading && auth.status != AuthStatus.accessDenied) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6530)));
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6530),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delivery_dining, color: Colors.white, size: 40),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Welcome to VKart', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                        const SizedBox(height: 6),
                        const Text('Delivery Partner Login', textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name', hintText: 'Enter your name',
                            prefixIcon: Icon(Icons.person_outline_rounded), border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^\s+'))],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email', hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.mail_outline_rounded), border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: _validateEmail,
                          onFieldSubmitted: (_) => _continuePressed(),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: _continuePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6530),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                        if (auth.error != null && auth.status == AuthStatus.accessDenied) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3F0), borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFE53935)),
                            ),
                            child: Text(auth.error!, textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: Color(0xFFE53935))),
                          ),
                        ],
                        if (auth.error != null && auth.status != AuthStatus.accessDenied && auth.status != AuthStatus.unauthenticated) ...[
                          const SizedBox(height: 16),
                          Text(auth.error!, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Color(0xFFE53935))),
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


