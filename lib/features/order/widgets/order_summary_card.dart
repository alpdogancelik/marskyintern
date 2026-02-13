import 'package:flutter/material.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/order_summary.dart';
import 'order_formatters.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.summary,
  });

  final OrderSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order summary',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          _SummaryLine(label: 'Subtotal', value: formatUsd(summary.subtotal)),
          const SizedBox(height: AppTokens.space2),
          _SummaryLine(label: 'Fees', value: formatUsd(summary.fees)),
          const SizedBox(height: AppTokens.space2),
          _SummaryLine(
            label: 'Discount',
            value: summary.discount > 0
                ? '-${formatUsd(summary.discount).replaceFirst('\$', '')}'
                : formatUsd(0),
            valueColor: summary.discount > 0
                ? const Color(0xFF10A764)
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: AppTokens.space3),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppTokens.space3),
          _SummaryLine(
            label: 'Total buy',
            value: formatUsd(summary.total),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = emphasize
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            )
        : Theme.of(context).textTheme.bodyMedium;
    final valueStyle = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor,
            )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            );

    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Text(value, style: valueStyle),
      ],
    );
  }
}
