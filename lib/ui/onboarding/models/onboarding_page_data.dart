enum OnboardingHeroType { illustration, mockPreview }

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.body,
    required this.heroType,
    this.illustrationName,
    this.previewVariant = 0,
  });

  final String title;
  final String body;
  final OnboardingHeroType heroType;
  final String? illustrationName;
  final int previewVariant;
}
