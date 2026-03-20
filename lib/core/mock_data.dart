// lib/core/mock_data.dart
// ALL mock data lives here. When backend is ready,
// replace each method with a real API call in the providers.

import '../models/worker.dart';
import '../models/policy.dart';
import '../models/earning_slot.dart';
import '../models/claim.dart';
import '../models/disruption.dart';

class MockData {
  // ── Worker ──────────────────────────────────────
  static Worker get currentWorker => Worker(
    id: 'w-001',
    firstName: 'Rahul',
    lastName: 'Kumar',
    phone: '9876543210',
    platform: 'Zomato',
    city: 'Mumbai',
    pincode: '400053',
    aadhaarVerified: true,
    upiId: 'rahul@upi',
    riskScore: 0.62,
    zoneRiskLevel: 'high',
    joinedAt: DateTime(2026, 2, 10),
  );

  // ── Plans ───────────────────────────────────────
  static List<InsurancePlan> get plans => [
    InsurancePlan(
      id: 'plan-1',
      name: 'Basic',
      baseWeeklyPremium: 49,
      maxCoverageHours: 4,
      maxWeeklyPayout: 400,
      description: 'Essential income protection for part-time workers',
    ),
    InsurancePlan(
      id: 'plan-2',
      name: 'Standard',
      baseWeeklyPremium: 79,
      maxCoverageHours: 8,
      maxWeeklyPayout: 800,
      description: 'Best for full-time delivery partners',
      isRecommended: true,
    ),
    InsurancePlan(
      id: 'plan-3',
      name: 'Premium',
      baseWeeklyPremium: 99,
      maxCoverageHours: 12,
      maxWeeklyPayout: 1200,
      description: 'Maximum protection for peak earners',
    ),
  ];

  // ── Active Policy ────────────────────────────────
  static Policy get activePolicy => Policy(
    id: 'pol-001',
    planName: 'Standard',
    basePremium: 79,
    riskAdjustment: 12,
    finalWeeklyPremium: 91,
    maxCoverageHours: 8,
    maxWeeklyPayout: 800,
    status: 'active',
    activationDate: DateTime(2026, 3, 1),
    currentWeekStart: DateTime(2026, 3, 17),
    currentWeekEnd: DateTime(2026, 3, 23),
    weeksPaid: 3,
    totalPremiumsPaid: 273,
    pricingFactors: {
      'city_risk': 1.30,
      'platform': 1.05,
      'ml_score': 0.95,
    },
  );

  // ── Today's Earning Slots ────────────────────────
  static List<EarningSlot> get todaySlots => [
    EarningSlot(slotStart: '06:00', earnings: 95, deliveries: 2, submitted: true),
    EarningSlot(slotStart: '08:00', earnings: 180, deliveries: 3, submitted: true),
    EarningSlot(slotStart: '10:00', earnings: 140, deliveries: 2, submitted: true),
    EarningSlot(slotStart: '12:00', earnings: 320, deliveries: 5, submitted: true),
    EarningSlot(slotStart: '14:00', earnings: 0, deliveries: 0, submitted: false),
    EarningSlot(slotStart: '16:00', earnings: 0, deliveries: 0, submitted: false),
    EarningSlot(slotStart: '18:00', earnings: 0, deliveries: 0, submitted: false),
    EarningSlot(slotStart: '20:00', earnings: 0, deliveries: 0, submitted: false),
  ];

  // ── Slot 4-week averages ─────────────────────────
  static Map<String, double> get slotAverages => {
    '06:00': 95,
    '08:00': 182,
    '10:00': 137,
    '12:00': 316,
    '14:00': 158,
    '16:00': 192,
    '18:00': 278,
    '20:00': 241,
  };

  // ── Active Disruption ────────────────────────────
  static DisruptionEvent? get activeDisruption => DisruptionEvent(
    id: 'dis-001',
    type: 'heavy_rain',
    severity: 'high',
    city: 'Mumbai',
    startedAt: DateTime(2026, 3, 19, 14, 0),
    endedAt: DateTime(2026, 3, 19, 20, 0),
    rainfallMm: 68.4,
    isActive: true,
  );

  // ── Claims ───────────────────────────────────────
  static List<Claim> get claims => [
    Claim(
      id: 'clm-001',
      disruptionType: 'heavy_rain',
      disruptionCity: 'Mumbai',
      status: 'paid',
      triggeredAt: DateTime(2026, 3, 19, 14, 10),
      paidAt: DateTime(2026, 3, 19, 14, 18),
      protectedHours: 6,
      calculatedPayout: 628,
      finalPayout: 628,
      fraudScore: 0.08,
      slotBreakdown: [
        SlotPayout(slotTime: '14:00–16:00', amount: 158),
        SlotPayout(slotTime: '16:00–18:00', amount: 192),
        SlotPayout(slotTime: '18:00–20:00', amount: 278),
      ],
    ),
    Claim(
      id: 'clm-002',
      disruptionType: 'severe_aqi',
      disruptionCity: 'Mumbai',
      status: 'paid',
      triggeredAt: DateTime(2026, 3, 10, 8, 0),
      paidAt: DateTime(2026, 3, 10, 8, 12),
      protectedHours: 4,
      calculatedPayout: 412,
      finalPayout: 412,
      fraudScore: 0.11,
      slotBreakdown: [
        SlotPayout(slotTime: '08:00–10:00', amount: 182),
        SlotPayout(slotTime: '10:00–12:00', amount: 137),
        SlotPayout(slotTime: '12:00–14:00', amount: 93),
      ],
    ),
    Claim(
      id: 'clm-003',
      disruptionType: 'heavy_rain',
      disruptionCity: 'Mumbai',
      status: 'evaluating',
      triggeredAt: DateTime(2026, 3, 19, 14, 10),
      protectedHours: 6,
      calculatedPayout: 628,
      finalPayout: null,
      fraudScore: null,
      slotBreakdown: [],
    ),
  ];

  // ── Dashboard summary ────────────────────────────
  static Map<String, dynamic> get dashboardSummary => {
    'total_hours_protected': 10.0,
    'total_amount_credited': 1040.0,
    'pending_premium': 0.0,
    'active_disruption': activeDisruption,
    'last_claim': claims.first,
  };

  // ── Slot label helper ────────────────────────────
  static String slotLabel(String start) {
    final hour = int.parse(start.split(':')[0]);
    final endHour = (hour + 2).toString().padLeft(2, '0');
    return '$start–$endHour:00';
  }

  static String slotCategory(String start) {
    final h = int.parse(start.split(':')[0]);
    if (h >= 12 && h <= 14) return 'peak';
    if (h >= 18 && h <= 20) return 'high';
    if (h >= 8 && h <= 10) return 'normal';
    return 'low';
  }
}