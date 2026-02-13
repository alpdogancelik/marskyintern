import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_icon.dart';
import '../kit/ui_kit.dart';
import '../theme/app_tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _visible = false;
  bool _isScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isScheduled) {
      return;
    }
    _isScheduled = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _visible = reduceMotion;
    if (!reduceMotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _visible = true);
      });
    }

    _timer = Timer(
        reduceMotion
            ? const Duration(milliseconds: 260)
            : const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AppScaffold(
      child: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: AppIcon(
                    name: 'digital-token',
                    semanticLabel: 'Finix logo mark',
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                'Finix',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
