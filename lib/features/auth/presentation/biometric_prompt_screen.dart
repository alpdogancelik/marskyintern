import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';

class BiometricPromptScreen extends StatelessWidget {
  const BiometricPromptScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.icon,
    required this.primaryRoute,
    this.skipRoute = '/app/home',
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final IconData icon;
  final String primaryRoute;
  final String skipRoute;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTokens.space8),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.06),
                  ),
                ),
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.12),
                  ),
                ),
                Icon(icon, size: 56, color: colors.primary),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.space10),
          PrimaryButton(
            label: primaryLabel,
            onPressed: () => context.go(primaryRoute),
          ),
          const SizedBox(height: AppTokens.space2),
          TextButton(
            onPressed: () => context.go(skipRoute),
            child: const Text('Skip for Now'),
          ),
        ],
      ),
    );
  }
}
