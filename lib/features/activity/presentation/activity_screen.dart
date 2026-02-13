import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/transaction_group.dart';
import 'activity_controller.dart';
import '../widgets/activity_filter_sheet.dart';
import '../widgets/activity_formatters.dart';
import '../widgets/activity_summary_card.dart';
import '../widgets/activity_transaction_row.dart';
import '../widgets/report_download_sheet.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityControllerProvider);

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: state.when(
          loading: () => const _ActivityLoadingView(),
          error: (error, _) => _ActivityErrorView(
            message: error.toString(),
            onRetry: () => ref.read(activityControllerProvider.notifier).load(),
          ),
          data: (data) => _ActivityContent(state: data),
        ),
      ),
    );
  }
}

class _ActivityContent extends ConsumerWidget {
  const _ActivityContent({required this.state});

  final ActivityState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  title: 'Activity / History',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final result =
                              await showModalBottomSheet<ActivityFilterResult>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ActivityFilterSheet(
                              initialType: state.typeFilter,
                              initialStatus: state.statusFilter,
                            ),
                          );

                          if (result == null || !context.mounted) {
                            return;
                          }

                          ref
                              .read(activityControllerProvider.notifier)
                              .applyFilters(
                                typeFilter: result.typeFilter,
                                statusFilter: result.statusFilter,
                              );
                        },
                        tooltip: 'Filter',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          minimumSize: const Size(44, 44),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                      ),
                      const SizedBox(width: AppTokens.space2),
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
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                ActivitySummaryCard(
                  incoming: state.totalIncoming,
                  outgoing: state.totalOutgoing,
                ),
                const SizedBox(height: AppTokens.space5),
                if (state.groups.isEmpty)
                  EmptyState(
                    title: 'No transactions yet',
                    description: 'Start trading to see your activity history.',
                    illustrationName: 'managing-money',
                    primaryAction: EmptyStateAction(
                      label: 'Explore market',
                      onPressed: () => context.go('/app/home'),
                    ),
                  )
                else
                  ...state.groups.map(
                    (group) => _GroupSection(group: group),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.group});

  final TransactionGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel(group.date),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: ActivityTransactionRow(
                transaction: item,
                onTap: () => context.push('/activity/${item.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLoadingView extends StatelessWidget {
  const _ActivityLoadingView();

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
            title: 'Activity / History',
            trailing: IconButton(
              onPressed: null,
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          ...List.generate(
            6,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: Container(
                height: 72,
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

class _ActivityErrorView extends StatelessWidget {
  const _ActivityErrorView({
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
