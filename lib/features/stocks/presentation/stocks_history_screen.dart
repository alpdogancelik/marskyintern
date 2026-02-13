import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/stock_transaction.dart';
import '../widgets/transaction_row.dart';
import 'stocks_market_controller.dart';

class StocksHistoryScreen extends ConsumerStatefulWidget {
  const StocksHistoryScreen({super.key});

  @override
  ConsumerState<StocksHistoryScreen> createState() =>
      _StocksHistoryScreenState();
}

class _StocksHistoryScreenState extends ConsumerState<StocksHistoryScreen> {
  StockTransactionStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(stocksTransactionsProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pageHorizontalPadding,
            AppTokens.space3,
            AppTokens.pageHorizontalPadding,
            AppTokens.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopBar(
                leading: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
                title: 'Transactions History',
              ),
              const SizedBox(height: AppTokens.space3),
              Wrap(
                spacing: AppTokens.space2,
                children: [
                  AppChip(
                    label: 'All',
                    onTap: () => setState(() => _filter = null),
                    isActive: _filter == null,
                  ),
                  AppChip(
                    label: 'Completed',
                    onTap: () => setState(
                        () => _filter = StockTransactionStatus.completed),
                    isActive: _filter == StockTransactionStatus.completed,
                  ),
                  AppChip(
                    label: 'Pending',
                    onTap: () => setState(
                        () => _filter = StockTransactionStatus.pending),
                    isActive: _filter == StockTransactionStatus.pending,
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space4),
              Expanded(
                child: transactionsState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      const Center(child: Text('Unable to load history')),
                  data: (transactions) {
                    final filtered = _filter == null
                        ? transactions
                        : transactions
                            .where((item) => item.status == _filter)
                            .toList(growable: false);
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No transactions'));
                    }

                    final grouped = <String, List<StockTransaction>>{};
                    for (final item in filtered) {
                      final key =
                          '${item.createdAt.year}-${item.createdAt.month}-${item.createdAt.day}';
                      grouped
                          .putIfAbsent(key, () => <StockTransaction>[])
                          .add(item);
                    }
                    final keys = grouped.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return ListView.builder(
                      itemCount: keys.length,
                      itemBuilder: (context, index) {
                        final key = keys[index];
                        final items = grouped[key]!;
                        final date = items.first.createdAt;
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppTokens.space4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: AppTokens.space2),
                              ...items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppTokens.space2),
                                  child: TransactionRow(transaction: item),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
