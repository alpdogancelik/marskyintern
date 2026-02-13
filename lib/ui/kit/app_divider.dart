import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  const AppDivider(
      {super.key, this.margin = const EdgeInsets.symmetric(vertical: 12)});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      height: 1,
      color: colors.outlineVariant,
    );
  }
}
