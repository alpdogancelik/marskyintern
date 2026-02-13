import 'package:flutter/material.dart';

import '../../../ui/theme/app_tokens.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.isOutgoing,
    required this.timeLabel,
    this.text,
    this.child,
  });

  final bool isOutgoing;
  final String timeLabel;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bubbleColor =
        isOutgoing ? colors.primary : colors.surfaceContainerLowest;
    final textColor = isOutgoing ? colors.onPrimary : colors.onSurface;
    final timeColor = isOutgoing
        ? colors.onPrimary.withValues(alpha: 0.76)
        : colors.onSurfaceVariant;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppTokens.space3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space3,
            vertical: AppTokens.space3,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border:
                isOutgoing ? null : Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (text != null)
                Text(
                  text!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        height: 1.35,
                      ),
                ),
              if (child != null) child!,
              const SizedBox(height: 6),
              Text(
                timeLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: timeColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
