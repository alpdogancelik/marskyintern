import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'auth_controller.dart';

class VerificationCodeScreen extends ConsumerStatefulWidget {
  const VerificationCodeScreen({
    super.key,
    this.email,
  });

  final String? email;

  @override
  ConsumerState<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends ConsumerState<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsLeft = 180;
  bool _isSubmitting = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _controllers.map((controller) => controller.text).join();
    final codeComplete = code.length == 6;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTokens.space2),
          Text(
            'Enter Verification Code',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            widget.email == null
                ? 'Enter the 6-digit code sent to your email.'
                : 'Enter the 6-digit code sent to ${widget.email}.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTokens.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return _OtpCell(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                onChanged: (value) => _onCodeChanged(index, value),
              );
            }),
          ),
          const SizedBox(height: AppTokens.space3),
          Center(
            child: Text(
              _secondsLeft > 0
                  ? 'Resend code ${_formatTimer(_secondsLeft)}'
                  : 'You can resend the code now',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: AppTokens.space6),
          PrimaryButton(
            label: 'Verify',
            onPressed:
                codeComplete && !_isSubmitting ? () => _verifyCode(code) : null,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: AppTokens.space2),
          TextButton(
            onPressed: _secondsLeft > 0 || _isResending ? null : _handleResend,
            child: const Text('Resend Code'),
          ),
          TextButton(
            onPressed: () => context.go('/auth/login'),
            child: const Text('Use Different Email'),
          ),
        ],
      ),
    );
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _handleResend() {
    final email = widget.email?.trim();
    if (email == null || email.isEmpty) {
      _showMessage('Missing email address. Please sign up again.');
      return;
    }
    setState(() => _isResending = true);
    ref
        .read(authControllerProvider.notifier)
        .resendSignupOtp(email: email)
        .then((result) {
      if (!mounted) {
        return;
      }
      if (!result.success) {
        _showMessage(result.message ?? 'Failed to resend verification code.');
        return;
      }
      setState(() => _secondsLeft = 180);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_secondsLeft <= 0) {
          timer.cancel();
          return;
        }
        setState(() => _secondsLeft -= 1);
      });
      _showMessage('Verification code resent.');
    }).whenComplete(() {
      if (mounted) {
        setState(() => _isResending = false);
      }
    });
  }

  Future<void> _verifyCode(String code) async {
    final email = widget.email?.trim();
    if (email == null || email.isEmpty) {
      _showMessage('Missing email address. Please sign up again.');
      return;
    }
    setState(() => _isSubmitting = true);
    final result = await ref.read(authControllerProvider.notifier).verifySignupOtp(
          email: email,
          token: code,
        );
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (!result.success) {
      _showMessage(result.message ?? 'Verification failed. Please try again.');
      return;
    }
    context.go('/app/home');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remain = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remain';
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 42,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            borderSide: BorderSide(color: colors.primary),
          ),
        ),
      ),
    );
  }
}
