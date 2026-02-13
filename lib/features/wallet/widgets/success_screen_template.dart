import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';

class SuccessScreenTemplate extends StatelessWidget {
  const SuccessScreenTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppIcon(
                name: 'check-mark',
                semanticLabel: 'Success',
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space5),
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
          const Spacer(),
          PrimaryButton(label: primaryLabel, onPressed: onPrimary),
          const SizedBox(height: AppTokens.space3),
          SecondaryButton(label: secondaryLabel, onPressed: onSecondary),
        ],
      ),
    );
  }
}
