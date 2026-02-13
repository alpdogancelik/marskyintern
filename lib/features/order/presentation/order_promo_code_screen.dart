import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/promo_code.dart';
import 'order_controller.dart';
import '../widgets/order_scaffold.dart';

class OrderPromoCodeScreen extends ConsumerStatefulWidget {
  const OrderPromoCodeScreen({super.key});

  @override
  ConsumerState<OrderPromoCodeScreen> createState() =>
      _OrderPromoCodeScreenState();
}

class _OrderPromoCodeScreenState extends ConsumerState<OrderPromoCodeScreen> {
  late final TextEditingController _promoController;

  @override
  void initState() {
    super.initState();
    _promoController = TextEditingController();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderControllerProvider);

    return OrderScaffold(
      title: 'Promo Code',
      ctaLabel: 'Apply',
      onCtaPressed: () => _applyAndReturn(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _promoController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _applyAndReturn(context),
            decoration: InputDecoration(
              hintText: 'Input code',
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
          if (state.promoError != null) ...[
            const SizedBox(height: AppTokens.space2),
            InlineErrorText(state.promoError!),
          ],
          const SizedBox(height: AppTokens.space5),
          Text(
            'Promo Available',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          ...state.availablePromos.map(
            (promo) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: _PromoTile(
                promo: promo,
                onApply: () {
                  ref.read(orderControllerProvider.notifier).applyPromo(promo);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyAndReturn(BuildContext context) {
    final ok = ref
        .read(orderControllerProvider.notifier)
        .applyPromoCode(_promoController.text);
    if (ok) {
      Navigator.of(context).pop();
    }
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({
    required this.promo,
    required this.onApply,
  });

  final PromoCode promo;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space3,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.primary.withValues(alpha: 0.12),
            child: const Icon(Icons.local_offer_outlined, size: 18),
          ),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.code,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  promo.title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onApply,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
