import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/theme/app_tokens.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/thread_row.dart';
import 'messages_controller.dart';

class MessagesSearchScreen extends ConsumerStatefulWidget {
  const MessagesSearchScreen({super.key});

  @override
  ConsumerState<MessagesSearchScreen> createState() =>
      _MessagesSearchScreenState();
}

class _MessagesSearchScreenState extends ConsumerState<MessagesSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNode.requestFocus();
      ref.read(messagesControllerProvider.notifier).search('');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pageHorizontalPadding,
            AppTokens.space3,
            AppTokens.pageHorizontalPadding,
            AppTokens.space4,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
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
                  const SizedBox(width: AppTokens.space2),
                  Expanded(
                    child: SearchBarField(
                      controller: _controller,
                      autofocus: true,
                      hintText: 'Search',
                      onChanged: (value) =>
                          ref.read(messagesControllerProvider.notifier).search(
                                value,
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space4),
              Expanded(
                child: state.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (data) {
                    final results = data.searchResults;
                    if (results.isEmpty) {
                      return Center(
                        child: Text(
                          'No conversations found.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: results.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppTokens.space2),
                      itemBuilder: (context, index) {
                        final thread = results[index];
                        return ThreadRow(
                          thread: thread,
                          onTap: () async {
                            await ref
                                .read(messagesControllerProvider.notifier)
                                .openThread(thread.id);
                            if (!context.mounted) {
                              return;
                            }
                            context.push('/messages/thread/${thread.id}');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
