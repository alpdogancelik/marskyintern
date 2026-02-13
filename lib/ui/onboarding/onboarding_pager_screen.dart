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
      title: 'All in One Investment Platform',
      body:
          'Diversify your investment from cryptocurrency, NFTs, Gold, and stock in one app',
      heroType: OnboardingHeroType.mockPreview,
      previewVariant: 0,
    ),
    OnboardingPageData(
      title: 'Track Prices On All Investment',
      body:
          'Set up automatic price alerts to let you know about price movements for a specific asset.',
      heroType: OnboardingHeroType.illustration,
      illustrationName: 'woman-is-looking-at-her-bank-account-statistics',
    ),
    OnboardingPageData(
      title: 'Stretch Out Your Payments Over Time',
      body:
          'Each time you purchase items on time, payments in small installments.',
      heroType: OnboardingHeroType.mockPreview,
      previewVariant: 1,
    ),
    OnboardingPageData(
      title: 'Enter for a Chance to Win You Share \$1M Assets',
      body:
          'Each time you join events or sell, you get a 0.000% commission. It\u2019s calculated for the value of your purchase.',
      heroType: OnboardingHeroType.illustration,
      illustrationName: 'character-coin-is-the-winner',
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
    return AppScaffold(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pageHorizontalPadding,
        AppTokens.space2,
        AppTokens.pageHorizontalPadding,
        AppTokens.space4,
      ),
      child: Column(
        children: [
          AppTopBar(
            leading: const _BrandMark(),
            trailing: AppPillButton(
              label: 'Skip',
              semanticLabel: 'Skip onboarding',
              onPressed: _skip,
            ),
          ),
          const SizedBox(height: AppTokens.space2),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space4,
                vertical: AppTokens.space2,
              ),
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, pageIndex) {
                  return _OnboardingPage(
                    page: _pages[pageIndex],
                    pageIndex: pageIndex,
                    pageCount: _pages.length,
                    activeIndex: _index,
                    onPressed: _onPrimaryPressed,
                    onBrowseAssets: _openBrowseAssets,
                  );
                },
              ),
            ),
          ),
        ],
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

  void _openBrowseAssets() => context.go('/get-started-v2');
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.page,
    required this.pageIndex,
    required this.pageCount,
    required this.activeIndex,
    required this.onPressed,
    required this.onBrowseAssets,
  });

  final OnboardingPageData page;
  final int pageIndex;
  final int pageCount;
  final int activeIndex;
  final ValueChanged<int> onPressed;
  final VoidCallback onBrowseAssets;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    const SizedBox(height: AppTokens.space4),
                    OnboardingHero(page: page),
                    const SizedBox(height: AppTokens.space6),
                    OnboardingPageIndicator(
                      count: pageCount,
                      activeIndex: activeIndex,
                    ),
                    const SizedBox(height: AppTokens.space6),
                    Text(
                      page.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 25,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    Text(
                      page.body,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space6),
                Column(
                  children: [
                    PrimaryButton(
                      label: 'Get Started',
                      semanticLabel:
                          'Get started on onboarding page ${pageIndex + 1}',
                      onPressed: () => onPressed(pageIndex),
                    ),
                    const SizedBox(height: AppTokens.space2),
                    TextButton(
                      onPressed: onBrowseAssets,
                      child: const Text(
                        'Browse Assets',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space2),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: AppTokens.minTapTarget,
      height: AppTokens.minTapTarget,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: const Center(
        child: AppIcon(
          name: 'digital-token',
          semanticLabel: 'Finix mark',
          size: 24,
        ),
      ),
    );
  }
}
