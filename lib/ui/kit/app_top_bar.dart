import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.leading,
    this.trailing,
    this.title,
  });

  final Widget? leading;
  final Widget? trailing;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final titleText = title;
    return SizedBox(
      height: AppTokens.minTapTarget,
      child: Row(
        children: [
          if (leading != null)
            leading!
          else
            const SizedBox(width: AppTokens.minTapTarget),
          if (titleText != null) ...[
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Text(
                titleText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else
            const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
