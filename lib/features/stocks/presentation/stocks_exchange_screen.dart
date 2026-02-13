import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/stock.dart';
import '../widgets/order_amount_keypad.dart';
import 'stocks_market_controller.dart';

class StocksExchangeScreen extends ConsumerStatefulWidget {
  const StocksExchangeScreen({super.key});

  @override
  ConsumerState<StocksExchangeScreen> createState() =>
      _StocksExchangeScreenState();
}

class _StocksExchangeScreenState extends ConsumerState<StocksExchangeScreen> {
  Stock? _from;
  Stock? _to;
  String _amountText = '0';

  @override
  Widget build(BuildContext context) {
    final marketState = ref.watch(stocksMarketControllerProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: marketState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Unable to load stocks')),
          data: (data) {
            final stocks = data.items;
            _from ??= stocks.isNotEmpty ? stocks.first : null;
            _to ??= stocks.length > 1 ? stocks[1] : _from;

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pageHorizontalPadding,
                AppTokens.space3,
                AppTokens.pageHorizontalPadding,
                AppTokens.space4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTopBar(
                    leading: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                    ),
                    title: 'Exchange',
                  ),
                  const SizedBox(height: AppTokens.space4),
                  _SelectorTile(
                    label: 'From',
                    stock: _from,
                    onTap: () => _pickStock(stocks, isFrom: true),
                  ),
                  const SizedBox(height: AppTokens.space2),
                  Center(
                    child: IconButton.filledTonal(
                      onPressed: () {
                        setState(() {
                          final temp = _from;
                          _from = _to;
                          _to = temp;
                        });
                      },
                      icon: const Icon(Icons.swap_vert_rounded),
                    ),
                  ),
                  const SizedBox(height: AppTokens.space2),
                  _SelectorTile(
                    label: 'To',
                    stock: _to,
                    onTap: () => _pickStock(stocks, isFrom: false),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          '\$$_amountText',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Text(
                          _estimateText(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Expanded(
                    child: OrderAmountKeypad(
                      onKeyTap: _onKeyTap,
                      onBackspace: _onBackspace,
                    ),
                  ),
                  PrimaryButton(
                    label: 'Convert',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Conversion completed (mock)')),
                      );
                      Navigator.of(context).maybePop();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickStock(List<Stock> stocks, {required bool isFrom}) async {
    final selected = await showModalBottomSheet<Stock>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return ListView.builder(
          itemCount: stocks.length,
          itemBuilder: (context, index) {
            final stock = stocks[index];
            return ListTile(
              title: Text(stock.symbol),
              subtitle: Text(stock.name),
              trailing: Text('\$${stock.price.toStringAsFixed(2)}'),
              onTap: () => Navigator.of(context).pop(stock),
            );
          },
        );
      },
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      if (isFrom) {
        _from = selected;
      } else {
        _to = selected;
      }
    });
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == '.' && _amountText.contains('.')) {
        return;
      }
      if (_amountText == '0' && key != '.') {
        _amountText = key;
        return;
      }
      _amountText += key;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountText.length <= 1) {
        _amountText = '0';
      } else {
        _amountText = _amountText.substring(0, _amountText.length - 1);
      }
    });
  }

  String _estimateText() {
    final amount = double.tryParse(_amountText) ?? 0;
    if (_from == null || _to == null || amount <= 0) {
      return 'Enter amount to convert';
    }
    final shares = amount / _from!.price;
    final converted = shares * _to!.price;
    return '~ \$${converted.toStringAsFixed(2)} ${_to!.symbol}';
  }
}

class _SelectorTile extends StatelessWidget {
  const _SelectorTile({
    required this.label,
    required this.stock,
    required this.onTap,
  });

  final String label;
  final Stock? stock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.space3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Text(
                stock == null
                    ? 'Select stock'
                    : '${stock!.symbol} • ${stock!.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }
}
