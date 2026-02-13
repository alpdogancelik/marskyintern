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
    this.skipRoute = '/app/home',
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final IconData icon;
  final String skipRoute;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTokens.space10),
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 40, color: colors.primary),
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
            onPressed: () => _showComingSoon(context),
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Coming soon')));
  }
}
