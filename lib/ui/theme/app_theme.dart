import 'package:flutter/material.dart';

import 'app_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppTokens.primary,
      onPrimary: Colors.white,
      secondary: AppTokens.primary,
      onSecondary: Colors.white,
      error: const Color(0xFFBC1535),
      onError: Colors.white,
      surface: isDark ? const Color(0xFF1D1E2B) : AppTokens.lightSurface,
      onSurface: isDark ? const Color(0xFFF1F2FB) : AppTokens.textStrong,
      surfaceContainerHighest:
          isDark ? const Color(0xFF2A2C3E) : const Color(0xFFEFF1F8),
      surfaceContainerHigh:
          isDark ? const Color(0xFF252638) : const Color(0xFFF4F6FC),
      surfaceContainerLow:
          isDark ? const Color(0xFF1F2030) : const Color(0xFFF9FAFF),
      surfaceContainerLowest:
          isDark ? const Color(0xFF141521) : AppTokens.lightBackground,
      onSurfaceVariant:
          isDark ? const Color(0xFFB5B9D0) : const Color(0xFF6C7086),
      outline: isDark ? const Color(0xFF3C3F56) : AppTokens.lightBorder,
      outlineVariant:
          isDark ? const Color(0xFF31344A) : const Color(0xFFE8EAF3),
      inverseSurface: isDark ? Colors.white : const Color(0xFF1E2030),
      onInverseSurface: isDark ? const Color(0xFF151726) : Colors.white,
      inversePrimary:
          isDark ? const Color(0xFFB6A8FF) : const Color(0xFF3D2B9B),
      tertiary: isDark ? const Color(0xFF96B4FF) : const Color(0xFF4E75DB),
      onTertiary: isDark ? const Color(0xFF0B1A43) : Colors.white,
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
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: scheme.onSurface,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.45,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
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
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
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
