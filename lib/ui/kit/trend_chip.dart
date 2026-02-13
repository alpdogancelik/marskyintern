import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class TrendChip extends StatelessWidget {
  const TrendChip({
    super.key,
    required this.change,
    this.compact = true,
  });

  final double change;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final text = '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%';
    final background = isPositive
        ? const Color(0xFF13B86F).withValues(alpha: 0.12)
        : const Color(0xFFDA3A56).withValues(alpha: 0.12);
    final foreground =
        isPositive ? const Color(0xFF0C9E5D) : const Color(0xFFC9304A);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppTokens.space2 : AppTokens.space3,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 11 : 12,
        ),
      ),
    );
  }
}
