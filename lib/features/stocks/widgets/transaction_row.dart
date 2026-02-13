import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/stock_transaction.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
  });

  final StockTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPositive = transaction.type == StockTransactionType.deposit ||
        transaction.type == StockTransactionType.sell;
    final valueColor = isPositive ? const Color(0xFF10A966) : colors.onSurface;

    return Container(
      padding: const EdgeInsets.all(AppTokens.space3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          _TransactionIcon(type: transaction.type),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.status == StockTransactionStatus.completed
                      ? 'Completed'
                      : 'Pending',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}\$${transaction.value.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.symbol,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({
    required this.type,
  });

  final StockTransactionType type;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (type) {
      StockTransactionType.buy => ('buying-bitcoin', 'Buy'),
      StockTransactionType.sell => ('cash', 'Sell'),
      StockTransactionType.deposit => ('wallet', 'Deposit'),
      StockTransactionType.exchange => ('exchange', 'Exchange'),
    };

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppIcon(
          name: icon,
          semanticLabel: label,
          size: 20,
        ),
      ),
    );
  }
}
