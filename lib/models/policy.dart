// lib/models/policy.dart

class InsurancePlan {
  final String id;
  final String name;
  final double baseWeeklyPremium;
  final int maxCoverageHours;
  final double maxWeeklyPayout;
  final String description;
  final bool isRecommended;

  const InsurancePlan({
    required this.id,
    required this.name,
    required this.baseWeeklyPremium,
    required this.maxCoverageHours,
    required this.maxWeeklyPayout,
    required this.description,
    this.isRecommended = false,
  });

  factory InsurancePlan.fromJson(Map<String, dynamic> json) => InsurancePlan(
    id: json['id'].toString(),
    name: json['name'],
    baseWeeklyPremium: (json['base_weekly_premium']).toDouble(),
    maxCoverageHours: json['max_coverage_hours'],
    maxWeeklyPayout: (json['max_weekly_payout']).toDouble(),
    description: json['description'] ?? '',
  );
}

class Policy {
  final String id;
  final String planName;
  final double basePremium;
  final double riskAdjustment;
  final double finalWeeklyPremium;
  final int maxCoverageHours;
  final double maxWeeklyPayout;
  final String status;
  final DateTime activationDate;
  final DateTime currentWeekStart;
  final DateTime currentWeekEnd;
  final int weeksPaid;
  final double totalPremiumsPaid;
  final Map<String, dynamic> pricingFactors;

  const Policy({
    required this.id,
    required this.planName,
    required this.basePremium,
    required this.riskAdjustment,
    required this.finalWeeklyPremium,
    required this.maxCoverageHours,
    required this.maxWeeklyPayout,
    required this.status,
    required this.activationDate,
    required this.currentWeekStart,
    required this.currentWeekEnd,
    required this.weeksPaid,
    required this.totalPremiumsPaid,
    required this.pricingFactors,
  });

  bool get isActive => status == 'active';

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
    id: json['id'],
    planName: json['plan_name'],
    basePremium: (json['base_premium']).toDouble(),
    riskAdjustment: (json['risk_adjustment']).toDouble(),
    finalWeeklyPremium: (json['final_weekly_premium']).toDouble(),
    maxCoverageHours: json['max_coverage_hours'],
    maxWeeklyPayout: (json['max_weekly_payout']).toDouble(),
    status: json['status'],
    activationDate: DateTime.parse(json['activation_date']),
    currentWeekStart: DateTime.parse(json['current_week_start']),
    currentWeekEnd: DateTime.parse(json['current_week_end']),
    weeksPaid: json['weeks_paid'],
    totalPremiumsPaid: (json['total_premiums_paid']).toDouble(),
    pricingFactors: json['pricing_factors'] ?? {},
  );
}