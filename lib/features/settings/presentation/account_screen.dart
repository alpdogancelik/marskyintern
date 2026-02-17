import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../settings/theme/theme_mode_controller.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/entities/settings_models.dart';
import '../widgets/settings_widgets.dart';
import 'profile_controller.dart';
import 'settings_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final settingsValue = ref.watch(settingsControllerProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return SettingsPageScaffold(
      title: 'Settings',
      child: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorCard(
          message: error.toString(),
          onRetry: () => ref.read(profileControllerProvider.notifier).load(),
        ),
        data: (profileData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeaderCard(
                profile: profileData.profile,
                onEdit: () => context.push('/account/personal/edit'),
              ),
              const SizedBox(height: AppTokens.space5),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: AppTokens.space2),
                child: Column(
                  children: [
                    SettingTile(
                      icon: Icons.group_add_outlined,
                      label: 'Invite friends',
                      subtitle: 'Invite friends and get 50 coins',
                      onTap: () => context.push('/account/referral'),
                    ),
                    SettingTile(
                      icon: Icons.person_outline_rounded,
                      label: 'My Account',
                      onTap: () => context.push('/account/personal'),
                    ),
                    SettingTile(
                      icon: Icons.credit_card_outlined,
                      label: 'Billing / Payment',
                      onTap: () => context.push('/account/payment-methods'),
                    ),
                    SettingTile(
                      icon: Icons.support_agent_outlined,
                      label: 'FAQ & Support',
                      onTap: () => context.push('/account/help'),
                    ),
                    SettingTile(
                      icon: Icons.verified_user_outlined,
                      label: 'Identity Verification',
                      onTap: () => context.push('/account/verify-identity'),
                    ),
                    SettingTile(
                      icon: Icons.sms_outlined,
                      label: '2-step verification',
                      onTap: () => context.push('/account/two-step'),
                    ),
                    SettingTile(
                      icon: Icons.pin_outlined,
                      label: 'Create New Pin',
                      onTap: () => context.push('/account/create-pin'),
                    ),
                    SettingTile(
                      icon: Icons.lock_reset_outlined,
                      label: 'Reset password',
                      onTap: () => context.push('/account/reset-password'),
                    ),
                    SettingTile(
                      icon: Icons.language_rounded,
                      label: 'Language',
                      subtitle: settingsValue?.languageLabel,
                      onTap: () => context.push('/account/language'),
                    ),
                    SettingTile(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark Mode',
                      trailing: Switch.adaptive(
                        value: isDarkMode,
                        onChanged: (value) => ref
                            .read(themeModeProvider.notifier)
                            .setDarkModeEnabled(value),
                      ),
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .setDarkModeEnabled(!isDarkMode),
                    ),
                    SettingTile(
                      icon: Icons.logout_rounded,
                      label: 'Log out',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }
    await ref.read(authControllerProvider.notifier).signOut();
  }
}

class PersonalDataScreen extends ConsumerWidget {
  const PersonalDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    return SettingsPageScaffold(
      title: 'Personal Data',
      trailing: IconButton(
        tooltip: 'Edit profile',
        onPressed: () => context.push('/account/personal/edit'),
        icon: const Icon(Icons.edit_rounded),
      ),
      child: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorCard(
          message: error.toString(),
          onRetry: () => ref.read(profileControllerProvider.notifier).load(),
        ),
        data: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeaderCard(profile: state.profile),
            const SizedBox(height: AppTokens.space4),
            DataFieldTile(label: 'Full name', value: state.profile.name),
            const SizedBox(height: AppTokens.space2),
            DataFieldTile(label: 'Phone number', value: state.profile.phone),
            const SizedBox(height: AppTokens.space2),
            DataFieldTile(label: 'Email', value: state.profile.email),
            const SizedBox(height: AppTokens.space5),
            PrimaryButton(
              label: 'Edit',
              onPressed: () => context.push('/account/personal/edit'),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalDataEditScreen extends ConsumerStatefulWidget {
  const PersonalDataEditScreen({super.key});

  @override
  ConsumerState<PersonalDataEditScreen> createState() =>
      _PersonalDataEditScreenState();
}

class _PersonalDataEditScreenState
    extends ConsumerState<PersonalDataEditScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;
  String? _nameError;
  String? _emailError;
  String? _phoneError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final profile = state.valueOrNull?.profile;
    if (!_initialized && profile != null) {
      _initialized = true;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
    }

    return SettingsPageScaffold(
      title: 'Edit Personal Data',
      child: profile == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  controller: _nameController,
                  label: 'Full name',
                  hint: 'Your full name',
                  leading: const Icon(Icons.person_outline_rounded),
                  errorText: _nameError,
                ),
                const SizedBox(height: AppTokens.space3),
                AuthTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  hint: '+1 234 1234 123',
                  keyboardType: TextInputType.phone,
                  leading: const Icon(Icons.phone_outlined),
                  errorText: _phoneError,
                ),
                const SizedBox(height: AppTokens.space3),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  leading: const Icon(Icons.mail_outline_rounded),
                  errorText: _emailError,
                ),
                const SizedBox(height: AppTokens.space5),
                PrimaryButton(
                  label: 'Save Change',
                  isLoading: state.valueOrNull?.isSaving ?? false,
                  onPressed: () => _save(profile),
                ),
              ],
            ),
    );
  }

  Future<void> _save(UserProfile current) async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    var valid = true;
    if (name.isEmpty) {
      _nameError = 'Name is required';
      valid = false;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      _emailError = 'Enter a valid email';
      valid = false;
    }
    if (!RegExp(r'^[0-9+ ()-]{7,}$').hasMatch(phone)) {
      _phoneError = 'Enter a valid phone number';
      valid = false;
    }
    if (!valid) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final next = current.copyWith(
      name: name,
      email: email,
      phone: phone,
    );
    final success =
        await ref.read(profileControllerProvider.notifier).save(next);
    if (!mounted) {
      return;
    }
    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.of(context).maybePop();
      return;
    }
    final message =
        ref.read(profileControllerProvider).valueOrNull?.errorMessage ??
            'Unable to save profile';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Something went wrong',
      description: message,
      illustrationName: 'man-with-a-wrench-can-fix-anything',
      primaryAction: EmptyStateAction(label: 'Retry', onPressed: onRetry),
    );
  }
}
