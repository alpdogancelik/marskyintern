import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/wallet_fee_calculator.dart';
import 'wallet_controller.dart';
import '../widgets/preview_receipt_card.dart';
import '../widgets/wallet_flow_scaffold.dart';
import '../widgets/wallet_formatters.dart';

class WalletTopupPreviewScreen extends ConsumerWidget {
  const WalletTopupPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);
    final amount = state.depositAmount;
    final fee = WalletFeeCalculator.depositFee(amount);
    final method = state.selectedDepositMethod;
    final receiveAmount = amount - fee;

    return WalletFlowScaffold(
      title: 'Deposit Preview',
      bottomCtaLabel: 'Deposit Now',
      ctaLoading: state.isSubmitting,
      onBottomCtaPressed: amount <= 0 || method == null
          ? null
          : () async {
              final ok = await ref
                  .read(walletControllerProvider.notifier)
                  .submitDeposit();
              if (ok && context.mounted) {
                context.go('/wallet/topup/success');
              }
            },
      body: PreviewReceiptCard(
        title: 'Deposit',
        amountText: formatUsd(amount),
        fields: [
          const PreviewReceiptField(label: 'Deposit to', value: 'USD Wallet'),
          PreviewReceiptField(
              label: 'Deposit method', value: method?.title ?? '-'),
          PreviewReceiptField(label: 'Deposit fee', value: formatUsd(fee)),
          PreviewReceiptField(label: 'Time', value: formatTime(DateTime.now())),
        ],
        totalText: formatUsd(receiveAmount),
      ),
    );
  }
}
