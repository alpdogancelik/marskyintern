import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/message.dart';
import '../widgets/attachment_card.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/communications_formatters.dart';
import '../widgets/voice_message_bubble.dart';
import 'messages_controller.dart';

class MessageThreadScreen extends ConsumerStatefulWidget {
  const MessageThreadScreen({
    super.key,
    required this.threadId,
  });

  final String threadId;

  @override
  ConsumerState<MessageThreadScreen> createState() =>
      _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  final _inputController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(messagesControllerProvider.notifier).openThread(widget.threadId);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (data) {
            final thread = data.threadById(widget.threadId);
            if (thread == null) {
              return EmptyState(
                title: 'Thread not found',
                description: 'This conversation is no longer available.',
                illustrationName: 'managing-money',
                primaryAction: EmptyStateAction(
                  label: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              );
            }

            final messages = data.threadMessages[widget.threadId] ?? const [];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.pageHorizontalPadding,
                    AppTokens.space3,
                    AppTokens.pageHorizontalPadding,
                    AppTokens.space3,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        constraints: const BoxConstraints.tightFor(
                          width: AppTokens.minTapTarget,
                          height: AppTokens.minTapTarget,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: AppTokens.space3),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        child: Text(
                          thread.name.isNotEmpty ? thread.name[0] : '?',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const SizedBox(width: AppTokens.space2),
                      Expanded(
                        child: Text(
                          thread.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'More',
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppTokens.pageHorizontalPadding,
                            AppTokens.space4,
                            AppTokens.pageHorizontalPadding,
                            AppTokens.space2,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final item = messages[index];
                            return ChatBubble(
                              isOutgoing: item.isOutgoing,
                              timeLabel: formatMessageTime(item.timestamp),
                              text: item.type == MessageType.text
                                  ? item.text
                                  : null,
                              child: _buildMessageBody(context, item),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTokens.pageHorizontalPadding,
                    AppTokens.space2,
                    AppTokens.pageHorizontalPadding,
                    AppTokens.space2 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ChatInputBar(
                    controller: _inputController,
                    enabled: !_isSending,
                    onTapAttachment: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('Attach coming soon')),
                        );
                    },
                    onSend: _sendMessage,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget? _buildMessageBody(BuildContext context, Message item) {
    if (item.type == MessageType.image && item.attachment != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppTokens.space2),
        child: AttachmentCard(
          attachment: item.attachment!,
          compact: true,
        ),
      );
    }
    if (item.type == MessageType.voice) {
      final duration = item.voiceDuration ?? Duration.zero;
      final minutes = duration.inMinutes.toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      return Padding(
        padding: const EdgeInsets.only(top: AppTokens.space2),
        child: VoiceMessageBubble(
          isOutgoing: item.isOutgoing,
          durationLabel: '$minutes:$seconds',
          onTapPlay: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Voice playback coming soon')),
              );
          },
        ),
      );
    }
    return null;
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);
    try {
      await ref.read(messagesControllerProvider.notifier).sendThreadMessage(
            threadId: widget.threadId,
            text: text,
          );
      _inputController.clear();
      if (!mounted) {
        return;
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
