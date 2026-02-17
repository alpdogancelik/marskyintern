import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/error_presenter.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../data/coin_history_api.dart';
import '../domain/entities/coin.dart';
import '../domain/entities/price_point.dart';

class CoinHistoryQuery {
  const CoinHistoryQuery({
    required this.uuid,
    required this.timePeriod,
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
    backgroundColor: Colors.transparent,
    builder: (_) => _CoinDetailSheet(coin: coin),
  );
}

class _CoinDetailSheet extends ConsumerStatefulWidget {
  const _CoinDetailSheet({required this.coin});

  final Coin coin;

  @override
  ConsumerState<_CoinDetailSheet> createState() => _CoinDetailSheetState();
}

class _CoinDetailSheetState extends ConsumerState<_CoinDetailSheet> {
  static const _periods = <String>['24h', '7d', '30d', '1y', '5y'];
  String _selectedPeriod = '7d';

  @override
  Widget build(BuildContext context) {
    final query = CoinHistoryQuery(
      uuid: widget.coin.uuid,
      timePeriod: _selectedPeriod,
    );

    ref.listen(coinHistoryProvider(query), (previous, next) {
      next.whenOrNull(
        error: (error, _) => showAppErrorSnackBar(context, error),
      );
    });

    final historyState = ref.watch(coinHistoryProvider(query));
    final colors = Theme.of(context).colorScheme;
    final changePrefix = widget.coin.change >= 0 ? '+' : '';
    final changeColor =
        widget.coin.change >= 0 ? AppTokens.success : AppTokens.danger;

    final historyPoints = historyState.valueOrNull ?? const <PricePoint>[];
    final high = _highPrice(historyPoints) ?? widget.coin.price;
    final low = _lowPrice(historyPoints) ?? widget.coin.price;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Row(
              children: [
                CoinAvatar(
                  symbol: widget.coin.symbol,
                  size: 30,
                  semanticLabel: '${widget.coin.symbol} icon',
                ),
                const SizedBox(width: AppTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.coin.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        widget.coin.symbol.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              _formatCurrency(widget.coin.price),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppTokens.space2),
            Text(
              '$changePrefix${widget.coin.change.toStringAsFixed(2)}% (24h)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppTokens.space4),
            Wrap(
              spacing: AppTokens.space2,
              children: _periods
                  .map(
                    (period) => AppChip(
                      label: period,
                      isActive: _selectedPeriod == period,
                      onTap: () => setState(() => _selectedPeriod = period),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: AppTokens.space4),
            Container(
              height: 190,
              padding: const EdgeInsets.all(AppTokens.space3),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: historyState.when(
                data: (points) {
                  if (points.length < 2) {
                    return const Center(
                      child: Text('No chart data available.'),
                    );
                  }
                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: ((high - low).abs() < 1
                            ? 1
                            : (high - low).abs() / 3),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: changeColor,
                          barWidth: 2.4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: changeColor.withValues(alpha: 0.12),
                          ),
                          spots: points
                              .asMap()
                              .entries
                              .map(
                                (entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.price,
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appErrorMessage(error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTokens.space2),
                      SecondaryButton(
                        label: 'Retry',
                        onPressed: () =>
                            ref.invalidate(coinHistoryProvider(query)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'High',
                    value: _formatCurrency(high),
                  ),
                ),
                const SizedBox(width: AppTokens.space3),
                Expanded(
                  child: _MetricCard(
                    label: 'Low',
                    value: _formatCurrency(low),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space4),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Sell',
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).push(
                        '/order/crypto?symbol=${Uri.encodeComponent(widget.coin.symbol)}',
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppTokens.space3),
                Expanded(
                  child: PrimaryButton(
                    label: 'Buy',
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).push(
                        '/order/crypto?symbol=${Uri.encodeComponent(widget.coin.symbol)}',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double? _highPrice(List<PricePoint> points) {
    if (points.isEmpty) {
      return null;
    }
    return points.map((point) => point.price).reduce((a, b) => a > b ? a : b);
  }

  double? _lowPrice(List<PricePoint> points) {
    if (points.isEmpty) {
      return null;
    }
    return points.map((point) => point.price).reduce((a, b) => a < b ? a : b);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.space3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) {
  final abs = value.abs();
  final decimals = abs >= 1000 ? 0 : 2;
  return '\$${value.toStringAsFixed(decimals)}';
}
