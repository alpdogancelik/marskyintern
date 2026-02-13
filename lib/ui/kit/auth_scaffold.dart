import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_tokens.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.onClose,
    this.closeFallbackRoute = '/get-started-v1',
  });

  final Widget child;
  final VoidCallback? onClose;
  final String closeFallbackRoute;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final insets = MediaQuery.of(context).viewInsets;
    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: AnimatedPadding(
          duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
              ? Duration.zero
              : const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.pageHorizontalPadding,
                  AppTokens.space2,
                  AppTokens.pageHorizontalPadding,
                  AppTokens.space4,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: onClose ?? () => _handleClose(context),
                          tooltip: 'Close authentication',
                          icon: const Icon(Icons.close),
                        ),
                      ),
                      const SizedBox(height: AppTokens.space2),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Container(
                            padding: const EdgeInsets.all(AppTokens.space5),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusXl),
                              border: Border.all(color: colors.outlineVariant),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withValues(alpha: 0.07),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleClose(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    context.go(closeFallbackRoute);
  }
}
