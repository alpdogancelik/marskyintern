import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/payment_method.dart';
import 'order_controller.dart';
import '../widgets/order_scaffold.dart';

class OrderPaymentMethodScreen extends ConsumerWidget {
  const OrderPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderControllerProvider);
    final controller = ref.read(orderControllerProvider.notifier);

    return OrderScaffold(
      title: 'Payment Method',
      ctaLabel: 'Confirm',
      onCtaPressed: state.selectedPaymentMethod == null
          ? null
          : () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: 'Bank Transfer'),
          const SizedBox(height: AppTokens.space2),
          ..._methodsForType(
                  state.paymentMethods, PaymentMethodType.bankTransfer)
              .map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: _PaymentTile(
                method: method,
                selected: state.selectedPaymentMethod?.id == method.id,
                onTap: () => controller.selectPaymentMethod(method.id),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          _SectionTitle(label: 'Credit/Debit Card'),
          const SizedBox(height: AppTokens.space2),
          ..._methodsForType(state.paymentMethods, PaymentMethodType.card).map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: _PaymentTile(
                method: method,
                selected: state.selectedPaymentMethod?.id == method.id,
                onTap: () => controller.selectPaymentMethod(method.id),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          _SectionTitle(label: 'E-wallet'),
          const SizedBox(height: AppTokens.space2),
          ..._methodsForType(state.paymentMethods, PaymentMethodType.ewallet)
              .map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: _PaymentTile(
                method: method,
                selected: state.selectedPaymentMethod?.id == method.id,
                onTap: () => controller.selectPaymentMethod(method.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PaymentMethod> _methodsForType(
    List<PaymentMethod> all,
    PaymentMethodType type,
  ) {
    return all.where((item) => item.type == type).toList(growable: false);
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space3,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              child: Center(
                child: AppIcon(
                  name: method.iconName,
                  semanticLabel: method.title,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(method.subtitle),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? colors.primary : colors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
