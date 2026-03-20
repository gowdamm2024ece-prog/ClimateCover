// lib/models/claim.dart

class SlotPayout {
  final String slotTime;
  final double amount;
  const SlotPayout({required this.slotTime, required this.amount});
}

class Claim {
  final String id;
  final String disruptionType;
  final String disruptionCity;
  final String status;
  final DateTime triggeredAt;
  final DateTime? paidAt;
  final double protectedHours;
  final double calculatedPayout;
  final double? finalPayout;
  final double? fraudScore;
  final List<SlotPayout> slotBreakdown;

  const Claim({
    required this.id,
    required this.disruptionType,
    required this.disruptionCity,
    required this.status,
    required this.triggeredAt,
    this.paidAt,
    required this.protectedHours,
    required this.calculatedPayout,
    this.finalPayout,
    this.fraudScore,
    required this.slotBreakdown,
  });

  bool get isPaid       => status == 'paid';
  bool get isEvaluating => status == 'evaluating' || status == 'triggered';

  String get disruptionLabel {
    switch (disruptionType) {
      case 'heavy_rain':   return 'Heavy Rain';
      case 'flood':        return 'Flood Alert';
      case 'severe_aqi':  return 'Severe Pollution';
      case 'extreme_heat': return 'Extreme Heat';
      default:             return disruptionType;
    }
  }

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
    id:               json['id'],
    disruptionType:   json['disruption_type'],
    disruptionCity:   json['disruption_city'],
    status:           json['status'],
    triggeredAt:      DateTime.parse(json['triggered_at']),
    paidAt:           json['paid_at'] != null
                          ? DateTime.parse(json['paid_at'])
                          : null,
    protectedHours:   (json['protected_hours']).toDouble(),
    calculatedPayout: (json['calculated_payout']).toDouble(),
    finalPayout:      json['final_payout']?.toDouble(),
    fraudScore:       json['fraud_score']?.toDouble(),
    slotBreakdown:    (json['slot_breakdown'] as List? ?? [])
                          .map((s) => SlotPayout(
                                slotTime: s['slot'],
                                amount: (s['amount']).toDouble(),
                              ))
                          .toList(),
  );
}