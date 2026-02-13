import 'package:flutter/material.dart';

import '../../kit/trend_chip.dart';
import '../../theme/app_tokens.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.totalValueText,
    required this.todayChange,
    this.onActionTap,
    this.onCardTap,
  });

  final String totalValueText;
  final double todayChange;
  final VoidCallback? onActionTap;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final card = Container(
      padding: const EdgeInsets.all(AppTokens.space5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF121E4A),
            const Color(0xFF212D66),
            colors.primary.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total asset value',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                ),
                const SizedBox(height: AppTokens.space3),
                Text(
                  totalValueText,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 33,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppTokens.space3),
                TrendChip(change: todayChange, compact: false),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onActionTap,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              foregroundColor: Colors.white,
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
          ),
        ],
      ),
    );

    if (onCardTap == null) {
      return card;
    }

    return Semantics(
      button: true,
      label: 'Open portfolio',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        onTap: onCardTap,
        child: card,
      ),
    );
  }
}
