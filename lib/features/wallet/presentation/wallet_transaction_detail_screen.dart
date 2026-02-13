import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/kit/ui_kit.dart';
import '../domain/entities/wallet_transaction.dart';
import 'wallet_controller.dart';
import '../widgets/preview_receipt_card.dart';
import '../widgets/wallet_flow_scaffold.dart';
import '../widgets/wallet_formatters.dart';

class WalletTransactionDetailScreen extends ConsumerWidget {
  const WalletTransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<WalletTransaction?>(
      future: ref
          .read(walletControllerProvider.notifier)
          .getTransactionById(transactionId),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return const WalletFlowScaffold(
            title: 'Details',
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tx = snapshot.data;
        if (tx == null) {
          return WalletFlowScaffold(
            title: 'Details',
            body: AppCard(
              child: Text(
                'Transaction not found.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        return WalletFlowScaffold(
          title: 'Details',
          bottomCtaLabel: 'Download',
          onBottomCtaPressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Download coming soon')),
              );
          },
          body: PreviewReceiptCard(
            title: _label(tx.type),
            amountText: formatUsd(tx.amount),
            fields: [
              PreviewReceiptField(
                  label: 'Reference', value: tx.id.toUpperCase()),
              PreviewReceiptField(
                  label: 'Payment',
                  value: tx.methodTitle ?? tx.counterparty ?? '-'),
              PreviewReceiptField(label: 'Fee', value: formatUsd(tx.fee)),
              PreviewReceiptField(
                label: 'Date/time',
                value:
                    '${formatDayLabel(tx.timestamp)} ${formatTime(tx.timestamp)}',
              ),
              PreviewReceiptField(label: 'Status', value: _status(tx.status)),
            ],
            totalText: formatUsd(tx.amount + tx.fee),
          ),
        );
      },
    );
  }

  String _label(WalletTransactionType type) {
    return switch (type) {
      WalletTransactionType.deposit => 'Deposit Receipt',
      WalletTransactionType.withdraw => 'Withdraw Receipt',
      WalletTransactionType.transfer => 'Transfer Receipt',
    };
  }

  String _status(WalletTransactionStatus status) {
    return switch (status) {
      WalletTransactionStatus.completed => 'Completed',
      WalletTransactionStatus.pending => 'Pending',
      WalletTransactionStatus.failed => 'Failed',
    };
  }
}
