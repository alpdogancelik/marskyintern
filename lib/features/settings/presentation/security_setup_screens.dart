import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../widgets/settings_widgets.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  static const _methods =
      <({String id, String title, String subtitle, IconData icon})>[
    (
      id: 'passport',
      title: 'Passport',
      subtitle: 'Use your passport as identity proof',
      icon: Icons.book_outlined,
    ),
    (
      id: 'identity_card',
      title: 'Identity Card',
      subtitle: 'Use a national identity card',
      icon: Icons.badge_outlined,
    ),
    (
      id: 'digital_document',
      title: 'Digital Document',
      subtitle: 'Upload a government-issued digital document',
      icon: Icons.description_outlined,
    ),
  ];

  String _selectedMethod = _methods.first.id;

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Let\'s verify your identity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your document to verify your identity.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTokens.space4),
          AppCard(
            padding: const EdgeInsets.all(AppTokens.space2),
            child: Column(
              children: _methods
                  .map(
                    (method) => _KycMethodTile(
                      title: method.title,
                      subtitle: method.subtitle,
                      icon: method.icon,
                      selected: _selectedMethod == method.id,
                      onTap: () => setState(() => _selectedMethod = method.id),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: AppTokens.space6),
          PrimaryButton(
            label: 'Continue',
            onPressed: () => context.push('/account/two-step'),
          ),
        ],
      ),
    );
  }
}

class TwoStepVerificationScreen extends StatefulWidget {
  const TwoStepVerificationScreen({super.key});

  @override
  State<TwoStepVerificationScreen> createState() =>
      _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+1';

  static const _countryCodes = <String>['+1', '+44', '+49', '+90', '+971'];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _phoneController.text.trim().length >= 6;

    return SettingsPageScaffold(
      title: 'Set up 2-step verification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your phone number so we can send verification codes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTokens.space4),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  initialValue: _countryCode,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                  ),
                  items: _countryCodes
                      .map(
                        (code) => DropdownMenuItem<String>(
                          value: code,
                          child: Text(code),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _countryCode = value);
                  },
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: AuthTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '555 123 4567',
                  keyboardType: TextInputType.phone,
                  leading: const Icon(Icons.phone_outlined),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space6),
          PrimaryButton(
            label: 'Continue',
            onPressed:
                isValid ? () => context.push('/account/create-pin') : null,
          ),
        ],
      ),
    );
  }
}

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = '';

  static const _digits = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '',
    '0',
    '<'
  ];

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Create New Pin',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Adding a pin number will make your account safer.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTokens.space5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final filled = index < _pin.length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: filled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppTokens.space6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _digits.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppTokens.space2,
              crossAxisSpacing: AppTokens.space2,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              final key = _digits[index];
              if (key.isEmpty) {
                return const SizedBox.shrink();
              }
              final isBackspace = key == '<';

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isBackspace) {
                      if (_pin.isNotEmpty) {
                        _pin = _pin.substring(0, _pin.length - 1);
                      }
                      return;
                    }

                    if (_pin.length < 6) {
                      _pin += key;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: isBackspace
                      ? const Icon(Icons.backspace_outlined)
                      : Text(
                          key,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: AppTokens.space5),
          PrimaryButton(
            label: 'Continue',
            onPressed: _pin.length == 6
                ? () => context.push('/account/reset-password')
                : null,
          ),
        ],
      ),
    );
  }
}

class ResetPasswordRequestScreen extends StatefulWidget {
  const ResetPasswordRequestScreen({super.key});

  @override
  State<ResetPasswordRequestScreen> createState() =>
      _ResetPasswordRequestScreenState();
}

class _ResetPasswordRequestScreenState
    extends State<ResetPasswordRequestScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(_emailController.text.trim());

    return SettingsPageScaffold(
      title: 'Reset password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter the email address you use to sign in.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTokens.space4),
          AuthTextField(
            controller: _emailController,
            label: 'Email address',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            leading: const Icon(Icons.email_outlined),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppTokens.space6),
          PrimaryButton(
            label: 'Continue',
            onPressed: isValid ? _submit : null,
          ),
        ],
      ),
    );
  }

  void _submit() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Reset link sent to ${_emailController.text.trim()}',
          ),
        ),
      );
  }
}

class _KycMethodTile extends StatelessWidget {
  const _KycMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space2,
          vertical: AppTokens.space2,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(icon, size: 18),
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTokens.space2),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
