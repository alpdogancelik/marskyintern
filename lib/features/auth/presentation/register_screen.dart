import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'auth_controller.dart';
import 'widgets/auth_shared_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _submitted = false;
  String? _formError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    final emailError =
        _submitted ? _validateEmail(_emailController.text) : null;
    final passwordError =
        _submitted ? _validatePassword(_passwordController.text) : null;
    final termsError = _submitted && !_acceptedTerms
        ? 'Please accept the Terms & Policy.'
        : null;
    final isFormValid = _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        _acceptedTerms;

    return AuthScaffold(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: AuthBrandMark()),
            const SizedBox(height: AppTokens.space4),
            Text(
              'Create your account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 30,
                  ),
            ),
            const SizedBox(height: AppTokens.space2),
            Text(
              'Let\u2019s get started with your free financial account.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTokens.space6),
            AuthTextField(
              controller: _nameController,
              enabled: !isLoading,
              label: 'Full name (optional)',
              hint: 'Jane Thomas',
              textInputAction: TextInputAction.next,
              leading: const Icon(Icons.person_outline, size: 20),
              autofillHints: const [AutofillHints.name],
              onChanged: (_) => _handleInputChange(),
            ),
            const SizedBox(height: AppTokens.space4),
            AuthTextField(
              controller: _emailController,
              enabled: !isLoading,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              leading: const Icon(Icons.alternate_email_rounded, size: 20),
              autofillHints: const [AutofillHints.email],
              errorText: emailError,
              onChanged: (_) => _handleInputChange(),
            ),
            const SizedBox(height: AppTokens.space4),
            AuthTextField(
              controller: _passwordController,
              enabled: !isLoading,
              label: 'Password',
              hint: 'Minimum 8 characters',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              leading: const Icon(Icons.lock_outline, size: 20),
              autofillHints: const [AutofillHints.newPassword],
              errorText: passwordError,
              trailing: IconButton(
                onPressed: isLoading
                    ? null
                    : () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
              ),
              onSubmitted: (_) => _submit(isFormValid),
              onChanged: (_) => _handleInputChange(),
            ),
            const SizedBox(height: AppTokens.space4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: isLoading
                      ? null
                      : (value) =>
                          setState(() => _acceptedTerms = value ?? false),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: const [
                          TextSpan(
                              text:
                                  'I certify that I\u2019m 18 years old and accept the '),
                          TextSpan(
                            text: 'Terms & Policy.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (termsError != null) ...[
              InlineErrorText(termsError),
              const SizedBox(height: AppTokens.space3),
            ],
            if (_formError != null) ...[
              InlineErrorText(_formError!),
              const SizedBox(height: AppTokens.space3),
            ],
            PrimaryButton(
              label: 'Sign up',
              onPressed:
                  isFormValid && !isLoading ? () => _submit(isFormValid) : null,
              isLoading: isLoading,
            ),
            const SizedBox(height: AppTokens.space6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/auth/login'),
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(
                        AppTokens.minTapTarget, AppTokens.minTapTarget),
                  ),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
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
        await ref.read(authControllerProvider.notifier).signUpWithEmailPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              data: _nameController.text.trim().isEmpty
                  ? null
                  : <String, dynamic>{'full_name': _nameController.text.trim()},
            );

    if (!mounted) {
      return;
    }

    if (!result.success) {
      setState(() => _formError = result.message);
      _showMessage(result.message ?? 'Sign up failed. Please try again.');
      return;
    }

    if (result.requiresVerification) {
      context.go(
        '/auth/verify?email=${Uri.encodeComponent(_emailController.text.trim())}',
      );
    }
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

  String? _validatePassword(String value) {
    if (value.trim().isEmpty) {
      return 'Password is required.';
    }
    if (value.trim().length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
