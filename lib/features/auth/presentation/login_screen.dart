import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/env/env.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'auth_controller.dart';
import 'widgets/auth_shared_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _submitted = false;
  String? _formError;

  @override
  void dispose() {
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
    final isFormValid = _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null;
    final showStubSocialActions = Env.enableDevStubFlows;

    return AuthScaffold(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: AuthBrandMark()),
            const SizedBox(height: AppTokens.space4),
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 30,
                  ),
            ),
            const SizedBox(height: AppTokens.space2),
            Text(
              'Sign in to your account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTokens.space6),
            AuthTextField(
              controller: _emailController,
              enabled: !isLoading,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              leading: const AppIcon(
                name: 'bitcoin-mail',
                semanticLabel: 'Email icon',
                size: 20,
              ),
              autofillHints: const [AutofillHints.email],
              errorText: emailError,
              onChanged: (_) => _handleInputChange(),
            ),
            const SizedBox(height: AppTokens.space4),
            AuthTextField(
              controller: _passwordController,
              enabled: !isLoading,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              leading: const AppIcon(
                name: 'lock',
                semanticLabel: 'Password icon',
                size: 20,
              ),
              autofillHints: const [AutofillHints.password],
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
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              ),
              onSubmitted: (_) => _submit(isFormValid),
              onChanged: (_) => _handleInputChange(),
            ),
            const SizedBox(height: AppTokens.space3),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: isLoading
                      ? null
                      : (value) => setState(() => _rememberMe = value ?? true),
                ),
                const Text('Remember me'),
                const Spacer(),
                TextButton(
                  onPressed:
                      isLoading ? null : () => context.push('/auth/forgot'),
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            if (_formError != null) ...[
              InlineErrorText(_formError!),
              const SizedBox(height: AppTokens.space3),
            ],
            PrimaryButton(
              label: 'Sign in',
              onPressed:
                  isFormValid && !isLoading ? () => _submit(isFormValid) : null,
              isLoading: isLoading,
              semanticLabel: 'Sign in to account',
            ),
            const SizedBox(height: AppTokens.space5),
            if (showStubSocialActions) ...[
              const AuthDividerText(text: 'Or sign in with'),
              const SizedBox(height: AppTokens.space5),
              SocialButton(
                label: 'Continue with Apple',
                icon: const Icon(Icons.apple, size: 20),
                onPressed: () => _showMessage('Coming soon'),
              ),
              const SizedBox(height: AppTokens.space3),
              SocialButton(
                label: 'Continue with Google',
                icon: const GoogleGlyph(),
                onPressed: () => _showMessage('Coming soon'),
              ),
              const SizedBox(height: AppTokens.space6),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\u2019t have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed:
                      isLoading ? null : () => context.go('/auth/signup'),
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(
                        AppTokens.minTapTarget, AppTokens.minTapTarget),
                  ),
                  child: const Text('Sign Up'),
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
        await ref.read(authControllerProvider.notifier).signInWithEmailPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

    if (!mounted) {
      return;
    }

    if (!result.success) {
      setState(() => _formError = result.message);
      if (result.message != null) {
        _showMessage(result.message!);
      }
    }
  }

  void _handleInputChange() {
    if (!_submitted && _formError == null) {
      return;
    }
    setState(() {
      _formError = null;
    });
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
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
