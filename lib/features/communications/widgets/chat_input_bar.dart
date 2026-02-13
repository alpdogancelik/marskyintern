import 'package:flutter/material.dart';

import '../../../ui/theme/app_tokens.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onTapAttachment,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onTapAttachment;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasText = controller.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space2,
        AppTokens.space2,
        AppTokens.space2,
        AppTokens.space2,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: enabled ? onTapAttachment : null,
            tooltip: 'Attach',
            icon: const Icon(Icons.attach_file_rounded),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Type message...',
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.space2),
          IconButton(
            onPressed: enabled && hasText ? onSend : null,
            tooltip: 'Send',
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
              backgroundColor: hasText && enabled
                  ? colors.primary
                  : colors.surfaceContainerHighest,
            ),
            icon: Icon(
              Icons.send_rounded,
              color: hasText && enabled
                  ? colors.onPrimary
                  : colors.onSurfaceVariant,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
