import 'package:flutter/material.dart';

import '../../core/widgets/coin_logo.dart';

class CoinAvatar extends StatelessWidget {
  const CoinAvatar({
    super.key,
    required this.symbol,
    this.iconUrl,
    this.size = 32,
    this.semanticLabel,
  });

  final String symbol;
  final String? iconUrl;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surface,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: CoinLogo(
        symbol: symbol,
        iconUrl: iconUrl,
        size: size.clamp(20, 32),
        semanticLabel: semanticLabel ?? '$symbol coin avatar',
      ),
    );
  }
}
