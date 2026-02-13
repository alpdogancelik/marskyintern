import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'activity_controller.dart';
import '../widgets/report_download_sheet.dart';
import '../widgets/transaction_receipt_card.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityTransactionProvider(transactionId));

    return AppScaffold(
      child: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.space4),
                  PrimaryButton(
                    label: 'Retry',
                    onPressed: () => ref
                        .invalidate(activityTransactionProvider(transactionId)),
                  ),
                ],
              ),
            ),
          ),
          data: (transaction) {
            if (transaction == null) {
              return Center(
                child: AppCard(
                  child: Text(
                    'Transaction not found.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTopBar(
                  leading: IconButton(
                    tooltip: 'Back',
                    constraints: const BoxConstraints.tightFor(
                      width: AppTokens.minTapTarget,
                      height: AppTokens.minTapTarget,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  title: 'Details',
                  trailing: IconButton(
                    onPressed: () => showDownloadReportSheet(context),
                    tooltip: 'Download report',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      minimumSize: const Size(44, 44),
                    ),
                    icon: const Icon(Icons.download_rounded),
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TransactionReceiptCard(transaction: transaction),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                PrimaryButton(
                  label: 'Download',
                  onPressed: () => showDownloadReportSheet(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
