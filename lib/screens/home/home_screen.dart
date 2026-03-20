// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/app_providers.dart';
import '../../models/disruption.dart';
import '../../models/claim.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(claimProvider.notifier).loadClaims();
      ref.read(policyProvider.notifier).loadPolicy();
      ref.read(slotProvider.notifier).loadToday();
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth    = ref.watch(authProvider);
    final claims  = ref.watch(claimProvider);
    final slots   = ref.watch(slotProvider);
    final policy  = ref.watch(policyProvider);
    final worker  = auth.worker;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(claimProvider.notifier).loadClaims();
          await ref.read(slotProvider.notifier).loadToday();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary,
                  padding:
                      const EdgeInsets.fromLTRB(24, 60, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good ${_greeting()}, ${worker?.firstName ?? ""}',
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  worker?.city ?? 'Mumbai',
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 13,
                                    color: Color(0xBFFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                const Color(0x33FFFFFF),
                            child: Text(
                              worker?.initials ?? 'RK',
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (claims.activeDisruption != null)
                    _DisruptionBanner(
                        disruption: claims.activeDisruption!),
                  if (claims.claims.any((c) => c.isEvaluating))
                    _EvaluatingClaimCard(
                      claim: claims.claims
                          .firstWhere((c) => c.isEvaluating),
                    ),
                  _StatsRow(
                    hoursProtected: 10,
                    totalCredited: claims.totalCredited,
                    weeksActive:
                        policy.activePolicy?.weeksPaid ?? 0,
                  ),
                  const SizedBox(height: 16),
                  _PolicyCard(
                    hasPolicy: policy.activePolicy != null,
                    premium:
                        policy.activePolicy?.finalWeeklyPremium,
                    planName: policy.activePolicy?.planName,
                    weekStart:
                        policy.activePolicy?.currentWeekStart,
                    onTap: () => policy.activePolicy == null
                        ? context.go('/plans')
                        : context.go('/policy'),
                  ),
                  const SizedBox(height: 16),
                  _TodaySlotsCard(slots: slots),
                  const SizedBox(height: 16),
                  if (claims.claims.isNotEmpty)
                    _LastClaimCard(
                      claim: claims.claims.firstWhere(
                        (c) => c.isPaid,
                        orElse: () => claims.claims.first,
                      ),
                      onTap: () => context
                          .go('/claims/${claims.claims.first.id}'),
                    ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Disruption Banner ─────────────────────────────────────────────
class _DisruptionBanner extends StatelessWidget {
  final DisruptionEvent disruption;
  const _DisruptionBanner({required this.disruption});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.disruptionLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.disruption.withAlpha(76)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.disruption.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storm_rounded,
                color: AppColors.disruption, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${disruption.typeLabel} in ${disruption.city}',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.disruption,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rainfall: ${disruption.rainfallMm.toStringAsFixed(1)} mm/hr · Claim auto-triggered',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.disruption,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Evaluating Claim Card ─────────────────────────────────────────
class _EvaluatingClaimCard extends StatefulWidget {
  final Claim claim;
  const _EvaluatingClaimCard({required this.claim});

  @override
  State<_EvaluatingClaimCard> createState() =>
      _EvaluatingClaimCardState();
}

class _EvaluatingClaimCardState extends State<_EvaluatingClaimCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: _pulse,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Claim evaluating...',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fraud check running · Payout calculating',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final double hoursProtected;
  final double totalCredited;
  final int weeksActive;

  const _StatsRow({
    required this.hoursProtected,
    required this.totalCredited,
    required this.weeksActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
            label: 'Hours protected',
            value: '${hoursProtected.toInt()}h'),
        const SizedBox(width: 10),
        _StatCard(
            label: 'Total credited',
            value: '₹${totalCredited.toStringAsFixed(0)}'),
        const SizedBox(width: 10),
        _StatCard(label: 'Weeks active', value: '$weeksActive'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppText.small),
          ],
        ),
      ),
    );
  }
}

// ── Policy Card ───────────────────────────────────────────────────
class _PolicyCard extends StatelessWidget {
  final bool hasPolicy;
  final double? premium;
  final String? planName;
  final DateTime? weekStart;
  final VoidCallback onTap;

  const _PolicyCard({
    required this.hasPolicy,
    this.premium,
    this.planName,
    this.weekStart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasPolicy) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get protected today',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'From ₹49/week · Zero paperwork',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        color: Color(0xB3FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
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
                  '$planName Plan',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${premium?.toStringAsFixed(0) ?? "91"}',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  '/week',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
                const Spacer(),
                if (weekStart != null)
                  Text(
                    'Week of ${DateFormat("d MMM").format(weekStart!)}',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: Color(0xB3FFFFFF),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Today's Slots Card ────────────────────────────────────────────
class _TodaySlotsCard extends StatelessWidget {
  final SlotState slots;
  const _TodaySlotsCard({required this.slots});

  @override
  Widget build(BuildContext context) {
    final submitted = slots.slots.where((s) => s.submitted).length;
    final total = slots.slots.length;

    return GestureDetector(
      onTap: () => context.go('/slots'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Today's earnings", style: AppText.h3),
                const Spacer(),
                Text('$submitted/$total slots', style: AppText.small),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.inkLight),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: slots.slots
                  .map(
                    (s) => Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: s.submitted
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '₹${slots.totalEarnings.toStringAsFixed(0)} earned',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Spacer(),
                Text('${slots.totalDeliveries} deliveries',
                    style: AppText.body),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Last Claim Card ───────────────────────────────────────────────
class _LastClaimCard extends StatelessWidget {
  final Claim claim;
  final VoidCallback onTap;
  const _LastClaimCard({required this.claim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: claim.isPaid
                    ? AppColors.successLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                claim.isPaid
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                color: claim.isPaid
                    ? AppColors.success
                    : AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    claim.disruptionLabel,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    DateFormat('d MMM, h:mm a')
                        .format(claim.triggeredAt),
                    style: AppText.small,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  claim.isPaid
                      ? '₹${claim.finalPayout?.toStringAsFixed(0)}'
                      : 'Evaluating',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: claim.isPaid
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                Text('credited', style: AppText.small),
              ],
            ),
          ],
        ),
      ),
    );
  }
}