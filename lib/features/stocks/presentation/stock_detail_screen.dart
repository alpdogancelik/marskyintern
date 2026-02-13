import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/stocks_repository.dart';
import '../widgets/stock_header_card.dart';
import 'stocks_market_controller.dart';

class StockDetailScreen extends ConsumerStatefulWidget {
  const StockDetailScreen({
    super.key,
    required this.symbol,
    this.darkVariant = false,
  });

  final String symbol;
  final bool darkVariant;

  @override
  ConsumerState<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends ConsumerState<StockDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StockTimeframe _timeframe = StockTimeframe.week1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(stockDetailProvider(widget.symbol));
    final chartState = ref.watch(
      stockChartProvider(
        StockChartRequest(symbol: widget.symbol, timeframe: _timeframe),
      ),
    );

    return Scaffold(
      backgroundColor: widget.darkVariant
          ? const Color(0xFF0A0E24)
          : Theme.of(context).colorScheme.surfaceContainerLowest,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppTokens.pageHorizontalPadding,
          AppTokens.space2,
          AppTokens.pageHorizontalPadding,
          AppTokens.space3,
        ),
        child: detailState.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (stock) => PrimaryButton(
            label: 'Buy ${stock.symbol}',
            onPressed: () => context.push('/stocks/buy/${stock.symbol}'),
          ),
        ),
      ),
      body: SafeArea(
        child: detailState.when(
          loading: () => const _StockDetailLoading(),
          error: (error, _) => _StockDetailError(
            onRetry: () => ref.invalidate(stockDetailProvider(widget.symbol)),
            message: error.toString(),
            darkVariant: widget.darkVariant,
          ),
          data: (stock) {
            final fg = widget.darkVariant
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface;
            final cardBg = widget.darkVariant
                ? const Color(0xFF141A37)
                : Theme.of(context).colorScheme.surface;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.pageHorizontalPadding,
                    AppTokens.space3,
                    AppTokens.pageHorizontalPadding,
                    AppTokens.space3,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTopBar(
                          leading: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: fg,
                            ),
                          ),
                          title: stock.symbol,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => context.push(
                                  '/stocks/${stock.symbol}?variant=${widget.darkVariant ? 'light' : 'dark'}',
                                ),
                                icon: Icon(
                                  widget.darkVariant
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  color: fg,
                                ),
                              ),
                              IconButton(
                                onPressed: () => context
                                    .push('/stocks/sell/${stock.symbol}'),
                                icon: Icon(Icons.sell_rounded, color: fg),
                              ),
                              IconButton(
                                onPressed: () =>
                                    context.push('/stocks/history'),
                                icon: Icon(Icons.history_rounded, color: fg),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        StockHeaderCard(
                          stock: stock,
                          darkVariant: widget.darkVariant,
                          onBuyTap: () =>
                              context.push('/stocks/buy/${stock.symbol}'),
                          onSellTap: () =>
                              context.push('/stocks/sell/${stock.symbol}'),
                          onExchangeTap: () => context.push('/stocks/exchange'),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Stats'),
                            Tab(text: 'News'),
                          ],
                        ),
                        const SizedBox(height: AppTokens.space4),
                        if (_tabController.index == 2)
                          _NewsStub(darkVariant: widget.darkVariant)
                        else ...[
                          SizedBox(
                            height: 210,
                            child: chartState.when(
                              loading: () => Center(
                                child: Container(
                                  height: 170,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(
                                        AppTokens.radiusLg),
                                  ),
                                ),
                              ),
                              error: (_, __) => const Center(
                                  child: Text('Chart unavailable')),
                              data: (values) {
                                return LineChart(
                                  LineChartData(
                                    borderData: FlBorderData(show: false),
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: values
                                            .asMap()
                                            .entries
                                            .map(
                                              (entry) => FlSpot(
                                                entry.key.toDouble(),
                                                entry.value,
                                              ),
                                            )
                                            .toList(growable: false),
                                        color: stock.changePercent >= 0
                                            ? const Color(0xFF10B56A)
                                            : const Color(0xFFD9435A),
                                        isCurved: true,
                                        dotData: const FlDotData(show: false),
                                        barWidth: 2.2,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppTokens.space2),
                          Wrap(
                            spacing: AppTokens.space2,
                            children: [
                              _timeframeChip('1D', StockTimeframe.day1),
                              _timeframeChip('1W', StockTimeframe.week1),
                              _timeframeChip('1M', StockTimeframe.month1),
                            ],
                          ),
                          const SizedBox(height: AppTokens.space5),
                          Text(
                            'Market Statistics',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppTokens.space3),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            crossAxisSpacing: AppTokens.space3,
                            mainAxisSpacing: AppTokens.space3,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.8,
                            children: [
                              _statCard(
                                context,
                                'Open',
                                '\$${(stock.price * 0.97).toStringAsFixed(2)}',
                                widget.darkVariant,
                              ),
                              _statCard(
                                context,
                                'High',
                                '\$${(stock.price * 1.03).toStringAsFixed(2)}',
                                widget.darkVariant,
                              ),
                              _statCard(
                                context,
                                'Low',
                                '\$${(stock.price * 0.95).toStringAsFixed(2)}',
                                widget.darkVariant,
                              ),
                              _statCard(
                                context,
                                'Volume',
                                '\$${(stock.volume24h / 1000000000).toStringAsFixed(1)}B',
                                widget.darkVariant,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _timeframeChip(String label, StockTimeframe timeframe) {
    final selected = timeframe == _timeframe;
    return AppChip(
      label: label,
      onTap: () => setState(() => _timeframe = timeframe),
      isActive: selected,
    );
  }

  Widget _statCard(
      BuildContext context, String label, String value, bool darkVariant) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.space3),
      decoration: BoxDecoration(
        color: darkVariant ? const Color(0xFF141A37) : colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: darkVariant ? Colors.white24 : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: darkVariant ? Colors.white70 : colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: darkVariant ? Colors.white : colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _NewsStub extends StatelessWidget {
  const _NewsStub({required this.darkVariant});

  final bool darkVariant;

  @override
  Widget build(BuildContext context) {
    final bg = darkVariant
        ? const Color(0xFF141A37)
        : Theme.of(context).colorScheme.surface;
    final color = darkVariant
        ? Colors.white70
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Text(
        'News feed will be available in a future release.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}

class _StockDetailLoading extends StatelessWidget {
  const _StockDetailLoading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.all(AppTokens.pageHorizontalPadding),
      child: Column(
        children: [
          AppTopBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
            title: 'Loading...',
          ),
          const SizedBox(height: AppTokens.space5),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockDetailError extends StatelessWidget {
  const _StockDetailError({
    required this.message,
    required this.onRetry,
    required this.darkVariant,
  });

  final String message;
  final VoidCallback onRetry;
  final bool darkVariant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.pageHorizontalPadding),
      child: Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space3),
              PrimaryButton(
                label: 'Retry',
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
