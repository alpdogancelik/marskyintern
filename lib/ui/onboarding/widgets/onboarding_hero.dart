import 'package:flutter/material.dart';

import '../../../core/widgets/illustration.dart';
import '../models/onboarding_page_data.dart';
import 'mock_preview_card.dart';

class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    super.key,
    required this.page,
  });

  final OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    if (page.heroType == OnboardingHeroType.illustration) {
      return Illustration(
        name: page.illustrationName ?? 'managing-money',
        size: 230,
      );
    }

    return MockPreviewCard(variant: page.previewVariant);
  }
}
