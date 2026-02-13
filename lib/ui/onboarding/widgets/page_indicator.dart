import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
              ? Duration.zero
              : const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? colors.primary : colors.outline,
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          ),
        );
      }),
    );
  }
}
