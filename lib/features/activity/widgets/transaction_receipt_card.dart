import 'package:flutter/material.dart';

import '../../../ui/kit/app_card.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/activity_transaction.dart';
import 'activity_formatters.dart';

class TransactionReceiptCard extends StatelessWidget {
  const TransactionReceiptCard({
    super.key,
    required this.transaction,
  });

  final ActivityTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final unitPrice = transaction.amountCrypto <= 0
        ? 0.0
        : transaction.amountFiat / transaction.amountCrypto;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${transaction.actionLabel} ${transaction.symbol}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            '${formatCrypto(transaction.amountCrypto)} ${transaction.symbol}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            formatUsd(transaction.amountFiat),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.space4),
          _ReceiptLine(
              label: 'Reference code', value: transaction.id.toUpperCase()),
          _ReceiptLine(label: 'Price per coin', value: formatUsd(unitPrice)),
          _ReceiptLine(label: 'Network fee', value: formatUsd(transaction.fee)),
          const _ReceiptLine(label: 'Payment method', value: 'Bank Transfer'),
          _ReceiptLine(
            label: 'Date/time',
            value:
                '${dayLabel(transaction.timestamp)} ${timeLabel(transaction.timestamp)}',
          ),
          _ReceiptLine(
            label: 'Status',
            value: statusLabel(transaction.status),
            valueColor: transaction.status == ActivityStatus.completed
                ? const Color(0xFF129A5F)
                : const Color(0xFFB57B21),
          ),
        ],
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space2),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}
