import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/theme/app_tokens.dart';
import 'order_formatters.dart';

class OrderSuccessHero extends StatelessWidget {
  const OrderSuccessHero({
    super.key,
    required this.quantity,
    required this.symbol,
  });

  final double quantity;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.1),
          ),
          child: Center(
            child: AppIcon(
              name: 'check-mark',
              semanticLabel: 'Order success',
              size: 24,
              tone: AppIconTone.defaultTone,
            ),
          ),
        ),
        const SizedBox(height: AppTokens.space5),
        Text(
          'Successfully purchased',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTokens.space2),
        Text(
          '${formatQuantity(quantity)} $symbol',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
