import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/theme/app_tokens.dart';

class SectorChip extends StatelessWidget {
  const SectorChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      child: Container(
        constraints: const BoxConstraints(minHeight: AppTokens.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? colors.primary : colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class SectorGridItem extends StatelessWidget {
  const SectorGridItem({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        padding: const EdgeInsets.all(AppTokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppIcon(
              name: 'analytics',
              semanticLabel: 'Sector icon',
              size: 20,
              tone: AppIconTone.secondary,
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
