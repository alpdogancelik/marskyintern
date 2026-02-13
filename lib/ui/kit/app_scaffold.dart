import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTokens.pageHorizontalPadding,
      vertical: AppTokens.space4,
    ),
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor:
          backgroundColor ?? theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
