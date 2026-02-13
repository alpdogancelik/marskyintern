import 'package:flutter/material.dart';

import '../../../ui/kit/coin_avatar.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/message_thread.dart';
import 'communications_formatters.dart';

class ThreadRow extends StatelessWidget {
  const ThreadRow({
    super.key,
    required this.thread,
    required this.onTap,
  });

  final MessageThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space3,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.surfaceContainerLow,
              child: thread.avatarSymbol == null
                  ? Text(
                      thread.name.isNotEmpty ? thread.name[0] : '?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    )
                  : CoinAvatar(
                      symbol: thread.avatarSymbol!,
                      size: 26,
                    ),
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (thread.pinned)
                        Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTokens.space2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatRelativeTime(thread.updatedAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 6),
                if (thread.unreadCount > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D4DFF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${thread.unreadCount}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
