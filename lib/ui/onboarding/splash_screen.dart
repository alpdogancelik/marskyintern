import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_icon.dart';
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
  bool _navigated = false;

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
          : const Duration(milliseconds: 1200),
      _goToOnboarding,
    );
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
    final titleStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        );
    return Scaffold(
      backgroundColor: AppTokens.primaryBlue,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _goToOnboarding,
          child: Center(
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon(
                    name: 'digital-token',
                    semanticLabel: 'GoCrypto mark',
                    size: 28,
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Text('GoCrypto', style: titleStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToOnboarding() {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    context.go('/onboarding');
  }
}
