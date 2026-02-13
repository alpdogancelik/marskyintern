import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/error_presenter.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/coin_logo.dart';
import '../../../ui/kit/ui_kit.dart';
import '../data/coin_history_api.dart';
import '../domain/entities/coin.dart';
import '../domain/entities/price_point.dart';

class CoinHistoryQuery {
  const CoinHistoryQuery({
    required this.uuid,
    this.timePeriod = '7d',
  });

  final String uuid;
  final String timePeriod;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoinHistoryQuery &&
        other.uuid == uuid &&
        other.timePeriod == timePeriod;
  }

  @override
  int get hashCode => Object.hash(uuid, timePeriod);
}

final coinHistoryProvider =
    FutureProvider.family<List<PricePoint>, CoinHistoryQuery>(
        (ref, query) async {
  final api = ref.watch(coinHistoryApiProvider);
  final dtos = await api.getPriceHistory(
    uuid: query.uuid,
    timePeriod: query.timePeriod,
  );
  return dtos.map((dto) => dto.toEntity()).toList();
});

Future<void> showCoinDetailSheet(BuildContext context, Coin coin) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _CoinDetailSheet(
      coin: coin,
      onBuy: () => GoRouter.of(context).push(
        '/order/crypto?symbol=${Uri.encodeComponent(coin.symbol)}',
      ),
    ),
  );
}

class _CoinDetailSheet extends ConsumerWidget {
  const _CoinDetailSheet({
    required this.coin,
    required this.onBuy,
  });

  final Coin coin;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = CoinHistoryQuery(uuid: coin.uuid, timePeriod: '7d');
    ref.listen(coinHistoryProvider(query), (previous, next) {
      next.whenOrNull(
        error: (error, _) => showAppErrorSnackBar(context, error),
      );
    });

    final historyState = ref.watch(coinHistoryProvider(query));
    final changePrefix = coin.change >= 0 ? '+' : '';
    final changeColor = coin.change >= 0 ? Colors.green : Colors.red;

    final historyPoints = historyState.valueOrNull ?? const <PricePoint>[];
    final highValue = historyPoints.isEmpty
        ? '-'
        : '\$${historyPoints.map((point) => point.price).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}';
    final lowValue = historyPoints.isEmpty
        ? '-'
        : '\$${historyPoints.map((point) => point.price).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coin.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Rank', value: '#${coin.rank}'),
            _DetailRow(label: 'Symbol', value: coin.symbol),
            _DetailRow(
              label: 'Current Price',
              value: '\$${coin.price.toStringAsFixed(2)}',
            ),
            _DetailRow(
              label: 'Change Rate',
              value: '$changePrefix${coin.change.toStringAsFixed(2)}%',
              valueColor: changeColor,
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Buy ${coin.symbol}',
              onPressed: () {
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) => onBuy());
              },
              semanticLabel: 'Buy ${coin.symbol}',
            ),
            const SizedBox(height: 14),
            _SwapSelectorCard(coin: coin),
            const SizedBox(height: 12),
            const Text(
              '7d Price History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            historyState.when(
              data: (points) {
                if (points.isEmpty) {
                  return const _HistoryEmpty();
                }

                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          dotData: const FlDotData(show: false),
                          spots: points
                              .asMap()
                              .entries
                              .map(
                                (entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.price,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const _HistoryLoading(),
              error: (error, _) => _HistoryError(
                message: appErrorMessage(error),
                onRetry: () => ref.invalidate(coinHistoryProvider(query)),
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'High Value', value: highValue),
            _DetailRow(label: 'Low Value', value: lowValue),
          ],
        ),
      ),
    );
  }
}

class _SwapSelectorCard extends StatefulWidget {
  const _SwapSelectorCard({required this.coin});

  final Coin coin;

  @override
  State<_SwapSelectorCard> createState() => _SwapSelectorCardState();
}

class _SwapSelectorCardState extends State<_SwapSelectorCard> {
  late List<_SwapAsset> _assets;
  late _SwapAsset _fromAsset;
  late _SwapAsset _toAsset;

  @override
  void initState() {
    super.initState();
    _assets = _buildAssets();
    _fromAsset = _assets.first;
    _toAsset = _assets.firstWhere(
      (asset) => asset.symbol != _fromAsset.symbol,
      orElse: () => _assets.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                AppIcon(
                  name: 'exchange',
                  semanticLabel: 'Swap selector',
                  size: 20,
                  tone: AppIconTone.secondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Swap / Exchange',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AssetSelectorButton(
              label: 'From',
              asset: _fromAsset,
              onTap: () => _pickAsset(isFrom: true),
            ),
            const SizedBox(height: 8),
            Center(
              child: IconButton(
                tooltip: 'Swap from and to assets',
                constraints:
                    const BoxConstraints.tightFor(width: 48, height: 48),
                onPressed: () => setState(() {
                  final currentFrom = _fromAsset;
                  _fromAsset = _toAsset;
                  _toAsset = currentFrom;
                }),
                icon: const AppIcon(
                  name: 'exchange',
                  semanticLabel: 'Swap direction',
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _AssetSelectorButton(
              label: 'To',
              asset: _toAsset,
              onTap: () => _pickAsset(isFrom: false),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  label: 'Wallet',
                  iconName: 'wallet',
                  semanticLabel: 'Wallet action',
                  onPressed: () => _showActionHint('Wallet action coming soon'),
                ),
                _ActionButton(
                  label: 'Payment',
                  iconName: 'payment-machine',
                  semanticLabel: 'Payment action',
                  onPressed: () =>
                      _showActionHint('Payment action coming soon'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_SwapAsset> _buildAssets() {
    final candidates = <_SwapAsset>[
      _SwapAsset(symbol: widget.coin.symbol, name: widget.coin.name),
      const _SwapAsset(symbol: 'BTC', name: 'Bitcoin'),
      const _SwapAsset(symbol: 'ETH', name: 'Ethereum'),
      const _SwapAsset(symbol: 'USDT', name: 'Tether'),
      const _SwapAsset(symbol: 'BNB', name: 'BNB'),
      const _SwapAsset(symbol: 'SOL', name: 'Solana'),
    ];

    final unique = <String, _SwapAsset>{};
    for (final item in candidates) {
      unique[item.symbol.toUpperCase()] = item;
    }
    return unique.values.toList(growable: false);
  }

  Future<void> _pickAsset({required bool isFrom}) async {
    final selected = await showModalBottomSheet<_SwapAsset>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _assets.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final asset = _assets[index];
            return ListTile(
              minVerticalPadding: 8,
              leading: CoinLogo(
                symbol: asset.symbol,
                size: 24,
                semanticLabel: '${asset.symbol} logo',
              ),
              title: Text(asset.name),
              subtitle: Text(asset.symbol),
              onTap: () => Navigator.of(context).pop(asset),
            );
          },
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      if (isFrom) {
        _fromAsset = selected;
        if (_toAsset.symbol == _fromAsset.symbol) {
          _toAsset = _assets.firstWhere(
            (asset) => asset.symbol != _fromAsset.symbol,
            orElse: () => _toAsset,
          );
        }
      } else {
        _toAsset = selected;
        if (_fromAsset.symbol == _toAsset.symbol) {
          _fromAsset = _assets.firstWhere(
            (asset) => asset.symbol != _toAsset.symbol,
            orElse: () => _fromAsset,
          );
        }
      }
    });
  }

  void _showActionHint(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AssetSelectorButton extends StatelessWidget {
  const _AssetSelectorButton({
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final _SwapAsset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label asset selector: ${asset.symbol}',
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          focusColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '$label:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CoinLogo(
                    symbol: asset.symbol,
                    size: 24,
                    semanticLabel: '${asset.symbol} logo',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${asset.name} (${asset.symbol})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const AppIcon(
                    name: 'payment-machine',
                    semanticLabel: 'Open asset picker',
                    size: 20,
                    tone: AppIconTone.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.iconName,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String label;
  final String iconName;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: AppIcon(
        name: iconName,
        semanticLabel: semanticLabel,
        size: 20,
        tone: AppIconTone.secondary,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(104, 48),
      ),
    );
  }
}

class _SwapAsset {
  const _SwapAsset({
    required this.symbol,
    required this.name,
  });

  final String symbol;
  final String name;
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: Text('No history data available.')),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
