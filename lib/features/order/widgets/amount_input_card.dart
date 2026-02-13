import 'package:flutter/material.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'order_formatters.dart';

class AmountInputCard extends StatelessWidget {
  const AmountInputCard({
    super.key,
    required this.controller,
    required this.symbol,
    required this.unitPrice,
    required this.onChanged,
    required this.onQuickPercent,
  });

  final TextEditingController controller;
  final String symbol;
  final double unitPrice;
  final ValueChanged<String> onChanged;
  final ValueChanged<int> onQuickPercent;

  @override
  Widget build(BuildContext context) {
    final quantity = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
    final fiat = quantity * unitPrice;

    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '$symbol  ',
              prefixStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space3),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [25, 50, 75, 100]
                .map(
                  (value) => AppChip(
                    label: '$value%',
                    onTap: () => onQuickPercent(value),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: AppTokens.space3),
          Text(
            'Estimated value: ${formatUsd(fiat)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
