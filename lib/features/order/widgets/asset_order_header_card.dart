import 'package:flutter/material.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'order_formatters.dart';

class AssetOrderHeaderCard extends StatelessWidget {
  const AssetOrderHeaderCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.unitPrice,
  });

  final String symbol;
  final String name;
  final double unitPrice;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Row(
        children: [
          CoinAvatar(symbol: symbol, size: 44),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            formatUsd(unitPrice),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
