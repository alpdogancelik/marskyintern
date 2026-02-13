import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'wallet_controller.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/wallet_flow_scaffold.dart';

class WalletTopupMethodScreen extends ConsumerWidget {
  const WalletTopupMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);

    return WalletFlowScaffold(
      title: 'Deposit Method',
      bottomCtaLabel: 'Confirm',
      onBottomCtaPressed: state.selectedDepositMethodId == null
          ? null
          : () => context.push('/wallet/topup/preview'),
      body: PaymentMethodSelector(
        methods: state.paymentMethods,
        selectedId: state.selectedDepositMethodId,
        onSelect: (id) =>
            ref.read(walletControllerProvider.notifier).setDepositMethod(id),
      ),
    );
  }
}
