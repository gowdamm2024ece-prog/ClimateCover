// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/policy/plan_select_screen.dart';
import '../screens/policy/policy_detail_screen.dart';
import '../screens/slots/slot_entry_screen.dart';
import '../screens/claims/claim_history_screen.dart';
import '../screens/claims/claim_detail_screen.dart';
import '../screens/home/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AadhaarEntryScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/plans',
        builder: (context, state) => const PlanSelectScreen(),
      ),
      GoRoute(
        path: '/claims/:id',
        builder: (context, state) => ClaimDetailScreen(
          claimId: state.pathParameters['id']!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/slots',
            builder: (context, state) => const SlotEntryScreen(),
          ),
          GoRoute(
            path: '/claims',
            builder: (context, state) => const ClaimHistoryScreen(),
          ),
          GoRoute(
            path: '/policy',
            builder: (context, state) => const PolicyDetailScreen(),
          ),
        ],
      ),
    ],
  );
});