// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gs_button.dart';

class AadhaarEntryScreen extends ConsumerStatefulWidget {
  const AadhaarEntryScreen({super.key});

  @override
  ConsumerState<AadhaarEntryScreen> createState() => _AadhaarEntryScreenState();
}

class _AadhaarEntryScreenState extends ConsumerState<AadhaarEntryScreen> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _rawAadhaar() => _ctrl.text.replaceAll(' ', '');

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).sendOtp(_rawAadhaar());
    if (mounted) context.go('/otp');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: const [
                          Icon(Icons.wb_cloudy_rounded,
                              color: AppColors.primary, size: 28),
                          Positioned(
                            bottom: 7,
                            right: 7,
                            child: Icon(Icons.umbrella_rounded,
                                color: AppColors.primary, size: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Climate Cover',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 52),
                const Text('Enter your Aadhaar', style: AppText.h1),
                const SizedBox(height: 8),
                const Text(
                  'We\'ll send a one-time password to your Aadhaar-linked mobile number',
                  style: AppText.body,
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _AadhaarFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Aadhaar number',
                    hintText: '1234 5678 9012',
                    prefixIcon: const Icon(Icons.fingerprint,
                        color: AppColors.primary),
                    counterText: '',
                  ),
                  maxLength: 14, // 12 digits + 2 spaces
                  validator: (v) {
                    final raw = v?.replaceAll(' ', '') ?? '';
                    if (raw.length != 12) return 'Enter a valid 12-digit Aadhaar number';
                    if (RegExp(r'[^0-9]').hasMatch(raw)) return 'Only digits allowed';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                GsButton(
                  label: 'Send OTP',
                  isLoading: state.isLoading,
                  onPressed: _sendOtp,
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      state.error!,
                      style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                          fontFamily: 'Sora'),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Your Aadhaar is used only for identity verification.\nNo data is stored without consent.',
                    textAlign: TextAlign.center,
                    style: AppText.small,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Formats a digit-only string as "XXXX XXXX XXXX"
class _AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    if (digits.length > 12) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 8) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
