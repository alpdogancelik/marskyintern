import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/notifications_repository.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/notification_row.dart';
import 'notifications_controller.dart';

class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    return AppScaffold(
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: state.when(
          loading: () => const _NotificationsLoadingView(),
          error: (error, _) => _NotificationsErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.read(notificationsControllerProvider.notifier).load(),
          ),
          data: (data) {
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          title: 'Notifications',
                          trailing: IconButton(
                            tooltip: 'Sort',
                            constraints: const BoxConstraints.tightFor(
                              width: AppTokens.minTapTarget,
                              height: AppTokens.minTapTarget,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                            onPressed: () async {
                              final result = await showModalBottomSheet<
                                  NotificationStatusFilter>(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => CommunicationsFilterSheet<
                                    NotificationStatusFilter>(
                                  title: 'Sort',
                                  initialValue: data.statusFilter,
                                  options: const [
                                    FilterOption(
                                      value: NotificationStatusFilter.all,
                                      label: 'All Status',
                                    ),
                                    FilterOption(
                                      value: NotificationStatusFilter.read,
                                      label: 'Already Read',
                                    ),
                                    FilterOption(
                                      value: NotificationStatusFilter.unread,
                                      label: 'Unread',
                                    ),
                                  ],
                                  confirmLabel: 'Done',
                                ),
                              );
                              if (result == null) {
                                return;
                              }
                              await ref
                                  .read(
                                      notificationsControllerProvider.notifier)
                                  .setStatusFilter(result);
                            },
                            icon: const Icon(Icons.tune_rounded),
                          ),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        SegmentedButton<NotificationsTab>(
                          segments: const [
                            ButtonSegment(
                              value: NotificationsTab.all,
                              label: Text('All'),
                            ),
                            ButtonSegment(
                              value: NotificationsTab.activity,
                              label: Text('Activity'),
                            ),
                          ],
                          selected: {data.tab},
                          onSelectionChanged: (value) {
                            ref
                                .read(notificationsControllerProvider.notifier)
                                .setTab(value.first);
                          },
                        ),
                        const SizedBox(height: AppTokens.space4),
                        if (data.items.isEmpty)
                          EmptyState(
                            title: 'No notifications',
                            description:
                                'When important account updates happen, they will show up here.',
                            illustrationName: 'managing-money',
                            primaryAction: EmptyStateAction(
                              label: 'Explore market',
                              onPressed: () => context.go('/app/home'),
                            ),
                          )
                        else
                          ...data.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppTokens.space2),
                              child: NotificationRow(
                                item: item,
                                onTap: () =>
                                    context.push('/notifications/${item.id}'),
                              ),
                            ),
                          ),
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
}

class _NotificationsLoadingView extends StatelessWidget {
  const _NotificationsLoadingView();

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
            title: 'Notifications',
            trailing: IconButton(
              onPressed: null,
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Expanded(
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTokens.space2),
              itemBuilder: (_, __) => Container(
                height: 78,
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

class _NotificationsErrorView extends StatelessWidget {
  const _NotificationsErrorView({
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
