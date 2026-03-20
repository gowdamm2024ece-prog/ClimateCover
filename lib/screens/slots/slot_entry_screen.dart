// lib/screens/slots/slot_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/mock_data.dart';
import '../../providers/app_providers.dart';
import '../../models/earning_slot.dart';

class SlotEntryScreen extends ConsumerStatefulWidget {
  const SlotEntryScreen({super.key});
  @override
  ConsumerState<SlotEntryScreen> createState() => _SlotEntryScreenState();
}

class _SlotEntryScreenState extends ConsumerState<SlotEntryScreen> {
  final Map<String, TextEditingController> _earnCtrl = {};
  final Map<String, TextEditingController> _delCtrl = {};
  final _allSlots = [
    '06:00','08:00','10:00','12:00',
    '14:00','16:00','18:00','20:00',
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _allSlots) {
      _earnCtrl[s] = TextEditingController();
      _delCtrl[s] = TextEditingController();
    }
    Future.microtask(() => ref.read(slotProvider.notifier).loadToday());
  }

  @override
  void dispose() {
    for (final c in _earnCtrl.values) { c.dispose(); }
    for (final c in _delCtrl.values) { c.dispose(); }
    super.dispose();
  }

  String _slotLabel(String start) {
    final h = int.parse(start.split(':')[0]);
    return '$start–${(h + 2).toString().padLeft(2, '0')}:00';
  }

  Color _slotColor(String start) {
    final h = int.parse(start.split(':')[0]);
    if (h == 12 || h == 18) return AppColors.slotPeak;
    if (h == 8 || h == 20) return AppColors.slotHigh;
    if (h >= 10 && h <= 16) return AppColors.slotNormal;
    return AppColors.slotLow;
  }

  String _slotTag(String start) {
    final h = int.parse(start.split(':')[0]);
    if (h == 12) return 'Lunch Peak';
    if (h == 18) return 'Dinner Peak';
    if (h == 8) return 'Morning Rush';
    if (h == 20) return 'Night';
    return '';
  }

  double _slotAvg(String start) => MockData.slotAverages[start] ?? 0;

  @override
  Widget build(BuildContext context) {
    final slotState = ref.watch(slotProvider);
    final submittedMap = {for (var s in slotState.slots) s.slotStart: s};

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s Slots'),
            Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: AppText.small),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary banner
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                _SummaryPill(
                  label: 'Earned',
                  value: '₹${slotState.totalEarnings.toStringAsFixed(0)}',
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                _SummaryPill(
                  label: 'Deliveries',
                  value: '${slotState.totalDeliveries}',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                _SummaryPill(
                  label: 'Slots filled',
                  value: '${slotState.slots.where((s) => s.submitted).length}/8',
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _allSlots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final slot = _allSlots[i];
                final submitted = submittedMap[slot];
                final color = _slotColor(slot);
                final tag = _slotTag(slot);
                final avg = _slotAvg(slot);
                final isNow = _isCurrentSlot(slot);

                return _SlotCard(
                  slotTime: _slotLabel(slot),
                  color: color,
                  tag: tag,
                  avg: avg,
                  isNow: isNow,
                  submitted: submitted,
                  earnCtrl: _earnCtrl[slot]!,
                  delCtrl: _delCtrl[slot]!,
                  isSaving: slotState.isSaving,
                  onSubmit: () => _submit(slot),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentSlot(String start) {
    final h = DateTime.now().hour;
    final slotH = int.parse(start.split(':')[0]);
    return h >= slotH && h < slotH + 2;
  }

  Future<void> _submit(String slot) async {
    final earn = double.tryParse(_earnCtrl[slot]!.text) ?? 0;
    final del = int.tryParse(_delCtrl[slot]!.text) ?? 0;
    if (earn <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter earnings for this slot')),
      );
      return;
    }
    await ref.read(slotProvider.notifier).submitSlot(slot, earn, del);
    _earnCtrl[slot]!.clear();
    _delCtrl[slot]!.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Slot $slot saved — ₹${earn.toStringAsFixed(0)}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
                fontFamily: 'Sora', fontSize: 16,
                fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppText.small),
          ],
        ),
      ),
    );
  }
}

class _SlotCard extends StatefulWidget {
  final String slotTime;
  final Color color;
  final String tag;
  final double avg;
  final bool isNow;
  final EarningSlot? submitted;
  final TextEditingController earnCtrl;
  final TextEditingController delCtrl;
  final bool isSaving;
  final VoidCallback onSubmit;

  const _SlotCard({
    required this.slotTime, required this.color, required this.tag,
    required this.avg, required this.isNow, this.submitted,
    required this.earnCtrl, required this.delCtrl,
    required this.isSaving, required this.onSubmit,
  });

  @override
  State<_SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends State<_SlotCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDone = widget.submitted != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isNow && !isDone
              ? widget.color.withAlpha(127)
              : AppColors.border,
          width: widget.isNow && !isDone ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (!isDone) setState(() => _expanded = !_expanded);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Color dot + time
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                        color: isDone ? AppColors.success : widget.color,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(widget.slotTime,
                                style: const TextStyle(
                                  fontFamily: 'Sora', fontSize: 14,
                                  fontWeight: FontWeight.w600, color: AppColors.ink)),
                            if (widget.isNow && !isDone) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.color.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Now',
                                    style: TextStyle(fontFamily: 'Sora',
                                        fontSize: 10, fontWeight: FontWeight.w600,
                                        color: widget.color)),
                              ),
                            ],
                            if (widget.tag.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(widget.tag,
                                  style: TextStyle(fontFamily: 'Sora',
                                      fontSize: 10, color: widget.color,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('4-week avg: ₹${widget.avg.toStringAsFixed(0)}',
                            style: AppText.small),
                      ],
                    ),
                  ),
                  if (isDone)
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${widget.submitted!.earnings.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'Sora', fontSize: 15,
                                  fontWeight: FontWeight.w700, color: AppColors.success)),
                            Text('${widget.submitted!.deliveries} orders',
                                style: AppText.small),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 20),
                      ],
                    )
                  else
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.add_rounded,
                      color: AppColors.inkLight, size: 20,
                    ),
                ],
              ),
            ),
          ),

          // Expandable input
          if (_expanded && !isDone)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: widget.earnCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Earnings (₹)',
                            hintText: '${widget.avg.toStringAsFixed(0)}',
                            prefixText: '₹ ',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: widget.delCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Orders',
                            hintText: '0',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.isSaving ? null : widget.onSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: widget.isSaving
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save slot'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}