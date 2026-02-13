import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/notification_item.dart';
import 'communications_formatters.dart';

class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.item,
    required this.onTap,
  });

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unread = item.status == NotificationStatus.unread;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space3,
        ),
        decoration: BoxDecoration(
          color: unread ? colors.surfaceContainerLow : colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Center(
                child: AppIcon(
                  name: _iconName(item.type),
                  semanticLabel: item.title,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    maxLines: 2,
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
                  formatRelativeTime(item.timestamp),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                if (unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _iconName(NotificationType type) {
    return switch (type) {
      NotificationType.emailVerified => 'bitcoin-mail',
      NotificationType.priceAlert => 'statistics-up',
      NotificationType.depositSuccess => 'wallet',
      NotificationType.security => 'security-shield',
    };
  }
}
