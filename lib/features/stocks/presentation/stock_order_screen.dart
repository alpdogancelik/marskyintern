import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/stock_holding.dart';
import '../widgets/order_amount_keypad.dart';
import 'stocks_market_controller.dart';

enum StockOrderSide { buy, sell }

class BuyStockScreen extends StatelessWidget {
  const BuyStockScreen({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return _StockOrderScreen(
      symbol: symbol,
      side: StockOrderSide.buy,
    );
  }
}

class SellStockScreen extends StatelessWidget {
  const SellStockScreen({
    super.key,
    required this.symbol,
  });

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return _StockOrderScreen(
      symbol: symbol,
      side: StockOrderSide.sell,
    );
  }
}

class _StockOrderScreen extends ConsumerStatefulWidget {
  const _StockOrderScreen({
    required this.symbol,
    required this.side,
  });

  final String symbol;
  final StockOrderSide side;

  @override
  ConsumerState<_StockOrderScreen> createState() => _StockOrderScreenState();
}

class _StockOrderScreenState extends ConsumerState<_StockOrderScreen> {
  String _input = '0';

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(stockDetailProvider(widget.symbol));
    final holdingsState = ref.watch(stocksHoldingsProvider);
    final isBuy = widget.side == StockOrderSide.buy;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: detailState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Unable to load stock')),
          data: (stock) {
            final holding = holdingsState.valueOrNull?.firstWhere(
              (item) => item.symbol == stock.symbol,
              orElse: () => StockHolding(
                symbol: stock.symbol,
                name: stock.name,
                quantity: 0,
                avgBuyPrice: stock.price,
                currentPrice: stock.price,
                allocationPercent: 0,
              ),
            );
            final availableAmount =
                isBuy ? 10000.0 : (holding?.marketValue ?? 0);
            final amount = double.tryParse(_input) ?? 0;
            final shares = amount / stock.price;
            final fee = amount * 0.0025;
            final canConfirm = amount > 0 && amount <= availableAmount;

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
                    title: '${isBuy ? 'Buy' : 'Sell'} ${stock.symbol}',
                  ),
                  const SizedBox(height: AppTokens.space4),
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          isBuy ? 'Buying power' : 'Available to sell',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${availableAmount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        Text(
                          '\$$_input',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Wrap(
                    spacing: AppTokens.space2,
                    runSpacing: AppTokens.space2,
                    children: [25, 50, 75, 100].map((percent) {
                      return AppChip(
                        label: '$percent%',
                        onTap: () {
                          setState(() {
                            final value = availableAmount * (percent / 100);
                            _input = value.toStringAsFixed(2);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaTile(
                          label: 'Estimated shares',
                          value:
                              shares.isFinite ? shares.toStringAsFixed(4) : '0',
                        ),
                      ),
                      const SizedBox(width: AppTokens.space3),
                      Expanded(
                        child: _MetaTile(
                          label: 'Fee (mock)',
                          value: '\$${fee.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Expanded(
                    child: OrderAmountKeypad(
                      onKeyTap: _onKeyTap,
                      onBackspace: _onBackspace,
                    ),
                  ),
                  PrimaryButton(
                    label: '${isBuy ? 'Buy' : 'Sell'} ${stock.symbol}',
                    onPressed: canConfirm
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${isBuy ? 'Buy' : 'Sell'} order placed (mock)',
                                ),
                              ),
                            );
                            Navigator.of(context).maybePop();
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == '.' && _input.contains('.')) {
        return;
      }
      if (_input == '0' && key != '.') {
        _input = key;
        return;
      }
      _input += key;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_input.length <= 1) {
        _input = '0';
      } else {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
