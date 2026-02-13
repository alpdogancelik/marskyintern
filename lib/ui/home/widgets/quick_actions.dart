import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../theme/app_tokens.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onActionTap,
  });

  final ValueChanged<String> onActionTap;

  @override
  Widget build(BuildContext context) {
    const actions = <_QuickActionItem>[
      _QuickActionItem(label: 'Buy', icon: 'buying-bitcoin'),
      _QuickActionItem(label: 'Wallet', icon: 'wallet'),
      _QuickActionItem(label: 'Portfolio', icon: 'chart'),
      _QuickActionItem(label: 'History', icon: 'receipt'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Expanded(
          child: _QuickActionButton(
            item: action,
            onTap: () => onActionTap(action.label),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.item,
    required this.onTap,
  });

  final _QuickActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTokens.space2),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Center(
                  child: AppIcon(
                    name: item.icon,
                    semanticLabel: item.label,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final String icon;
}
