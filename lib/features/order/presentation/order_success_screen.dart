import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'order_controller.dart';
import '../widgets/order_success_hero.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderControllerProvider);

    return AppScaffold(
      child: Column(
        children: [
          const Spacer(),
          OrderSuccessHero(
            quantity: state.quantity,
            symbol: state.symbol,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Show Details',
            onPressed: () => context.push('/order/receipt'),
          ),
          const SizedBox(height: AppTokens.space3),
          SecondaryButton(
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
