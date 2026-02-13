import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/order_status.dart';
import 'order_controller.dart';
import '../widgets/amount_input_card.dart';
import '../widgets/asset_order_header_card.dart';
import '../widgets/order_formatters.dart';
import '../widgets/order_scaffold.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_method_row.dart';

class OrderCryptoScreen extends ConsumerStatefulWidget {
  const OrderCryptoScreen({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  ConsumerState<OrderCryptoScreen> createState() => _OrderCryptoScreenState();
}

class _OrderCryptoScreenState extends ConsumerState<OrderCryptoScreen> {
  late final TextEditingController _amountController;
  bool _updatingText = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref
          .read(orderControllerProvider.notifier)
          .startCryptoOrder(symbol: widget.symbol);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(orderControllerProvider, (previous, next) {
      final previousQty = previous?.quantity;
      if (previousQty != next.quantity) {
        final nextText =
            next.quantity <= 0 ? '' : formatQuantity(next.quantity);
        if (_amountController.text != nextText) {
          _updatingText = true;
          _amountController.value = TextEditingValue(
            text: nextText,
            selection: TextSelection.collapsed(offset: nextText.length),
          );
          _updatingText = false;
        }
      }

      final previousError = previous?.errorMessage;
      if (next.errorMessage != null && next.errorMessage != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final state = ref.watch(orderControllerProvider);
    final symbol = state.symbol.isNotEmpty ? state.symbol : widget.symbol;

    return OrderScaffold(
      title: 'Order Crypto',
      ctaLabel: 'Preview Buy',
      onCtaPressed:
          state.canPreview ? () => context.push('/order/confirm') : null,
      ctaLoading: state.status == OrderStatus.pending,
      body: state.isInitializing && !state.hasAsset
          ? const _OrderCryptoLoading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssetOrderHeaderCard(
                  symbol: symbol,
                  name: state.name.isEmpty ? symbol : state.name,
                  unitPrice: state.unitPrice,
                ),
                const SizedBox(height: AppTokens.space4),
                AmountInputCard(
                  controller: _amountController,
                  symbol: symbol,
                  unitPrice: state.unitPrice,
                  onChanged: (value) {
                    if (_updatingText) {
                      return;
                    }
                    ref
                        .read(orderControllerProvider.notifier)
                        .setQuantityFromInput(value);
                  },
                  onQuickPercent: (value) {
                    ref
                        .read(orderControllerProvider.notifier)
                        .setQuantityByPercent(value);
                  },
                ),
                const SizedBox(height: AppTokens.space4),
                PaymentMethodRow(
                  method: state.selectedPaymentMethod,
                  onChange: () => context.push('/order/payment-method'),
                ),
                const SizedBox(height: AppTokens.space4),
                OrderSummaryCard(summary: state.summary),
              ],
            ),
    );
  }
}

class _OrderCryptoLoading extends StatelessWidget {
  const _OrderCryptoLoading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      children: [
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.space4),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppTokens.radiusXl),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
