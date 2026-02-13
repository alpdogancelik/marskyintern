import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'wallet_controller.dart';
import '../widgets/success_screen_template.dart';

class WalletTransferSuccessScreen extends ConsumerWidget {
  const WalletTransferSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(walletControllerProvider).lastCompletedTransaction;

    return SuccessScreenTemplate(
      title: 'Transfer Successful',
      subtitle: 'Your transfer has been completed successfully.',
      primaryLabel: 'Show Details',
      onPrimary: tx == null ? () {} : () => context.push('/wallet/tx/${tx.id}'),
      secondaryLabel: 'Done',
      onSecondary: () {
        ref.read(walletControllerProvider.notifier).resetTransferFlow();
        context.go('/wallet');
      },
    );
  }
}
