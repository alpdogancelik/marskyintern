import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/settings_models.dart';

class SettingsPageScaffold extends StatelessWidget {
  const SettingsPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppTokens.pageHorizontalPadding,
      AppTokens.space3,
      AppTokens.pageHorizontalPadding,
      AppTokens.space6,
    ),
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: padding,
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
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      title: title,
                      trailing: trailing,
                    ),
                    const SizedBox(height: AppTokens.space5),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    this.onEdit,
  });

  final UserProfile profile;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.surfaceContainerLow,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppTokens.space2),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.title,
    required this.iconName,
    this.subtitle,
    this.onTap,
    this.trailingText,
    this.fallbackIcon = Icons.chevron_right_rounded,
  });

  final String title;
  final String iconName;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? trailingText;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTokens.space2,
          horizontal: AppTokens.space2,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Center(
                child: AppIcon(
                  name: iconName,
                  semanticLabel: title,
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
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            const SizedBox(width: 4),
            Icon(
              fallbackIcon,
              color: colors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class DataFieldTile extends StatelessWidget {
  const DataFieldTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space3,
        vertical: AppTokens.space3,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
