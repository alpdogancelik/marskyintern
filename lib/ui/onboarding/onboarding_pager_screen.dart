import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_icon.dart';
import '../kit/ui_kit.dart';
import '../theme/app_tokens.dart';
import 'models/onboarding_page_data.dart';
import 'widgets/onboarding_hero.dart';
import 'widgets/page_indicator.dart';

class OnboardingPagerScreen extends StatefulWidget {
  const OnboardingPagerScreen({super.key});

  @override
  State<OnboardingPagerScreen> createState() => _OnboardingPagerScreenState();
}

class _OnboardingPagerScreenState extends State<OnboardingPagerScreen> {
  late final PageController _controller;
  int _index = 0;

  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Manage Crypto in One Place',
      body:
          'Track market moves, monitor your wallet, and buy top crypto assets with a clean mobile experience.',
      heroType: OnboardingHeroType.mockPreview,
      previewVariant: 0,
    ),
    OnboardingPageData(
      title: 'Follow Market Prices Fast',
      body:
          'See live pricing, daily change, and personalized watchlists built for active traders.',
      heroType: OnboardingHeroType.illustration,
      illustrationName: 'woman-is-looking-at-her-bank-account-statistics',
    ),
    OnboardingPageData(
      title: 'Secure Wallet and Transfers',
      body:
          'Protect your account with secure authentication and move funds confidently when you need to act.',
      heroType: OnboardingHeroType.illustration,
      illustrationName: 'man-protects-his-digital-wallet',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _index == _pages.length - 1;

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
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, pageIndex) {
                    return _OnboardingPage(
                      page: _pages[pageIndex],
                      pageCount: _pages.length,
                      activeIndex: _index,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTokens.sectionGapMd),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Skip',
                      semanticLabel: 'Skip onboarding',
                      onPressed: _skip,
                    ),
                  ),
                  const SizedBox(width: AppTokens.space3),
                  Expanded(
                    child: PrimaryButton(
                      label: isLastPage ? 'Get Started' : 'Next',
                      semanticLabel: isLastPage
                          ? 'Finish onboarding'
                          : 'Go to next onboarding page',
                      onPressed: () => _onPrimaryPressed(_index),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPrimaryPressed(int pageIndex) {
    if (pageIndex < _pages.length - 1) {
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      _controller.nextPage(
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    context.go('/get-started-v1');
  }

  void _skip() => context.go('/get-started-v1');
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.page,
    required this.pageCount,
    required this.activeIndex,
  });

  final OnboardingPageData page;
  final int pageCount;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTokens.space2),
          const _BrandMark(),
          const SizedBox(height: AppTokens.sectionGapMd),
          Expanded(
            child: Center(
              child: OnboardingHero(page: page),
            ),
          ),
          const SizedBox(height: AppTokens.sectionGapLg),
          OnboardingPageIndicator(
            count: pageCount,
            activeIndex: activeIndex,
          ),
          const SizedBox(height: AppTokens.sectionGapMd),
          Text(
            page.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.sectionGapSm),
          Text(
            page.body,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: AppTokens.minTapTarget,
        height: AppTokens.minTapTarget,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: const Center(
          child: AppIcon(
            name: 'digital-token',
            semanticLabel: 'GoCrypto mark',
            size: 24,
          ),
        ),
      ),
    );
  }
}
