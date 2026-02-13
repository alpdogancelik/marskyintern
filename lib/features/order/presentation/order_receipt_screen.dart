import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'order_controller.dart';
import '../widgets/order_formatters.dart';

class OrderReceiptScreen extends ConsumerWidget {
  const OrderReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderControllerProvider);

    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTopBar(
            leading: IconButton(
              tooltip: 'Back',
              constraints: const BoxConstraints.tightFor(
                width: AppTokens.minTapTarget,
                height: AppTokens.minTapTarget,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: 'Order Details',
          ),
          const SizedBox(height: AppTokens.space5),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Line(label: 'Asset', value: '${state.symbol} - ${state.name}'),
                const SizedBox(height: AppTokens.space2),
                _Line(label: 'Quantity', value: formatQuantity(state.quantity)),
                const SizedBox(height: AppTokens.space2),
                _Line(label: 'Unit price', value: formatUsd(state.unitPrice)),
                const SizedBox(height: AppTokens.space2),
                _Line(
                  label: 'Payment',
                  value: state.selectedPaymentMethod?.title ?? '-',
                ),
                const SizedBox(height: AppTokens.space2),
                _Line(
                  label: 'Promo',
                  value: state.appliedPromo?.code ?? 'No promo',
                ),
                const SizedBox(height: AppTokens.space3),
                Divider(color: Theme.of(context).colorScheme.outlineVariant),
                const SizedBox(height: AppTokens.space3),
                _Line(
                  label: 'Total',
                  value: formatUsd(state.summary.total),
                  strong: true,
                ),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Done',
            onPressed: () {
              ref.read(orderControllerProvider.notifier).clearOrder();
              context.go('/app/home');
            },
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            )
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
