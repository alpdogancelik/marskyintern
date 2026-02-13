import 'package:flutter/material.dart';

import '../../../ui/kit/trend_chip.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/portfolio_summary.dart';
import 'portfolio_formatters.dart';

class PortfolioValueHeroCard extends StatelessWidget {
  const PortfolioValueHeroCard({
    super.key,
    required this.summary,
  });

  final PortfolioSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF101B47),
            const Color(0xFF1F2C64),
            colors.primary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total asset value',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            formatUsd(summary.totalValue),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          Row(
            children: [
              TrendChip(change: summary.totalPnLPercent, compact: false),
              const SizedBox(width: AppTokens.space2),
              Text(
                summary.totalPnL >= 0
                    ? '+${formatUsd(summary.totalPnL)}'
                    : formatUsd(summary.totalPnL),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          const _MiniBars(),
        ],
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars();

  @override
  Widget build(BuildContext context) {
    final bars = [12.0, 24.0, 18.0, 34.0, 28.0, 16.0, 22.0];
    return Row(
      children: bars
          .map(
            (value) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  height: value,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
