import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_icon.dart';
import '../kit/ui_kit.dart';
import '../theme/app_tokens.dart';

class GetStartedScreenV1 extends StatelessWidget {
  const GetStartedScreenV1({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GetStartedScreen(
      title: 'Start with GoCrypto',
      subtitle: 'Trade, track, and manage your crypto assets in one app.',
      primaryLabel: 'Get Started',
      primaryRoute: '/auth/login',
      alternateActionLabel: 'Create account',
      alternateRoute: '/auth/signup',
    );
  }
}

class GetStartedScreenV2 extends StatelessWidget {
  const GetStartedScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GetStartedScreen(
      title: 'Welcome to GoCrypto',
      subtitle: 'Secure your portfolio and move funds quickly.',
      primaryLabel: 'Get Started',
      primaryRoute: '/auth/login',
      alternateActionLabel: 'Sign in',
      alternateRoute: '/auth/login',
    );
  }
}

class _GetStartedScreen extends StatelessWidget {
  const _GetStartedScreen({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.primaryRoute,
    required this.alternateActionLabel,
    required this.alternateRoute,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final String primaryRoute;
  final String alternateActionLabel;
  final String alternateRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pageHorizontalPadding,
            AppTokens.space4,
            AppTokens.pageHorizontalPadding,
            AppTokens.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTokens.space2),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppTokens.sectionGapLg),
              const _GetStartedHeroRow(),
              const Spacer(),
              PrimaryButton(
                label: primaryLabel,
                onPressed: () => context.go(primaryRoute),
              ),
              const SizedBox(height: AppTokens.space2),
              Center(
                child: TextButton(
                  onPressed: () => context.go(alternateRoute),
                  child: Text(alternateActionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GetStartedHeroRow extends StatelessWidget {
  const _GetStartedHeroRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _GetStartedFeatureCard(
            title: 'Market',
            description: 'Track top assets and price movement.',
            iconName: 'chart-candle',
          ),
        ),
        SizedBox(width: AppTokens.space3),
        Expanded(
          child: _GetStartedFeatureCard(
            title: 'Wallet',
            description: 'Store and transfer crypto securely.',
            iconName: 'wallet',
          ),
        ),
      ],
    );
  }
}

class _GetStartedFeatureCard extends StatelessWidget {
  const _GetStartedFeatureCard({
    required this.title,
    required this.description,
    required this.iconName,
  });

  final String title;
  final String description;
  final String iconName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Center(
              child: AppIcon(
                name: iconName,
                semanticLabel: '$title icon',
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space3),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
