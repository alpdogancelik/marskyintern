import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_icon.dart';
import '../kit/ui_kit.dart';
import '../theme/app_tokens.dart';
import 'widgets/get_started_header.dart';

class GetStartedScreenV1 extends StatelessWidget {
  const GetStartedScreenV1({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GetStartedScreen(showAssetPreview: false);
  }
}

class GetStartedScreenV2 extends StatelessWidget {
  const GetStartedScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GetStartedScreen(showAssetPreview: true);
  }
}

class _GetStartedScreen extends StatelessWidget {
  const _GetStartedScreen({
    required this.showAssetPreview,
  });

  final bool showAssetPreview;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: AppCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppTokens.space2),
                        GetStartedHeader(showAssetPreview: showAssetPreview),
                        const SizedBox(height: AppTokens.space4),
                        Text(
                          'Get Started',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Text(
                          'All in One Investment Platform',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: AppTokens.space8),
                        PrimaryButton(
                          label: 'Continue with Email',
                          semanticLabel: 'Continue with Email',
                          onPressed: () => context.go('/auth/login'),
                          icon: const AppIcon(
                            name: 'bitcoin-mail',
                            semanticLabel: 'Email icon',
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        SecondaryButton(
                          label: 'Continue with Apple',
                          semanticLabel: 'Continue with Apple',
                          onPressed: () => _showComingSoon(context),
                          leading: const Icon(Icons.apple, size: 20),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        SecondaryButton(
                          label: 'Continue with Google',
                          semanticLabel: 'Continue with Google',
                          onPressed: () => _showComingSoon(context),
                          leading: const _GoogleGlyph(),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const AppDivider(
                          margin:
                              EdgeInsets.symmetric(vertical: AppTokens.space5),
                        ),
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Don\u2019t have an account? ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/auth/signup'),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(
                                    AppTokens.minTapTarget,
                                    AppTokens.minTapTarget,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Sign Up'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTokens.space4),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        'G',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
