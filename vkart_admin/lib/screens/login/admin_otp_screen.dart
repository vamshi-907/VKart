import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/admin_auth_provider.dart';
import '../../config/admin_auth_config.dart';
import '../../materials/vkart_colors.dart';
import '../../widgets/vkart_button.dart';

/// OTP verification screen.
///
/// Displays the recipient email, six auto-focused OTP boxes, paste support, a
/// countdown timer, and a resend option (with cooldown). On success the auth
/// provider transitions to the dashboard.
class AdminOtpScreen extends StatefulWidget {
  const AdminOtpScreen({super.key});

  @override
  State<AdminOtpScreen> createState() => _AdminOtpScreenState();
}

class _AdminOtpScreenState extends State<AdminOtpScreen> {
  static const int _boxCount = AdminAuthConfig.otpLength;

  final List<TextEditingController> _controllers = List.generate(
    _boxCount,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _boxCount,
    (_) => FocusNode(),
  );

  Timer? _countdownTimer;
  int _expiryCountdown = 0;
  int _resendCountdown = 0;
  late final AdminAuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AdminAuthProvider>();
    _startCountdown();
    // Focus the first box after the frame is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _loadRemaining();
  }

  Future<void> _loadRemaining() async {
    final expiryRemaining = await _auth.otpSecondsRemaining();
    final resendRemaining = await _auth.resendSecondsRemaining();
    if (!mounted) return;
    setState(() {
      _expiryCountdown = expiryRemaining;
      _resendCountdown = resendRemaining;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_expiryCountdown > 0) _expiryCountdown--;
        if (_resendCountdown > 0) _resendCountdown--;
        if (_expiryCountdown <= 0 && _resendCountdown <= 0) {
          timer.cancel();
        }
      });
    });
  }

  String get _otpValue {
    final buffer = StringBuffer();
    for (final c in _controllers) {
      buffer.write(c.text);
    }
    return buffer.toString();
  }

  void _onBoxChanged(int index, String value) {
    if (value.length == 1 && index < _boxCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-submit when all boxes are filled.
    if (_otpValue.length == _boxCount) {
      _verify();
    }
  }

void _handlePaste(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    for (var i = 0; i < _boxCount; i++) {
      if (i < digits.length) {
        _controllers[i].text = digits[i];
      } else {
        _controllers[i].clear();
      }
    }
    // Move focus to the last filled box.
    final lastIndex = digits.length.clamp(0, _boxCount - 1);
    _focusNodes[lastIndex].requestFocus();

    if (_otpValue.length == _boxCount) {
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_otpValue.length != _boxCount) return;
    FocusScope.of(context).unfocus();
    await _auth.verifyOtp(_otpValue);
  }

  Future<void> _resend() async {
    if (_resendCountdown > 0) return;
    await _auth.resendOtp();
    _startCountdown();
    // Clear boxes for a fresh code.
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.pendingEmail ?? '';

    return Scaffold(
      backgroundColor: VKartColors.background,
      body: SafeArea(
        child: Consumer<AdminAuthProvider>(
          builder: (context, auth, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Branding
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: VKartColors.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Enter Verification Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: VKartColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We sent a 6-digit code to\n$email',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: VKartColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // OTP boxes
                      _buildOtpBoxes(),

                      const SizedBox(height: 24),

                      // Error / message
                      if (auth.error != null) ...[
                        Text(
                          auth.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: VKartColors.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Verify button
                      VKartButton(
                        text: 'Verify',
                        prefixIcon: Icons.verified_user_rounded,
                        height: 52,
                        isLoading: auth.status == AuthStatus.loading,
                        onPressed: _verify,
                      ),

                      const SizedBox(height: 24),

                      // Countdown + Resend
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_expiryCountdown > 0)
                              Text(
                                'Code expires in ${_formatTime(_expiryCountdown)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: VKartColors.secondaryText,
                                ),
                              )
                            else
                              const Text(
                                'Code expired',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: VKartColors.error,
                                ),
                              ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _resendCountdown > 0 ? null : _resend,
                              child: Text(
                                _resendCountdown > 0
                                    ? 'Resend in ${_resendCountdown}s'
                                    : 'Resend OTP',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: VKartColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) => false,
                                );
                          },
                          child: const Text(
                            'Change Email',
                            style: TextStyle(
                              fontSize: 13,
                              color: VKartColors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_boxCount, (index) {
        return Container(
          width: 52,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: VKartColors.primaryText,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: VKartColors.surface,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: VKartColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: VKartColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: VKartColors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.length > 1) {
                // Paste of multiple digits into a single box.
                _handlePaste(value);
              } else {
                _onBoxChanged(index, value);
              }
            },
            onEditingComplete: () {
              if (index < _boxCount - 1) {
                _focusNodes[index + 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
