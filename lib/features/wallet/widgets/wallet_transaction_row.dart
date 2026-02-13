import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/wallet_transaction.dart';
import 'wallet_formatters.dart';

class WalletTransactionRow extends StatelessWidget {
  const WalletTransactionRow({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final WalletTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final positive = transaction.type == WalletTransactionType.deposit;

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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Center(
                child: AppIcon(
                  name: _iconName(transaction.type),
                  semanticLabel: _label(transaction.type),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(transaction),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatTime(transaction.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTokens.space2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${positive ? '+' : '-'}${formatUsd(transaction.amount).replaceFirst('\$', '')}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: positive
                            ? const Color(0xFF159D62)
                            : const Color(0xFFCF314D),
                      ),
                ),
                const SizedBox(height: 4),
                _StatusChip(status: transaction.status),
              ],
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _title(WalletTransaction transaction) {
    final action = _label(transaction.type);
    final counterparty = transaction.counterparty;
    if (counterparty != null && counterparty.trim().isNotEmpty) {
      return '$action $counterparty';
    }
    if (transaction.methodTitle != null) {
      return '$action ${transaction.methodTitle}';
    }
    return action;
  }

  String _label(WalletTransactionType type) {
    return switch (type) {
      WalletTransactionType.deposit => 'Deposit',
      WalletTransactionType.withdraw => 'Withdraw',
      WalletTransactionType.transfer => 'Transfer',
    };
  }

  String _iconName(WalletTransactionType type) {
    return switch (type) {
      WalletTransactionType.deposit => 'wallet',
      WalletTransactionType.withdraw => 'bank',
      WalletTransactionType.transfer => 'money-transfer-between-wallets',
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final WalletTransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      WalletTransactionStatus.completed => (
          'Completed',
          const Color(0xFF159D62)
        ),
      WalletTransactionStatus.pending => ('Pending', const Color(0xFFB77E1F)),
      WalletTransactionStatus.failed => ('Failed', const Color(0xFFC9324D)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
