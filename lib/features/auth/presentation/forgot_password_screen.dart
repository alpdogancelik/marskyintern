import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final emailError =
        _submitted ? _validateEmail(_emailController.text) : null;
    final isFormValid = _validateEmail(_emailController.text) == null;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTokens.space4),
          Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            'Enter your email and we\u2019ll send instructions to reset your password.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.space8),
          AuthTextField(
            controller: _emailController,
            enabled: !isLoading,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            leading: const AppIcon(
              name: 'bitcoin-mail',
              semanticLabel: 'Email icon',
              size: 20,
            ),
            errorText: emailError,
            onChanged: (_) => _handleInputChange(),
            onSubmitted: (_) => _submit(isFormValid),
          ),
          if (_formError != null) ...[
            const SizedBox(height: AppTokens.space3),
            InlineErrorText(_formError!),
          ],
          const SizedBox(height: AppTokens.space6),
          PrimaryButton(
            label: 'Reset Password',
            onPressed:
                isFormValid && !isLoading ? () => _submit(isFormValid) : null,
            isLoading: isLoading,
          ),
          const SizedBox(height: AppTokens.space3),
          TextButton(
            onPressed: isLoading ? null : () => context.go('/auth/login'),
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(bool isFormValid) async {
    setState(() {
      _submitted = true;
      _formError = null;
    });
    if (!isFormValid) {
      return;
    }

    final result =
        await ref.read(authControllerProvider.notifier).resetPassword(
              email: _emailController.text.trim(),
            );

    if (!mounted) {
      return;
    }

    if (!result.success) {
      setState(() => _formError = result.message);
      _showMessage(result.message ?? 'Failed to reset password');
      return;
    }

    context.go('/auth/success');
  }

  void _handleInputChange() {
    if (!_submitted && _formError == null) {
      return;
    }
    setState(() => _formError = null);
    ref.read(authControllerProvider.notifier).clearError();
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Email is required.';
    }
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    if (!isValid) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
