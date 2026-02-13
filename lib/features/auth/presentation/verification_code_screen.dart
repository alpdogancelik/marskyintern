import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({
    super.key,
    this.email,
  });

  final String? email;

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
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
          const SizedBox(height: AppTokens.space4),
          Text(
            'Authentication Code',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            widget.email == null
                ? 'Enter the verification code sent to your email.'
                : 'Enter the verification code sent to ${widget.email}.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
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
          const SizedBox(height: AppTokens.space6),
          PrimaryButton(
            label: 'Continue',
            onPressed:
                codeComplete ? () => context.go('/auth/biometric-face') : null,
          ),
          const SizedBox(height: AppTokens.space2),
          TextButton(
            onPressed: () => _showMessage('Resend Code'),
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

  void _showMessage(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$action coming soon')));
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
