import 'package:flutter/material.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';

class WalletFlowScaffold extends StatelessWidget {
  const WalletFlowScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomCtaLabel,
    this.onBottomCtaPressed,
    this.ctaLoading = false,
  });

  final String title;
  final Widget body;
  final String? bottomCtaLabel;
  final VoidCallback? onBottomCtaPressed;
  final bool ctaLoading;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
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
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pageHorizontalPadding,
                AppTokens.space4,
                AppTokens.pageHorizontalPadding,
                AppTokens.space4,
              ).copyWith(bottom: AppTokens.space4 + bottomInset),
              child: body,
            ),
          ),
          if (bottomCtaLabel != null)
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
                label: bottomCtaLabel!,
                onPressed: onBottomCtaPressed,
                isLoading: ctaLoading,
              ),
            ),
        ],
      ),
    );
  }
}
