// lib/core/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary       = Color(0xFF1A56DB);
  static const primaryDark   = Color(0xFF1241A8);
  static const primaryLight  = Color(0xFFEBF2FF);
  static const success       = Color(0xFF0E9F6E);
  static const successLight  = Color(0xFFDEF7EC);
  static const warning       = Color(0xFFE3A008);
  static const warningLight  = Color(0xFFFDF6B2);
  static const danger        = Color(0xFFE02424);
  static const dangerLight   = Color(0xFFFDE8E8);
  static const disruption    = Color(0xFFFF5A1F);
  static const disruptionLight = Color(0xFFFFF3EE);
  static const ink           = Color(0xFF111928);
  static const inkMid        = Color(0xFF374151);
  static const inkLight      = Color(0xFF6B7280);
  static const border        = Color(0xFFE5E7EB);
  static const surface       = Color(0xFFF9FAFB);
  static const white         = Color(0xFFFFFFFF);
  static const slotPeak      = Color(0xFFFF5A1F);
  static const slotHigh      = Color(0xFFE3A008);
  static const slotNormal    = Color(0xFF1A56DB);
  static const slotLow       = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Sora',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        surface: AppColors.white,
        onPrimary: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Sora',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      // FIX: CardTheme uses CardThemeData in Material3
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Sora',
          color: AppColors.inkLight,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Sora',
          color: AppColors.inkLight,
          fontSize: 14,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Sora', fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.ink),
        displayMedium: TextStyle(fontFamily: 'Sora', fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink),
        headlineLarge: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.ink),
        headlineMedium:TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
        titleLarge:    TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
        titleMedium:   TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
        bodyLarge:     TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.inkMid),
        bodyMedium:    TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.inkLight),
        labelLarge:    TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.inkLight),
      ),
    );
  }
}

class AppText {
  static const h1    = TextStyle(fontFamily: 'Sora', fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const h2    = TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const h3    = TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const body  = TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.inkMid);
  static const small = TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.inkLight);
  static const label = TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.inkLight);
  static const mono  = TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink);
}