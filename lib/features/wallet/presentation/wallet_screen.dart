import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/wallet_transaction.dart';
import 'wallet_controller.dart';
import '../widgets/wallet_formatters.dart';
import '../widgets/wallet_hero_card.dart';
import '../widgets/wallet_transaction_row.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);

    if (state.isLoading) {
      return const _WalletLoadingView();
    }

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pageHorizontalPadding,
                AppTokens.space3,
                AppTokens.pageHorizontalPadding,
                AppTokens.space6,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
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
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      title: 'My Wallet',
                      trailing: IconButton(
                        tooltip: 'Open activity',
                        constraints: const BoxConstraints.tightFor(
                          width: AppTokens.minTapTarget,
                          height: AppTokens.minTapTarget,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        onPressed: () => context.push('/activity'),
                        icon: const Icon(Icons.receipt_long_rounded),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space5),
                    WalletHeroCard(
                      balance: state.balance,
                      onTapDeposit: () => context.push('/wallet/topup'),
                      onTapWithdraw: () => context.push('/wallet/withdraw'),
                      onTapSend: () => context.push('/wallet/transfer'),
                      onTapReceive: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                                content: Text('Receive coming soon')),
                          );
                      },
                    ),
                    const SizedBox(height: AppTokens.space5),
                    Row(
                      children: [
                        Text(
                          'Transactions',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/activity'),
                          child: const Text('See all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space2),
                    if (state.transactions.isEmpty)
                      EmptyState(
                        title: 'No wallet transactions yet',
                        description:
                            'Use Deposit, Withdraw, or Send to create activity.',
                        illustrationName: 'managing-money',
                        primaryAction: EmptyStateAction(
                          label: 'Deposit funds',
                          onPressed: () => context.push('/wallet/topup'),
                        ),
                      )
                    else
                      ..._buildGroupedTransactions(state.transactions).map(
                        (section) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppTokens.space4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: AppTokens.space2),
                              ...section.items.map(
                                (tx) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppTokens.space2),
                                  child: WalletTransactionRow(
                                    transaction: tx,
                                    onTap: () =>
                                        context.push('/wallet/tx/${tx.id}'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_WalletTxSection> _buildGroupedTransactions(
    List<WalletTransaction> transactions,
  ) {
    final map = <DateTime, List<WalletTransaction>>{};
    for (final tx in transactions) {
      final day =
          DateTime(tx.timestamp.year, tx.timestamp.month, tx.timestamp.day);
      map.putIfAbsent(day, () => <WalletTransaction>[]).add(tx);
    }

    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys
        .map(
          (key) => _WalletTxSection(
            label: formatDayLabel(key),
            items: map[key] ?? const [],
          ),
        )
        .toList(growable: false);
  }
}

class _WalletTxSection {
  const _WalletTxSection({
    required this.label,
    required this.items,
  });

  final String label;
  final List<WalletTransaction> items;
}

class _WalletLoadingView extends StatelessWidget {
  const _WalletLoadingView();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AppScaffold(
      child: Column(
        children: [
          AppTopBar(
            leading: IconButton(
              onPressed: null,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: 'My Wallet',
            trailing: IconButton(
              onPressed: null,
              icon: const Icon(Icons.receipt_long_rounded),
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          Container(
            height: 196,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: Container(
                height: 74,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
