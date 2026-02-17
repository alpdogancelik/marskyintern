import 'package:flutter/material.dart';

import 'app_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.primaryBlue,
      brightness: brightness,
    ).copyWith(
      primary: AppTokens.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppTokens.primaryBlue,
      onSecondary: Colors.white,
      error: AppTokens.danger,
      onError: Colors.white,
      surface: isDark ? AppTokens.darkCard : AppTokens.lightCard,
      onSurface: isDark ? const Color(0xFFE2E8F0) : AppTokens.textStrong,
      surfaceContainerHighest:
          isDark ? const Color(0xFF1C2A3E) : const Color(0xFFEDF2FA),
      surfaceContainerHigh:
          isDark ? const Color(0xFF162336) : AppTokens.lightCard,
      surfaceContainerLow:
          isDark ? const Color(0xFF132034) : const Color(0xFFF8FAFD),
      surfaceContainerLowest:
          isDark ? AppTokens.darkBackground : AppTokens.lightBackground,
      onSurfaceVariant: isDark ? const Color(0xFF94A3B8) : AppTokens.mutedLabel,
      outline: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
      outlineVariant:
          isDark ? const Color(0xFF1F2D44) : const Color(0xFFDAE3F0),
      inverseSurface: isDark ? Colors.white : const Color(0xFF0F172A),
      onInverseSurface: isDark ? const Color(0xFF0F172A) : Colors.white,
      inversePrimary:
          isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
      tertiary: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      onTertiary: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF152238) : Colors.white,
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space4,
          vertical: AppTokens.space3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
      ),
      iconTheme: IconThemeData(
        color: scheme.onSurface,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          letterSpacing: -0.3,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: scheme.onSurface,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          height: 1.45,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.45,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.4,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize:
              const Size(double.infinity, AppTokens.socialButtonHeight),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          foregroundColor: scheme.onSurface,
          backgroundColor: scheme.surface,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize:
              const Size(AppTokens.minTapTarget, AppTokens.minTapTarget),
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
