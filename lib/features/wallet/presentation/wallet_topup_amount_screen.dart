import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'wallet_controller.dart';
import '../widgets/amount_input_panel.dart';
import '../widgets/wallet_flow_scaffold.dart';
import '../widgets/wallet_formatters.dart';

class WalletTopupAmountScreen extends ConsumerWidget {
  const WalletTopupAmountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);

    ref.listen(walletControllerProvider.select((s) => s.errorMessage),
        (previous, next) {
      if (next == null || next == previous) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(next)));
      ref.read(walletControllerProvider.notifier).clearError();
    });

    return WalletFlowScaffold(
      title: 'Deposit',
      bottomCtaLabel: 'Deposit Preview',
      onBottomCtaPressed: state.depositAmount > 0
          ? () => context.push('/wallet/topup/method')
          : null,
      body: AmountInputPanel(
        title: 'Topup Balance',
        amountText: formatUsd(state.depositAmount),
        subtitle: 'Topup to your USD wallet',
        onKeyTap: (key) =>
            ref.read(walletControllerProvider.notifier).appendDepositKey(key),
        onBackspace: () =>
            ref.read(walletControllerProvider.notifier).backspaceDeposit(),
      ),
    );
  }
}
