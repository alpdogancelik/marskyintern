import 'package:flutter/material.dart';

class AppTokens {
  const AppTokens._();

  // Color system
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF111C2E);
  static const Color darkBorder = Color(0xFF243248);
  static const Color lightBackground = Color(0xFFF4F7FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFEF4444);
  static const Color mutedLabel = Color(0xFF64748B);

  // Backward-compatible aliases
  static const Color primary = primaryBlue;
  static const Color textStrong = Color(0xFF0F172A);
  static const Color textMuted = mutedLabel;
  static const Color lightSurface = lightCard;

  // Spacing system
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  static const double sectionGapSm = 12;
  static const double sectionGapMd = 16;
  static const double sectionGapLg = 24;

  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusCard = 16;
  static const double radiusPill = 999;

  static const double buttonHeight = 50;
  static const double socialButtonHeight = 50;
  static const double minTapTarget = 44;
  static const double pageHorizontalPadding = 16;
}
