import 'package:flutter/material.dart';

import '../../../../core/widgets/app_icon.dart';
import '../../../../ui/theme/app_tokens.dart';

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
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

class AuthDividerText extends StatelessWidget {
  const AuthDividerText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space3),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(child: Divider(color: colors.outlineVariant)),
      ],
    );
  }
}

class GoogleGlyph extends StatelessWidget {
  const GoogleGlyph({super.key});

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
