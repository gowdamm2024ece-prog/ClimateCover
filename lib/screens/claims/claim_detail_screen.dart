// lib/screens/claims/claim_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/claim.dart';
import '../../providers/app_providers.dart';

class ClaimDetailScreen extends ConsumerWidget {
  final String claimId;
  const ClaimDetailScreen({super.key, required this.claimId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: getById is on the notifier, not on ClaimState
    final claim = ref.read(claimProvider.notifier).getById(claimId);

    if (claim == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Claim')),
        body: const Center(child: Text('Claim not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Claim details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _HeroCard(claim: claim),
            const SizedBox(height: 16),
            _TimelineCard(claim: claim),
            const SizedBox(height: 16),
            if (claim.slotBreakdown.isNotEmpty) ...[
              _SlotBreakdownCard(claim: claim),
              const SizedBox(height: 16),
            ],
            if (claim.fraudScore != null) ...[
              _FraudCard(score: claim.fraudScore!),
              const SizedBox(height: 16),
            ],
            _DetailsCard(claim: claim),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Claim claim;
  const _HeroCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final color = claim.isPaid ? AppColors.success : AppColors.warning;
    final icon = claim.isPaid
        ? Icons.check_circle_rounded
        : Icons.pending_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            claim.isPaid
                ? '₹${claim.finalPayout?.toStringAsFixed(0) ?? "0"}'
                : 'Evaluating...',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            claim.isPaid
                ? 'Credited to ${claim.disruptionCity} UPI'
                : 'Payout calculating',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              color: Color(0xCCFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Claim claim;
  const _TimelineCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        'Disruption detected',
        true,
        DateFormat('h:mm a').format(claim.triggeredAt)
      ),
      (
        'Claim triggered',
        true,
        DateFormat('h:mm a').format(claim.triggeredAt)
      ),
      (
        'Fraud check',
        claim.isPaid || claim.fraudScore != null,
        claim.fraudScore != null
            ? 'Score: ${(claim.fraudScore! * 100).toInt()}/100'
            : ''
      ),
      ('Approved', claim.isPaid, ''),
      (
        'Payout credited',
        claim.isPaid,
        claim.paidAt != null
            ? DateFormat('h:mm a').format(claim.paidAt!)
            : ''
      ),
    ];

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
          const Text('Timeline', style: AppText.h3),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map(
            (e) => _buildStep(e.value.$1, e.value.$2, e.value.$3,
                e.key == steps.length - 1),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
      String label, bool done, String subtitle, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done ? AppColors.success : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: done ? AppColors.success : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        done ? AppColors.ink : AppColors.inkLight,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: AppText.small),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SlotBreakdownCard extends StatelessWidget {
  final Claim claim;
  const _SlotBreakdownCard({required this.claim});

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
          const Text('Slot-by-slot breakdown', style: AppText.h3),
          const SizedBox(height: 4),
          const Text(
            'Based on your 4-week average per time slot',
            style: AppText.small,
          ),
          const SizedBox(height: 16),
          ...claim.slotBreakdown.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.slotTime,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (s.amount / 350).clamp(0.1, 1.0),
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '₹${s.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total payout', style: AppText.h3),
              Text(
                '₹${(claim.finalPayout ?? claim.calculatedPayout).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FraudCard extends StatelessWidget {
  final double score;
  const _FraudCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final isClean = score < 0.5;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isClean ? AppColors.successLight : AppColors.dangerLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isClean
              ? AppColors.success.withAlpha(76)
              : AppColors.danger.withAlpha(76),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isClean
                ? Icons.verified_rounded
                : Icons.warning_rounded,
            color: isClean ? AppColors.success : AppColors.danger,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isClean ? 'Verified clean' : 'Flagged for review',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isClean
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
                Text(
                  'Fraud score: ${(score * 100).toInt()}/100 · GPS verified · Work confirmed',
                  style: AppText.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Claim claim;
  const _DetailsCard({required this.claim});

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
          const Text('Claim details', style: AppText.h3),
          const SizedBox(height: 14),
          _row('Disruption type', claim.disruptionLabel),
          _row('City', claim.disruptionCity),
          _row('Protected hours',
              '${claim.protectedHours.toStringAsFixed(0)} hours'),
          _row('Triggered',
              DateFormat('d MMM yyyy, h:mm a').format(claim.triggeredAt)),
          if (claim.paidAt != null)
            _row('Paid at',
                DateFormat('d MMM yyyy, h:mm a').format(claim.paidAt!)),
          _row('Claim ID', claim.id),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.label),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      );
}