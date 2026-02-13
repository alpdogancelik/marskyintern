import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/wallet_fee_calculator.dart';
import 'wallet_controller.dart';
import '../widgets/preview_receipt_card.dart';
import '../widgets/wallet_flow_scaffold.dart';
import '../widgets/wallet_formatters.dart';

class WalletWithdrawPreviewScreen extends ConsumerWidget {
  const WalletWithdrawPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);
    final amount = state.withdrawAmount;
    final fee = WalletFeeCalculator.withdrawFee(amount);
    final method = state.selectedWithdrawMethod;
    final totalDebit = amount + fee;

    return WalletFlowScaffold(
      title: 'Withdraw Preview',
      bottomCtaLabel: 'Withdraw Now',
      ctaLoading: state.isSubmitting,
      onBottomCtaPressed: amount <= 0 || method == null
          ? null
          : () async {
              final ok = await ref
                  .read(walletControllerProvider.notifier)
                  .submitWithdraw();
              if (ok && context.mounted) {
                context.go('/wallet/withdraw/success');
              }
            },
      body: PreviewReceiptCard(
        title: 'Withdraw',
        amountText: formatUsd(amount),
        fields: [
          const PreviewReceiptField(
              label: 'Withdraw from', value: 'USD Wallet'),
          PreviewReceiptField(
              label: 'Destination', value: method?.title ?? '-'),
          PreviewReceiptField(label: 'Withdraw fee', value: formatUsd(fee)),
          PreviewReceiptField(label: 'Time', value: formatTime(DateTime.now())),
        ],
        totalText: formatUsd(totalDebit),
      ),
    );
  }
}
