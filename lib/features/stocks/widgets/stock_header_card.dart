import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/trend_chip.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/stock.dart';

class StockHeaderCard extends StatelessWidget {
  const StockHeaderCard({
    super.key,
    required this.stock,
    this.darkVariant = false,
    this.onBuyTap,
    this.onSellTap,
    this.onExchangeTap,
  });

  final Stock stock;
  final bool darkVariant;
  final VoidCallback? onBuyTap;
  final VoidCallback? onSellTap;
  final VoidCallback? onExchangeTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = darkVariant ? Colors.white : colors.onSurface;
    final subtitle = darkVariant
        ? Colors.white.withValues(alpha: 0.72)
        : colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppTokens.space5),
      decoration: BoxDecoration(
        color: darkVariant ? const Color(0xFF0F1430) : colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        border: Border.all(
          color: darkVariant
              ? Colors.white.withValues(alpha: 0.08)
              : colors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: darkVariant ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${stock.name} (${stock.symbol})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: subtitle,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          Text(
            '\$${stock.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          TrendChip(change: stock.changePercent, compact: false),
          const SizedBox(height: AppTokens.space4),
          Row(
            children: [
              _HeaderAction(
                label: 'Buy',
                iconName: 'buying-bitcoin',
                onTap: onBuyTap,
                darkVariant: darkVariant,
              ),
              const SizedBox(width: AppTokens.space2),
              _HeaderAction(
                label: 'Sell',
                iconName: 'cash',
                onTap: onSellTap,
                darkVariant: darkVariant,
              ),
              const SizedBox(width: AppTokens.space2),
              _HeaderAction(
                label: 'Exchange',
                iconName: 'exchange',
                onTap: onExchangeTap,
                darkVariant: darkVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.iconName,
    required this.onTap,
    required this.darkVariant,
  });

  final String label;
  final String iconName;
  final VoidCallback? onTap;
  final bool darkVariant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            color: darkVariant
                ? Colors.white.withValues(alpha: 0.08)
                : colors.surfaceContainerLow,
          ),
          child: Column(
            children: [
              AppIcon(
                name: iconName,
                semanticLabel: label,
                size: 20,
                tone: darkVariant
                    ? AppIconTone.defaultTone
                    : AppIconTone.secondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          darkVariant ? Colors.white : colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
