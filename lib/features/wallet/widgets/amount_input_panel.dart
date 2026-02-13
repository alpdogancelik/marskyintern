import 'package:flutter/material.dart';

import '../../../ui/kit/app_card.dart';
import '../../../ui/theme/app_tokens.dart';
import 'amount_keypad.dart';

class AmountInputPanel extends StatelessWidget {
  const AmountInputPanel({
    super.key,
    required this.title,
    required this.amountText,
    required this.subtitle,
    required this.onKeyTap,
    required this.onBackspace,
  });

  final String title;
  final String amountText;
  final String subtitle;
  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTokens.space3),
              Text(
                amountText,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        AmountKeypad(onKeyTap: onKeyTap, onBackspace: onBackspace),
      ],
    );
  }
}
