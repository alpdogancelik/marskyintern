import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'wallet_controller.dart';
import '../widgets/success_screen_template.dart';

class WalletWithdrawSuccessScreen extends ConsumerWidget {
  const WalletWithdrawSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(walletControllerProvider).lastCompletedTransaction;

    return SuccessScreenTemplate(
      title: 'Withdraw Successful',
      subtitle: 'Your withdrawal has been processed successfully.',
      primaryLabel: 'Show Details',
      onPrimary: tx == null ? () {} : () => context.push('/wallet/tx/${tx.id}'),
      secondaryLabel: 'Done',
      onSecondary: () {
        ref.read(walletControllerProvider.notifier).resetWithdrawFlow();
        context.go('/wallet');
      },
    );
  }
}
