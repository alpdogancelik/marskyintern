import 'package:flutter/material.dart';

import '../brand/brand.dart';
import 'app_icon.dart';
import 'illustration.dart';

class EmptyStateAction {
  const EmptyStateAction({
    required this.label,
    required this.onPressed,
    this.iconName,
  });

  final String label;
  final VoidCallback onPressed;
  final String? iconName;
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.primaryAction,
    this.secondaryAction,
    this.illustrationName,
  });

  final String title;
  final String description;
  final EmptyStateAction? primaryAction;
  final EmptyStateAction? secondaryAction;
  final String? illustrationName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 420
            ? KoraBrand.spaceMd
            : KoraBrand.spaceXl;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: KoraBrand.spaceLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (illustrationName != null) ...[
                    Illustration(
                      name: illustrationName!,
                      size: constraints.maxWidth < 420 ? 140 : 176,
                      semanticLabel: '$title illustration',
                    ),
                    const SizedBox(height: KoraBrand.spaceLg),
                  ],
                  Text(
                    title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: KoraBrand.spaceSm),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (primaryAction != null || secondaryAction != null) ...[
                    const SizedBox(height: KoraBrand.spaceXl),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: KoraBrand.spaceSm,
                      runSpacing: KoraBrand.spaceSm,
                      children: [
                        if (primaryAction != null)
                          if (primaryAction!.iconName == null)
                            ElevatedButton(
                              onPressed: primaryAction!.onPressed,
                              child: Text(primaryAction!.label),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: primaryAction!.onPressed,
                              icon: AppIcon(
                                name: primaryAction!.iconName!,
                                semanticLabel: '${primaryAction!.label} icon',
                                size: 20,
                              ),
                              label: Text(primaryAction!.label),
                            ),
                        if (secondaryAction != null)
                          if (secondaryAction!.iconName == null)
                            OutlinedButton(
                              onPressed: secondaryAction!.onPressed,
                              child: Text(secondaryAction!.label),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: secondaryAction!.onPressed,
                              icon: AppIcon(
                                name: secondaryAction!.iconName!,
                                semanticLabel:
                                    '${secondaryAction!.label} icon',
                                size: 20,
                                tone: AppIconTone.secondary,
                              ),
                              label: Text(secondaryAction!.label),
                            ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
