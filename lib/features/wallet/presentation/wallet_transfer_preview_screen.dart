import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/wallet_fee_calculator.dart';
import 'wallet_controller.dart';
import '../widgets/preview_receipt_card.dart';
import '../widgets/wallet_flow_scaffold.dart';
import '../widgets/wallet_formatters.dart';

class WalletTransferPreviewScreen extends ConsumerWidget {
  const WalletTransferPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);
    final amount = state.transferAmount;
    final recipient = state.selectedRecipient;
    final fee = WalletFeeCalculator.transferFee(amount);
    final totalDebit = amount + fee;

    final transferId =
        'TX${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    return WalletFlowScaffold(
      title: 'Transfer Preview',
      bottomCtaLabel: 'Transfer Now',
      ctaLoading: state.isSubmitting,
      onBottomCtaPressed: amount <= 0 || recipient == null
          ? null
          : () async {
              final ok = await ref
                  .read(walletControllerProvider.notifier)
                  .submitTransfer();
              if (ok && context.mounted) {
                context.go('/wallet/transfer/success');
              }
            },
      body: PreviewReceiptCard(
        title: 'Transfer',
        amountText: formatUsd(amount),
        fields: [
          PreviewReceiptField(label: 'Transfer ID', value: transferId),
          PreviewReceiptField(
              label: 'Recipient', value: recipient?.name ?? '-'),
          PreviewReceiptField(label: 'Transfer fee', value: formatUsd(fee)),
          PreviewReceiptField(label: 'Time', value: formatTime(DateTime.now())),
        ],
        totalText: formatUsd(totalDebit),
      ),
    );
  }
}
