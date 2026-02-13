import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/theme/app_tokens.dart';
import 'order_controller.dart';
import '../widgets/asset_order_header_card.dart';
import '../widgets/order_scaffold.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_method_row.dart';
import '../widgets/promo_row.dart';

class OrderConfirmScreen extends ConsumerWidget {
  const OrderConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderControllerProvider);

    return OrderScaffold(
      title: 'Order Preview',
      ctaLabel: 'Buy Now',
      ctaLoading: state.isSubmitting,
      onCtaPressed: state.canPreview
          ? () async {
              final ok = await ref
                  .read(orderControllerProvider.notifier)
                  .submitOrder();
              if (ok && context.mounted) {
                context.go('/order/success');
              }
            }
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrderHeaderCard(
            symbol: state.symbol,
            name: state.name,
            unitPrice: state.unitPrice,
          ),
          const SizedBox(height: AppTokens.space4),
          OrderSummaryCard(summary: state.summary),
          const SizedBox(height: AppTokens.space4),
          PaymentMethodRow(
            method: state.selectedPaymentMethod,
            onChange: () => context.push('/order/payment-method'),
          ),
          const SizedBox(height: AppTokens.space4),
          PromoRow(
            promo: state.appliedPromo,
            onTap: () => context.push('/order/promo'),
          ),
        ],
      ),
    );
  }
}
