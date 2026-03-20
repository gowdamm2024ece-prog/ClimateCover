// lib/models/earning_slot.dart
class EarningSlot {
  final String slotStart;
  final double earnings;
  final int deliveries;
  final bool submitted;

  const EarningSlot({
    required this.slotStart,
    required this.earnings,
    required this.deliveries,
    required this.submitted,
  });

  String get slotEnd {
    final h = int.parse(slotStart.split(':')[0]);
    return '${(h + 2).toString().padLeft(2, '0')}:00';
  }

  String get label => '$slotStart–$slotEnd';

  factory EarningSlot.fromJson(Map<String, dynamic> json) => EarningSlot(
    slotStart:  json['slot_start'],
    earnings:   (json['earnings']).toDouble(),
    deliveries: json['deliveries'],
    submitted:  true,
  );
}