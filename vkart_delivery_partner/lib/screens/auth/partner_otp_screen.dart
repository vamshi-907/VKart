import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/partner_auth_provider.dart';
import '../../config/delivery_partner_auth_config.dart';



class PartnerOtpScreen extends StatefulWidget {
  const PartnerOtpScreen({super.key});
  @override
  State<PartnerOtpScreen> createState() => _PartnerOtpScreenState();
}

class _PartnerOtpScreenState extends State<PartnerOtpScreen> {
  static const int _boxCount = DeliveryPartnerAuthConfig.otpLength;
  final List<TextEditingController> _controllers = List.generate(
    _boxCount, (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _boxCount, (_) => FocusNode(),
  );
  int _expiryCountdown = 0;
  int _resendCountdown = 0;
  Future<void> _loadRemaining() async {
    final auth = context.read<PartnerAuthProvider>();
    final expiryRemaining = await auth.otpSecondsRemaining();
    final resendRemaining = await auth.resendSecondsRemaining();
    if (!mounted) return;
    setState(() {
      _expiryCountdown = expiryRemaining;
      _resendCountdown = resendRemaining;
    });
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _onBoxChanged(int index, String value) {
    if (value.length == 1 && index < _boxCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otpValue.length == _boxCount) _verify();
  }

  Future<void> _verify() async {
  FocusScope.of(context).unfocus();

  final auth = context.read<PartnerAuthProvider>();

  try {
    await auth.verifyOtp(_otpValue);

    // No manual navigation here: on success the provider flips to
    // `authenticated` and AuthGate rebuilds the home to the dashboard.
    // Manual push/pop here would race AuthGate and show the wrong screen.
    if (!mounted) return;
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }
}

  Future<void> _resend() async {
  await context.read<PartnerAuthProvider>().resendOtp();

  for (final c in _controllers) {
    c.clear();
  }

  if (_focusNodes.isNotEmpty) {
    _focusNodes.first.requestFocus();
  }

  await _loadRemaining();
}

@override
Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFFF8F9FA), body: SafeArea(
      child: Consumer<PartnerAuthProvider>(builder: (context, auth, _) {
        final email = auth.pendingEmail ?? '';
        return Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 72, height: 72, decoration: BoxDecoration(color: const Color(0xFFFF6530), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.verified_user, color: Colors.white, size: 36))),
              const SizedBox(height: 20),
              const Text('Verify Your Email', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const SizedBox(height: 8),
              const Text('Enter the 6-digit OTP sent to', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 4),
              Text(email, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF6530))),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_boxCount, (index) {
                return Container(width: 48, height: 56, margin: const EdgeInsets.symmetric(horizontal: 4), child: TextField(
                  controller: _controllers[index], focusNode: _focusNodes[index], keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 1,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
                  decoration: InputDecoration(counterText: '', filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6530), width: 2))),
                  onChanged: (value) { if (value.isNotEmpty && index < _boxCount - 1) _focusNodes[index + 1].requestFocus(); _onBoxChanged(index, value); },
                ));
              })),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: auth.status == AuthStatus.loading ? null : _verify,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6530), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: auth.status == AuthStatus.loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Verify OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                  onPressed: _resendCountdown > 0 ? null : _resend,
                  child: Text(_resendCountdown > 0 ? 'Resend in $_resendCountdown s' : 'Resend OTP',
                    style: TextStyle(color: _resendCountdown > 0 ? const Color(0xFF6B7280) : const Color(0xFFFF6530), fontWeight: FontWeight.w600)),
                ),
              ]),
              if (auth.error != null && auth.status == AuthStatus.otpSent) ...[
                const SizedBox(height: 16),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3F0), borderRadius: BorderRadius.circular(8), border: Border.all(color: Color(0xFFE53935))),
                  child: Text(auth.error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFFE53935)))),
              ],
            ],
          )),
        ));
      }),
    ));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }

    for (final f in _focusNodes) {
      f.dispose();
    }

    super.dispose();
  }
}
