// lib/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worker.dart';
import '../models/policy.dart';
import '../models/earning_slot.dart';
import '../models/claim.dart';
import '../models/disruption.dart';
import '../core/mock_data.dart';

// ── Auth ──────────────────────────────────────────────────────────
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final Worker? worker;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.worker,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    Worker? worker,
    String? error,
  }) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        isLoading: isLoading ?? this.isLoading,
        worker: worker ?? this.worker,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: replace with fromJson(Map<String,dynamic> json) when backend ready
    // TODO: real API: final res = await ApiClient().post('/auth/login/', {'username': phone, 'password': password});
    state = state.copyWith(
      isLoading: false,
      isLoggedIn: true,
      worker: MockData.currentWorker,
    );
    return true;
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 1000));
    // TODO: real API: await ApiClient().post('/auth/register/', data);
    state = state.copyWith(
      isLoading: false,
      isLoggedIn: true,
      worker: MockData.currentWorker,
    );
    return true;
  }

  void logout() {
    // TODO: clear JWT from secure storage
    state = const AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

// ── Policy ────────────────────────────────────────────────────────
class PolicyState {
  final Policy? activePolicy;
  final List<InsurancePlan> plans;
  final bool isLoading;
  final double? quotedPremium;

  const PolicyState({
    this.activePolicy,
    this.plans = const [],
    this.isLoading = false,
    this.quotedPremium,
  });

  PolicyState copyWith({
    Policy? activePolicy,
    List<InsurancePlan>? plans,
    bool? isLoading,
    double? quotedPremium,
  }) =>
      PolicyState(
        activePolicy: activePolicy ?? this.activePolicy,
        plans: plans ?? this.plans,
        isLoading: isLoading ?? this.isLoading,
        quotedPremium: quotedPremium ?? this.quotedPremium,
      );
}

class PolicyNotifier extends StateNotifier<PolicyState> {
  PolicyNotifier() : super(const PolicyState());

  Future<void> loadPolicy() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: final res = await ApiClient().get('/policy/my-policy/');
    state = state.copyWith(
      isLoading: false,
      activePolicy: MockData.activePolicy,
    );
  }

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: final res = await ApiClient().get('/policy/plans/');
    state = state.copyWith(isLoading: false, plans: MockData.plans);
  }

  Future<double> getQuote(String planId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: final res = await ApiClient().post('/policy/pricing/', {'plan_id': planId});
    final plan = MockData.plans.firstWhere((p) => p.id == planId);
    final quote = plan.baseWeeklyPremium * 1.15;
    state = state.copyWith(quotedPremium: quote);
    return quote;
  }

  Future<bool> subscribe(String planId) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: await ApiClient().post('/policy/subscribe/', {'plan_id': planId});
    state = state.copyWith(
      isLoading: false,
      activePolicy: MockData.activePolicy,
    );
    return true;
  }
}

final policyProvider = StateNotifierProvider<PolicyNotifier, PolicyState>(
    (ref) => PolicyNotifier());

// ── Slots ─────────────────────────────────────────────────────────
class SlotState {
  final List<EarningSlot> slots;
  final bool isLoading;
  final bool isSaving;

  const SlotState({
    this.slots = const [],
    this.isLoading = false,
    this.isSaving = false,
  });

  SlotState copyWith({
    List<EarningSlot>? slots,
    bool? isLoading,
    bool? isSaving,
  }) =>
      SlotState(
        slots: slots ?? this.slots,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
      );

  double get totalEarnings =>
      slots.where((s) => s.submitted).fold(0, (sum, s) => sum + s.earnings);

  int get totalDeliveries =>
      slots.where((s) => s.submitted).fold(0, (sum, s) => sum + s.deliveries);
}

class SlotNotifier extends StateNotifier<SlotState> {
  SlotNotifier() : super(const SlotState());

  Future<void> loadToday() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: final res = await ApiClient().get('/slots/today/');
    state = state.copyWith(isLoading: false, slots: MockData.todaySlots);
  }

  Future<bool> submitSlot(
      String slotStart, double earnings, int deliveries) async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: await ApiClient().post('/slots/submit/', {...});
    final updated = state.slots.map((s) {
      if (s.slotStart == slotStart) {
        return EarningSlot(
          slotStart: slotStart,
          earnings: earnings,
          deliveries: deliveries,
          submitted: true,
        );
      }
      return s;
    }).toList();
    state = state.copyWith(isSaving: false, slots: updated);
    return true;
  }
}

final slotProvider =
    StateNotifierProvider<SlotNotifier, SlotState>((ref) => SlotNotifier());

// ── Claims ────────────────────────────────────────────────────────
class ClaimState {
  final List<Claim> claims;
  final bool isLoading;
  final DisruptionEvent? activeDisruption;

  const ClaimState({
    this.claims = const [],
    this.isLoading = false,
    this.activeDisruption,
  });

  ClaimState copyWith({
    List<Claim>? claims,
    bool? isLoading,
    DisruptionEvent? activeDisruption,
  }) =>
      ClaimState(
        claims: claims ?? this.claims,
        isLoading: isLoading ?? this.isLoading,
        activeDisruption: activeDisruption ?? this.activeDisruption,
      );

  double get totalCredited => claims
      .where((c) => c.isPaid)
      .fold(0, (sum, c) => sum + (c.finalPayout ?? 0));
}

class ClaimNotifier extends StateNotifier<ClaimState> {
  ClaimNotifier() : super(const ClaimState());

  Future<void> loadClaims() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: final res = await ApiClient().get('/claims/');
    state = state.copyWith(
      isLoading: false,
      claims: MockData.claims,
      activeDisruption: MockData.activeDisruption,
    );
  }

  // FIX: getById is on the notifier (not ClaimState)
  Claim? getById(String id) {
    try {
      return state.claims.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

final claimProvider = StateNotifierProvider<ClaimNotifier, ClaimState>(
    (ref) => ClaimNotifier());

// ── Dashboard ─────────────────────────────────────────────────────
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 700));
  // TODO: final res = await ApiClient().get('/dashboard/');
  return MockData.dashboardSummary;
});