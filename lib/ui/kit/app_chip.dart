import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
    this.isActive = false,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? leading;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background =
        isActive ? colors.primary.withValues(alpha: 0.12) : colors.surface;
    final borderColor = isActive ? colors.primary : colors.outlineVariant;
    final textColor = isActive ? colors.primary : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppTokens.minTapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space3,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
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
