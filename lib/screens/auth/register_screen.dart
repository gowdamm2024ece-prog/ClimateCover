// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gs_button.dart';
import '../../widgets/gs_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _platform = 'Zomato';
  String _city = 'Mumbai';
  int _step = 0;

  final _platforms = ['Zomato', 'Swiggy', 'Amazon', 'Flipkart', 'Zepto', 'Blinkit'];
  final _cities = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Hyderabad', 'Kolkata', 'Pune'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _aadhaarCtrl.dispose(); _upiCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register({
      'first_name': _nameCtrl.text.split(' ').first,
      'last_name': _nameCtrl.text.split(' ').skip(1).join(' '),
      'phone_number': _phoneCtrl.text,
      'aadhaar_number': _aadhaarCtrl.text,
      'platform': _platform.toLowerCase(),
      'city': _city,
      'upi_id': _upiCtrl.text,
      'username': _phoneCtrl.text,
      'password': _passCtrl.text,
    });
    if (mounted) context.go('/plans');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => _step == 0 ? context.go('/login') : setState(() => _step--),
        ),
        title: Text(_step == 0 ? 'Personal details' : 'Work details'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: List.generate(2, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 0 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _step ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: _step == 0 ? _buildStep1() : _buildStep2(state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tell us about yourself', style: AppText.h2),
        const SizedBox(height: 6),
        const Text('We verify your identity securely', style: AppText.body),
        const SizedBox(height: 28),
        GsTextField(
          controller: _nameCtrl,
          label: 'Full name',
          hint: 'Rahul Kumar',
          prefixIcon: Icons.person_outline_rounded,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        GsTextField(
          controller: _phoneCtrl,
          label: 'Phone number',
          hint: '9876543210',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          validator: (v) => v == null || v.length < 10 ? 'Enter 10-digit number' : null,
        ),
        const SizedBox(height: 16),
        GsTextField(
          controller: _aadhaarCtrl,
          label: 'Aadhaar number',
          hint: '1234 5678 9012',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.credit_card_outlined,
          validator: (v) => v == null || v.replaceAll(' ', '').length != 12
              ? 'Enter 12-digit Aadhaar' : null,
        ),
        const SizedBox(height: 16),
        GsTextField(
          controller: _passCtrl,
          label: 'Create password',
          hint: 'Min 8 characters',
          obscureText: true,
          prefixIcon: Icons.lock_outline_rounded,
          validator: (v) => v == null || v.length < 8 ? 'Min 8 characters' : null,
        ),
        const SizedBox(height: 32),
        GsButton(
          label: 'Continue',
          onPressed: () {
            if (_formKey.currentState!.validate()) setState(() => _step = 1);
          },
        ),
      ],
    );
  }

  Widget _buildStep2(AuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Work details', style: AppText.h2),
        const SizedBox(height: 6),
        const Text('Helps us calculate your accurate premium', style: AppText.body),
        const SizedBox(height: 28),

        // Platform selector
        _SectionLabel('Delivery platform'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _platforms.map((p) => _Chip(
            label: p,
            selected: _platform == p,
            onTap: () => setState(() => _platform = p),
          )).toList(),
        ),
        const SizedBox(height: 20),

        // City selector
        _SectionLabel('Your city'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _cities.map((c) => _Chip(
            label: c,
            selected: _city == c,
            onTap: () => setState(() => _city = c),
          )).toList(),
        ),
        const SizedBox(height: 20),

        GsTextField(
          controller: _upiCtrl,
          label: 'UPI ID (for payouts)',
          hint: 'yourname@upi',
          prefixIcon: Icons.account_balance_wallet_outlined,
          validator: (v) => v == null || v.isEmpty ? 'Required for payouts' : null,
        ),
        const SizedBox(height: 32),
        GsButton(
          label: 'Create account',
          isLoading: state.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.inkLight));
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.inkMid,
            )),
      ),
    );
  }
}