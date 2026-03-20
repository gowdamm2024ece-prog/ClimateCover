// lib/screens/policy/plan_select_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/policy.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gs_button.dart';

class PlanSelectScreen extends ConsumerStatefulWidget {
  const PlanSelectScreen({super.key});
  @override
  ConsumerState<PlanSelectScreen> createState() => _PlanSelectScreenState();
}

class _PlanSelectScreenState extends ConsumerState<PlanSelectScreen> {
  String? _selectedPlanId;
  double? _quotedPremium;
  bool _quoting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(policyProvider.notifier).loadPlans());
  }

  Future<void> _getQuote(String planId) async {
    setState(() { _selectedPlanId = planId; _quoting = true; });
    final q = await ref.read(policyProvider.notifier).getQuote(planId);
    setState(() { _quotedPremium = q; _quoting = false; });
  }

  Future<void> _subscribe() async {
    if (_selectedPlanId == null) return;
    final ok = await ref.read(policyProvider.notifier).subscribe(_selectedPlanId!);
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(policyProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Choose a plan')),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Weekly coverage plans',
                          style: AppText.h2),
                      const SizedBox(height: 6),
                      const Text(
                        'Premium auto-adjusts based on your city risk and platform',
                        style: AppText.body),
                      const SizedBox(height: 24),
                      ...state.plans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlanCard(
                          plan: plan,
                          isSelected: _selectedPlanId == plan.id,
                          onTap: () => _getQuote(plan.id),
                        ),
                      )),
                    ],
                  ),
          ),

          // Bottom CTA
          if (_selectedPlanId != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  if (_quoting)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(color: AppColors.primary),
                    ),
                  if (_quotedPremium != null && !_quoting) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your weekly premium', style: AppText.body),
                        Text('₹${_quotedPremium!.toStringAsFixed(0)}/week',
                            style: const TextStyle(
                              fontFamily: 'Sora', fontSize: 18,
                              fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  GsButton(
                    label: _quotedPremium != null
                        ? 'Subscribe for ₹${_quotedPremium!.toStringAsFixed(0)}/week'
                        : 'Get quote',
                    isLoading: state.isLoading,
                    onPressed: _quotedPremium != null ? _subscribe : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final InsurancePlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  const _PlanCard({required this.plan, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(plan.name,
                              style: const TextStyle(
                                fontFamily: 'Sora', fontSize: 16,
                                fontWeight: FontWeight.w600, color: AppColors.ink)),
                          if (plan.isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Recommended',
                                  style: TextStyle(
                                    fontFamily: 'Sora', fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(plan.description, style: AppText.small),
                    ],
                  ),
                ),
                Text('₹${plan.baseWeeklyPremium.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Sora', fontSize: 22,
                      fontWeight: FontWeight.w700, color: AppColors.ink)),
                const Text('/wk',
                    style: TextStyle(fontFamily: 'Sora',
                        fontSize: 12, color: AppColors.inkLight)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _Feature('Up to ${plan.maxCoverageHours}h covered'),
                const SizedBox(width: 16),
                _Feature('Max ₹${plan.maxWeeklyPayout.toStringAsFixed(0)}/week'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String label;
  const _Feature(this.label);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.check_rounded, color: AppColors.success, size: 14),
      const SizedBox(width: 4),
      Text(label, style: AppText.small),
    ],
  );
}