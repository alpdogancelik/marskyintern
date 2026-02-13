import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/promo_code.dart';

class PromoRow extends StatelessWidget {
  const PromoRow({
    super.key,
    required this.promo,
    required this.onTap,
  });

  final PromoCode? promo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            child: const Center(
              child: AppIcon(
                name: 'discount',
                semanticLabel: 'Promo icon',
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: promo == null
                ? Text(
                    'Promo code',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo!.code,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        promo!.title,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(promo == null ? 'Add code' : 'Change'),
          ),
        ],
      ),
    );
  }
}
