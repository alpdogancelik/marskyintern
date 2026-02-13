import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/message.dart';

class AttachmentCard extends StatelessWidget {
  const AttachmentCard({
    super.key,
    required this.attachment,
    this.compact = false,
  });

  final Attachment attachment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: compact ? 190 : 220,
      padding: const EdgeInsets.all(AppTokens.space2),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: compact ? 90 : 108,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: _PreviewAsset(
              path: attachment.previewAsset,
              fallbackIcon: attachment.type == AttachmentType.image
                  ? Icons.image_outlined
                  : Icons.credit_card_rounded,
            ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            attachment.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            attachment.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PreviewAsset extends StatelessWidget {
  const _PreviewAsset({
    required this.path,
    required this.fallbackIcon,
  });

  final String? path;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final value = path;
    if (value == null || value.trim().isEmpty) {
      return Icon(
        fallbackIcon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    final lowerPath = value.toLowerCase();
    if (lowerPath.endsWith('.svg')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: SvgPicture.asset(
          value,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Image.asset(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          fallbackIcon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
