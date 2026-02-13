import 'package:flutter/material.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';

class OrderScaffold extends StatelessWidget {
  const OrderScaffold({
    super.key,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCtaPressed,
    this.ctaLoading = false,
  });

  final String title;
  final Widget body;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final bool ctaLoading;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return AppScaffold(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.pageHorizontalPadding,
              AppTokens.space3,
              AppTokens.pageHorizontalPadding,
              0,
            ),
            child: AppTopBar(
              leading: IconButton(
                tooltip: 'Back',
                constraints: const BoxConstraints.tightFor(
                  width: AppTokens.minTapTarget,
                  height: AppTokens.minTapTarget,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: title,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppTokens.pageHorizontalPadding,
                AppTokens.space4,
                AppTokens.pageHorizontalPadding,
                AppTokens.space4 + viewInsets.bottom,
              ),
              child: body,
            ),
          ),
          if (ctaLabel != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pageHorizontalPadding,
                AppTokens.space3,
                AppTokens.pageHorizontalPadding,
                AppTokens.space4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: PrimaryButton(
                label: ctaLabel!,
                onPressed: onCtaPressed,
                isLoading: ctaLoading,
              ),
            ),
        ],
      ),
    );
  }
}
