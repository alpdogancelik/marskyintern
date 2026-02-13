import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../../activity/widgets/report_download_sheet.dart';
import '../domain/entities/portfolio_snapshot.dart';
import 'portfolio_controller.dart';
import '../widgets/allocation_donut_card.dart';
import '../widgets/holding_row.dart';
import '../widgets/portfolio_segment_control.dart';
import '../widgets/portfolio_value_hero_card.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioSnapshotProvider);
    final segment = ref.watch(portfolioSegmentProvider);

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: portfolioState.when(
          loading: () => const _PortfolioLoadingView(),
          error: (error, _) => _PortfolioErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(portfolioSnapshotProvider),
          ),
          data: (snapshot) => _PortfolioContent(
            snapshot: snapshot,
            segment: segment,
            onSegmentChanged: (value) {
              ref.read(portfolioSegmentProvider.notifier).state = value;
            },
          ),
        ),
      ),
    );
  }
}

class _PortfolioContent extends StatelessWidget {
  const _PortfolioContent({
    required this.snapshot,
    required this.segment,
    required this.onSegmentChanged,
  });

  final PortfolioSnapshot snapshot;
  final PortfolioSegment segment;
  final ValueChanged<PortfolioSegment> onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  title: 'My Portfolio',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => showDownloadReportSheet(context),
                        tooltip: 'Download report',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          minimumSize: const Size(44, 44),
                        ),
                        icon: const Icon(Icons.download_rounded),
                      ),
                      const SizedBox(width: AppTokens.space2),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                  content: Text('More options coming soon')),
                            );
                        },
                        tooltip: 'More',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          minimumSize: const Size(44, 44),
                        ),
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                PortfolioValueHeroCard(summary: snapshot.summary),
                const SizedBox(height: AppTokens.space4),
                PortfolioSegmentControl(
                  selectedIndex: segment == PortfolioSegment.crypto ? 0 : 1,
                  onChanged: (index) {
                    onSegmentChanged(
                      index == 0
                          ? PortfolioSegment.crypto
                          : PortfolioSegment.stocks,
                    );
                  },
                ),
                const SizedBox(height: AppTokens.space4),
                if (segment == PortfolioSegment.stocks) ...[
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          'Stocks overview coming soon',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Text(
                          'Crypto portfolio remains active. This segment is UI-only for now.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                ],
                if (snapshot.holdings.isEmpty)
                  EmptyState(
                    title: 'No assets yet',
                    description:
                        'Buy your first crypto asset to start building your portfolio.',
                    illustrationName: 'managing-money',
                    primaryAction: EmptyStateAction(
                      label: 'Buy first asset',
                      onPressed: () => context.push('/order/crypto?symbol=BTC'),
                    ),
                  )
                else ...[
                  AllocationDonutCard(
                    slices: snapshot.allocations,
                    totalValue: snapshot.summary.totalValue,
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Buy',
                          onPressed: () =>
                              context.push('/order/crypto?symbol=BTC'),
                        ),
                      ),
                      const SizedBox(width: AppTokens.space3),
                      Expanded(
                        child: SecondaryButton(
                          label: 'Deposit',
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                    content: Text('Deposit coming soon')),
                              );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space5),
                  Text(
                    'Holdings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  ...snapshot.holdings.map(
                    (holding) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTokens.space3),
                      child: HoldingRow(
                        holding: holding,
                        onTap: () => context.push(
                          '/order/crypto?symbol=${Uri.encodeComponent(holding.symbol)}',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PortfolioLoadingView extends StatelessWidget {
  const _PortfolioLoadingView();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pageHorizontalPadding,
        AppTokens.space3,
        AppTokens.pageHorizontalPadding,
        AppTokens.space4,
      ),
      child: Column(
        children: [
          AppTopBar(
            leading: IconButton(
              onPressed: null,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: 'My Portfolio',
            trailing: IconButton(
              onPressed: null,
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space3),
              child: Container(
                height: 82,
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

class _PortfolioErrorView extends StatelessWidget {
  const _PortfolioErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTokens.space4),
              PrimaryButton(label: 'Retry', onPressed: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}
