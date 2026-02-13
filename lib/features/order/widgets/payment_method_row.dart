import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/payment_method.dart';

class PaymentMethodRow extends StatelessWidget {
  const PaymentMethodRow({
    super.key,
    required this.method,
    required this.onChange,
  });

  final PaymentMethod? method;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final selected = method;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Center(
              child: AppIcon(
                name: selected?.iconName ?? 'wallet',
                semanticLabel: 'Payment method icon',
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: selected == null
                ? Text(
                    'No payment method selected',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selected.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
