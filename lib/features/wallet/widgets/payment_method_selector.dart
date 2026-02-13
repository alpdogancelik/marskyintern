import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/wallet_payment_method.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.methods,
    required this.selectedId,
    required this.onSelect,
  });

  final List<WalletPaymentMethod> methods;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final bankMethods = methods
        .where((m) => m.type == WalletPaymentMethodType.bankTransfer)
        .toList(growable: false);
    final cardMethods = methods
        .where((m) => m.type == WalletPaymentMethodType.card)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: 'Bank Transfer'),
        const SizedBox(height: AppTokens.space2),
        ...bankMethods.map(
          (method) => Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.space2),
            child: _MethodTile(
              method: method,
              selected: selectedId == method.id,
              onTap: () => onSelect(method.id),
            ),
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        _SectionTitle(label: 'Credit/Debit Card'),
        const SizedBox(height: AppTokens.space2),
        ...cardMethods.map(
          (method) => Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.space2),
            child: _MethodTile(
              method: method,
              selected: selectedId == method.id,
              onTap: () => onSelect(method.id),
            ),
          ),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final WalletPaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
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
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(99),
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
