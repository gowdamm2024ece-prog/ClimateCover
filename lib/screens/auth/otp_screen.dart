// lib/screens/auth/otp_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gs_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  String _maskedAadhaar(String raw) {
    if (raw.length < 4) return raw;
    final last4 = raw.substring(raw.length - 4);
    return 'XXXX XXXX $last4';
  }

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    final aadhaar = ref.read(authProvider).pendingAadhaar ?? '';
    final ok = await ref.read(authProvider.notifier).verifyOtp(aadhaar, _otp);
    if (!mounted) return;
    if (ok) {
      final userType = ref.read(authProvider).userType;
      if (userType == 'existing_user') {
        context.go('/home');
      } else {
        context.go('/register');
      }
    }
  }

  Future<void> _resend() async {
    final aadhaar = ref.read(authProvider).pendingAadhaar ?? '';
    await ref.read(authProvider.notifier).sendOtp(aadhaar);
    _startTimer();
    for (final c in _ctrls) { c.clear(); }
    if (mounted) _nodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final aadhaar = state.pendingAadhaar ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Verify OTP', style: AppText.h1),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit OTP sent to your mobile linked with Aadhaar',
                style: AppText.body,
              ),
              const SizedBox(height: 6),
              Text(
                _maskedAadhaar(aadhaar),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 36),

              // 6-box OTP input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _ctrls[i],
                  focusNode: _nodes[i],
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      _nodes[i + 1].requestFocus();
                    }
                    setState(() {});
                  },
                  onBackspace: () {
                    if (_ctrls[i].text.isEmpty && i > 0) {
                      _ctrls[i - 1].clear();
                      _nodes[i - 1].requestFocus();
                    }
                  },
                )),
              ),

              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Demo: use OTP 123456',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkLight,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Error
              if (state.error != null) ...[
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
                const SizedBox(height: 16),
              ],

              GsButton(
                label: 'Verify OTP',
                isLoading: state.isLoading,
                onPressed: _otp.length == 6 ? _verify : null,
              ),
              const SizedBox(height: 20),

              // Resend
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Resend OTP in ${_secondsLeft}s',
                        style: AppText.body,
                      )
                    : GestureDetector(
                        onTap: state.isLoading ? null : _resend,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    return SizedBox(
      width: 46,
      height: 54,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            widget.onBackspace();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _focused ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focused
                  ? AppColors.primary
                  : filled
                      ? AppColors.primary.withAlpha(120)
                      : AppColors.border,
              width: _focused ? 2 : 1.5,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}
