// lib/screens/claims/claim_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/claim.dart';
import '../../providers/app_providers.dart';

class ClaimHistoryScreen extends ConsumerStatefulWidget {
  const ClaimHistoryScreen({super.key});
  @override
  ConsumerState<ClaimHistoryScreen> createState() => _ClaimHistoryScreenState();
}

class _ClaimHistoryScreenState extends ConsumerState<ClaimHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(claimProvider.notifier).loadClaims());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(claimProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Claim History')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.claims.isEmpty
              ? _EmptyState()
              : Column(
                  children: [
                    // Total credited banner
                    Container(
                      width: double.infinity,
                      color: AppColors.white,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total credited', style: AppText.label),
                              const SizedBox(height: 4),
                              Text(
                                '₹${state.totalCredited.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'Sora', fontSize: 28,
                                  fontWeight: FontWeight.w700, color: AppColors.success),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${state.claims.where((c) => c.isPaid).length}',
                                  style: const TextStyle(
                                    fontFamily: 'Sora', fontSize: 28,
                                    fontWeight: FontWeight.w700, color: AppColors.ink)),
                              const Text('claims paid', style: AppText.label),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.claims.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _ClaimTile(
                          claim: state.claims[i],
                          onTap: () => context.go('/claims/${state.claims[i].id}'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  final Claim claim;
  final VoidCallback onTap;
  const _ClaimTile({required this.claim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (claim.status) {
      case 'paid':
        statusColor = AppColors.success;
        statusLabel = 'Paid';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'evaluating':
      case 'triggered':
        statusColor = AppColors.warning;
        statusLabel = 'Evaluating';
        statusIcon = Icons.pending_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.danger;
        statusLabel = 'Rejected';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.inkLight;
        statusLabel = claim.status;
        statusIcon = Icons.info_outline_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(claim.disruptionLabel,
                      style: const TextStyle(fontFamily: 'Sora',
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(DateFormat('d MMM yyyy, h:mm a').format(claim.triggeredAt),
                      style: AppText.small),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  claim.isPaid
                      ? '₹${claim.finalPayout?.toStringAsFixed(0)}'
                      : statusLabel,
                  style: TextStyle(
                    fontFamily: 'Sora', fontSize: 15,
                    fontWeight: FontWeight.w700, color: statusColor),
                ),
                if (claim.isPaid)
                  const Text('credited', style: AppText.small),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppColors.inkLight),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          const Text('No claims yet', style: AppText.h3),
          const SizedBox(height: 8),
          const Text('Claims appear here when disruptions occur',
              style: AppText.body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}