// lib/screens/policy/policy_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';

class PolicyDetailScreen extends ConsumerStatefulWidget {
  const PolicyDetailScreen({super.key});

  @override
  ConsumerState<PolicyDetailScreen> createState() =>
      _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends ConsumerState<PolicyDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(policyProvider.notifier).loadPolicy());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(policyProvider);
    final policy = state.activePolicy;

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (policy == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Policy')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.shield_outlined,
                      size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text('No active policy', style: AppText.h2),
                const SizedBox(height: 8),
                const Text(
                  'Subscribe to a weekly plan to get income protection during disruptions.',
                  style: AppText.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => context.go('/plans'),
                  child: const Text('Choose a plan'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('My Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${policy.planName} Plan',
                        style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            color: Colors.white70),
                      ),
                      const Spacer(),
                      _StatusBadge(policy.status),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${policy.finalWeeklyPremium.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6, left: 4),
                        child: Text(
                          '/week',
                          style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Base ₹${policy.basePremium.toStringAsFixed(0)} + risk adjustment ₹${policy.riskAdjustment.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        color: Colors.white60),
                  ),
                  const SizedBox(height: 20),
                  // Week progress bar
                  _WeekProgressBar(
                    start: policy.currentWeekStart,
                    end: policy.currentWeekEnd,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _MiniStat('Weeks paid', '${policy.weeksPaid}'),
                const SizedBox(width: 10),
                _MiniStat('Max hours',
                    '${policy.maxCoverageHours}h'),
                const SizedBox(width: 10),
                _MiniStat('Max payout',
                    '₹${policy.maxWeeklyPayout.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 16),

            // Coverage card
            _InfoCard(
              title: 'Coverage details',
              rows: [
                _InfoRow('Plan', policy.planName),
                _InfoRow('Status', policy.status.toUpperCase()),
                _InfoRow('Active since',
                    '${policy.activationDate.day}/${policy.activationDate.month}/${policy.activationDate.year}'),
                _InfoRow('Current week',
                    '${_fmtDate(policy.currentWeekStart)} – ${_fmtDate(policy.currentWeekEnd)}'),
                _InfoRow('Total paid',
                    '₹${policy.totalPremiumsPaid.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 16),

            // Pricing breakdown card
            _InfoCard(
              title: 'How your premium is calculated',
              subtitle: 'AI-adjusted based on your city and platform',
              rows: [
                _InfoRow('Base rate',
                    '₹${policy.basePremium.toStringAsFixed(0)}'),
                ...policy.pricingFactors.entries.map((e) => _InfoRow(
                  _labelFor(e.key),
                  '×${e.value.toStringAsFixed(2)}',
                )),
                _InfoRow(
                    'Final premium',
                    '₹${policy.finalWeeklyPremium.toStringAsFixed(0)}/week',
                    highlight: true),
              ],
            ),
            const SizedBox(height: 16),

            // What's covered card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What triggers a payout',
                      style: AppText.h3),
                  const SizedBox(height: 14),
                  ...[
                    ('Heavy rain', 'Rainfall > 50 mm/hr',
                        Icons.water_drop_rounded),
                    ('Flood alert', 'Official IMD flood warning',
                        Icons.flood_rounded),
                    ('Severe pollution', 'AQI > 300',
                        Icons.air_rounded),
                    ('Extreme heat', 'Temperature > 45°C',
                        Icons.thermostat_rounded),
                    ('Curfew / strike', 'Admin verified',
                        Icons.warning_amber_rounded),
                  ].map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(t.$3,
                                color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.$1,
                                  style: const TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.ink)),
                              Text(t.$2, style: AppText.small),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}';
  String _labelFor(String key) {
    switch (key) {
      case 'city_risk': return 'City risk (Mumbai)';
      case 'platform': return 'Platform (Zomato)';
      case 'ml_score': return 'ML risk score';
      default: return key.replaceAll('_', ' ');
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF34D399) : Colors.white54,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _WeekProgressBar extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  const _WeekProgressBar({required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final total = end.difference(start).inSeconds.toDouble();
    final elapsed = now.difference(start).inSeconds.toDouble();
    final progress = (elapsed / total).clamp(0.0, 1.0);
    final daysLeft = end.difference(now).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Week progress',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  color: const Color(0xB3FFFFFF)),
            ),
            Text(
              '$daysLeft days left',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  color: const Color(0xB3FFFFFF)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0x33FFFFFF),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
            const SizedBox(height: 2),
            Text(label, style: AppText.small),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<_InfoRow> rows;
  const _InfoCard(
      {required this.title, this.subtitle, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h3),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: AppText.small),
          ],
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _InfoRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: highlight
                  ? const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink)
                  : AppText.label),
          Text(value,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: highlight ? 15 : 13,
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.w500,
                color:
                    highlight ? AppColors.primary : AppColors.ink,
              )),
        ],
      ),
    );
  }
}