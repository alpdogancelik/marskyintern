import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../data/mock_stocks_repository.dart';
import '../domain/entities/stock.dart';
import '../domain/stocks_repository.dart';
import '../widgets/stock_row.dart';

class StocksSearchScreen extends ConsumerStatefulWidget {
  const StocksSearchScreen({super.key});

  @override
  ConsumerState<StocksSearchScreen> createState() => _StocksSearchScreenState();
}

class _StocksSearchScreenState extends ConsumerState<StocksSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Stock> _results = const <Stock>[];
  bool _isLoading = false;
  final List<String> _recent = <String>['AAPL', 'NVDA', 'AMZN'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
    _search();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                title: 'Search Stocks',
              ),
              const SizedBox(height: AppTokens.space4),
              TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Search symbol or company',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _search();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              if (_searchController.text.isEmpty) ...[
                Text(
                  'Recent',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppTokens.space2),
                Wrap(
                  spacing: AppTokens.space2,
                  runSpacing: AppTokens.space2,
                  children: _recent.map((symbol) {
                    return AppChip(
                      label: symbol,
                      onTap: () {
                        _searchController.text = symbol;
                        _search();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppTokens.space4),
              ],
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              'No stocks found.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppTokens.space3),
                            itemBuilder: (context, index) {
                              final stock = _results[index];
                              return StockRow(
                                stock: stock,
                                onTap: () {
                                  if (!_recent.contains(stock.symbol)) {
                                    _recent.insert(0, stock.symbol);
                                  }
                                  context.push('/stocks/${stock.symbol}');
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

  Future<void> _search() async {
    setState(() => _isLoading = true);
    final repository = ref.read(stocksRepositoryProvider);
    final result = await repository.getStocks(
      limit: 25,
      offset: 0,
      query: _searchController.text,
      sortBy: StockSortBy.marketCap,
      ascending: false,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _results = result;
      _isLoading = false;
    });
  }
}
