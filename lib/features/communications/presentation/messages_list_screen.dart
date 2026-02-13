import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/thread_row.dart';
import 'messages_controller.dart';

class MessagesListScreen extends ConsumerWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(messagesControllerProvider);
    return AppScaffold(
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: state.when(
          loading: () => const _MessagesLoadingView(),
          error: (error, _) => _MessagesErrorView(
            message: error.toString(),
            onRetry: () => ref.read(messagesControllerProvider.notifier).load(),
          ),
          data: (data) {
            final threads = data.filteredThreads;
            final pinned = threads
                .where((thread) => thread.pinned)
                .toList(growable: false);
            final others = threads
                .where((thread) => !thread.pinned)
                .toList(growable: false);
            return Scaffold(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLowest,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Compose coming soon')),
                    );
                },
                tooltip: 'Compose',
                child: const Icon(Icons.add_rounded),
              ),
              body: CustomScrollView(
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
                            leading: _BackButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            title: 'Message',
                            trailing: IconButton(
                              tooltip: 'Filter messages',
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
                                final nextFilter =
                                    await showModalBottomSheet<MessagesFilter>(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      CommunicationsFilterSheet<MessagesFilter>(
                                    title: 'Filter',
                                    initialValue: data.filter,
                                    options: const [
                                      FilterOption(
                                        value: MessagesFilter.all,
                                        label: 'All Message',
                                      ),
                                      FilterOption(
                                        value: MessagesFilter.unread,
                                        label: 'Unread Message',
                                      ),
                                      FilterOption(
                                        value: MessagesFilter.unanswered,
                                        label: 'Unanswered',
                                      ),
                                    ],
                                    confirmLabel: 'Done',
                                  ),
                                );
                                if (nextFilter == null) {
                                  return;
                                }
                                ref
                                    .read(messagesControllerProvider.notifier)
                                    .setFilter(nextFilter);
                              },
                              icon: const Icon(Icons.tune_rounded),
                            ),
                          ),
                          const SizedBox(height: AppTokens.space4),
                          SearchBarField(
                            readOnly: true,
                            hintText: 'Search',
                            onTap: () => context.push('/messages/search'),
                          ),
                          const SizedBox(height: AppTokens.space5),
                          if (threads.isEmpty)
                            EmptyState(
                              title: 'No messages yet',
                              description:
                                  'Start a message to keep your portfolio conversations in one place.',
                              illustrationName:
                                  'man-looking-for-someone-to-help-with-a-question',
                              primaryAction: EmptyStateAction(
                                label: 'Start a message',
                                onPressed: () {},
                              ),
                            )
                          else ...[
                            if (pinned.isNotEmpty) ...[
                              const _SectionTitle('Pinned message'),
                              const SizedBox(height: AppTokens.space2),
                              ...pinned.map(
                                (thread) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppTokens.space2),
                                  child: ThreadRow(
                                    thread: thread,
                                    onTap: () async {
                                      await ref
                                          .read(messagesControllerProvider
                                              .notifier)
                                          .openThread(thread.id);
                                      if (!context.mounted) {
                                        return;
                                      }
                                      context.push(
                                          '/messages/thread/${thread.id}');
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTokens.space3),
                            ],
                            if (others.isNotEmpty) ...[
                              const _SectionTitle('All message'),
                              const SizedBox(height: AppTokens.space2),
                              ...others.map(
                                (thread) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppTokens.space2),
                                  child: ThreadRow(
                                    thread: thread,
                                    onTap: () async {
                                      await ref
                                          .read(messagesControllerProvider
                                              .notifier)
                                          .openThread(thread.id);
                                      if (!context.mounted) {
                                        return;
                                      }
                                      context.push(
                                          '/messages/thread/${thread.id}');
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      constraints: const BoxConstraints.tightFor(
        width: AppTokens.minTapTarget,
        height: AppTokens.minTapTarget,
      ),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _MessagesLoadingView extends StatelessWidget {
  const _MessagesLoadingView();

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
            leading: const _BackButton(onPressed: _noop),
            title: 'Message',
            trailing: IconButton(
              onPressed: null,
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          Expanded(
            child: ListView.separated(
              itemCount: 7,
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

class _MessagesErrorView extends StatelessWidget {
  const _MessagesErrorView({
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

void _noop() {}
