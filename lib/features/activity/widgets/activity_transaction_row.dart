import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/coin_avatar.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/activity_transaction.dart';
import 'activity_formatters.dart';

class ActivityTransactionRow extends StatelessWidget {
  const ActivityTransactionRow({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final ActivityTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPositive = transaction.type == ActivityType.buy ||
        transaction.type == ActivityType.deposit;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space3,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Center(
                child: AppIcon(
                  name: _iconName(transaction.type),
                  semanticLabel: transaction.actionLabel,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.space2),
            CoinAvatar(symbol: transaction.symbol, size: 24),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${transaction.actionLabel} ${transaction.symbol}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatCrypto(transaction.amountCrypto)} ${transaction.symbol} • ${timeLabel(transaction.timestamp)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTokens.space3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : '-'}${formatUsd(transaction.amountFiat).replaceFirst('\$', '')}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isPositive
                            ? const Color(0xFF159E62)
                            : const Color(0xFFCD324C),
                      ),
                ),
                const SizedBox(height: 4),
                _StatusChip(status: transaction.status),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _iconName(ActivityType type) {
    return switch (type) {
      ActivityType.buy => 'buying-bitcoin',
      ActivityType.sell => 'exchange',
      ActivityType.deposit => 'wallet',
      ActivityType.withdraw => 'money-transfer-between-wallets',
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ActivityStatus status;

  @override
  Widget build(BuildContext context) {
    final completed = status == ActivityStatus.completed;
    final foreground =
        completed ? const Color(0xFF159E62) : const Color(0xFFBC7A19);
    final background = completed
        ? const Color(0xFF159E62).withValues(alpha: 0.12)
        : const Color(0xFFBC7A19).withValues(alpha: 0.14);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        statusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
