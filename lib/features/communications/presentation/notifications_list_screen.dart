import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/notification_item.dart';
import '../widgets/notification_row.dart';
import 'notifications_controller.dart';

class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  ConsumerState<NotificationsListScreen> createState() =>
      _NotificationsListScreenState();
}

class _NotificationsListScreenState
    extends ConsumerState<NotificationsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            final items = _filterByQuery(data.items, _query);
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
                          title: 'Notification',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Search',
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
                                onPressed: () => setState(() {}),
                                icon: const Icon(Icons.search_rounded),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        SearchField(
                          controller: _searchController,
                          hintText: 'Search notifications',
                          onChanged: (value) => setState(() => _query = value),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        if (items.isEmpty)
                          EmptyState(
                            title: 'No notifications',
                            description: _query.isEmpty
                                ? 'You are all caught up for now.'
                                : 'No matches for "$_query".',
                            illustrationName: 'managing-money',
                            primaryAction: EmptyStateAction(
                              label: 'Back to Home',
                              onPressed: () => context.go('/app/home'),
                            ),
                          )
                        else
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTokens.space2,
                              ),
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

  List<NotificationItem> _filterByQuery(
      List<NotificationItem> items, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return items;
    }
    return items
        .where(
          (item) =>
              item.title.toLowerCase().contains(q) ||
              item.body.toLowerCase().contains(q),
        )
        .toList(growable: false);
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
            title: 'Notification',
            trailing: IconButton(
              onPressed: null,
              icon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppTokens.space3),
          Container(
            height: 48,
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
