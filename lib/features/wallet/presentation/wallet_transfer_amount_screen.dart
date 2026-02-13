import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'wallet_controller.dart';
import '../widgets/amount_input_panel.dart';
import '../widgets/wallet_flow_scaffold.dart';
import '../widgets/wallet_formatters.dart';

class WalletTransferAmountScreen extends ConsumerWidget {
  const WalletTransferAmountScreen({super.key});

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
      title: 'Transfer USD',
      bottomCtaLabel: 'Transfer Preview',
      onBottomCtaPressed: state.transferAmount > 0
          ? () => context.push('/wallet/transfer/recipients')
          : null,
      body: AmountInputPanel(
        title: 'Transfer Balance',
        amountText: formatUsd(state.transferAmount),
        subtitle: 'Transfer from USD wallet',
        onKeyTap: (key) =>
            ref.read(walletControllerProvider.notifier).appendTransferKey(key),
        onBackspace: () =>
            ref.read(walletControllerProvider.notifier).backspaceTransfer(),
      ),
    );
  }
}
