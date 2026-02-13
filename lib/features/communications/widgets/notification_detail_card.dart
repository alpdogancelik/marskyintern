import 'package:flutter/material.dart';

import '../../../ui/theme/app_tokens.dart';

class NotificationDetailCard extends StatelessWidget {
  const NotificationDetailCard({
    super.key,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5E32FF),
            Color(0xFF6D4DFF),
            Color(0xFF7D69FF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AppTokens.space6),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, AppTokens.buttonHeight),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5D36F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
