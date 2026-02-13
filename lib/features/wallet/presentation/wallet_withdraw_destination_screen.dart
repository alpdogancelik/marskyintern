import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'wallet_controller.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/wallet_flow_scaffold.dart';

class WalletWithdrawDestinationScreen extends ConsumerWidget {
  const WalletWithdrawDestinationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);

    return WalletFlowScaffold(
      title: 'Withdraw Destination',
      bottomCtaLabel: 'Confirm',
      onBottomCtaPressed: state.selectedWithdrawMethodId == null
          ? null
          : () => context.push('/wallet/withdraw/preview'),
      body: PaymentMethodSelector(
        methods: state.paymentMethods,
        selectedId: state.selectedWithdrawMethodId,
        onSelect: (id) =>
            ref.read(walletControllerProvider.notifier).setWithdrawMethod(id),
      ),
    );
  }
}
