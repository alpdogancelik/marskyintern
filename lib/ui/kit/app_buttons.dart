import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.semanticLabel,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final String? semanticLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        : icon == null
            ? Text(label)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: AppTokens.space2),
                  Text(label),
                ],
              );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final child = leading == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading!,
              const SizedBox(width: AppTokens.space2),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(72, AppTokens.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space4),
          side: BorderSide(color: colors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          ),
          foregroundColor: colors.onSurfaceVariant,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        child: Text(label),
      ),
    );
  }
}
