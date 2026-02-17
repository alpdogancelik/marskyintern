import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTokens.space8),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 164,
                  height: 164,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  Icons.celebration_outlined,
                  size: 74,
                  color: colors.primary,
                ),
                Positioned(
                  right: 44,
                  bottom: 44,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF15B56B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space6),
          Text(
            'You\'re verified!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            'Your account has been securely verified.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.space10),
          PrimaryButton(
            label: 'Done',
            onPressed: () => context.go('/auth/biometric-face'),
          ),
          const SizedBox(height: AppTokens.space6),
        ],
      ),
    );
  }
}
