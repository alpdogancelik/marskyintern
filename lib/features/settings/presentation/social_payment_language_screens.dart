import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/settings_models.dart';
import '../widgets/settings_widgets.dart';
import 'settings_controller.dart';

class SocialLinksScreen extends ConsumerWidget {
  const SocialLinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    return SettingsPageScaffold(
      title: 'Link Account',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SettingsErrorCard(
          message: error.toString(),
          onRetry: () => ref.read(settingsControllerProvider.notifier).load(),
        ),
        data: (data) => AppCard(
          padding: const EdgeInsets.all(AppTokens.space2),
          child: Column(
            children: data.socialLinks
                .map(
                  (link) => SettingsMenuTile(
                    title: link.provider,
                    iconName: _socialIcon(link.provider),
                    subtitle: link.connected
                        ? 'Connected ${link.handle}'
                        : 'Connect your account',
                    trailingText: link.connected ? 'Connected' : 'Connect',
                    fallbackIcon: link.connected
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    onTap: () => _connect(context, ref, link.provider),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  Future<void> _connect(
    BuildContext context,
    WidgetRef ref,
    String provider,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect $provider'),
        content: const Text('Simulated connect flow. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    await ref.read(settingsControllerProvider.notifier).connectSocial(provider);
  }

  String _socialIcon(String provider) {
    return switch (provider.toLowerCase()) {
      'facebook' => 'cloud-money',
      'instagram' => 'gift-box',
      'twitter' => 'announcement',
      'google' => 'searching',
      'apple' => 'digital-token',
      _ => 'chain',
    };
  }
}

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    return SettingsPageScaffold(
      title: 'Payment Method',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SettingsErrorCard(
          message: error.toString(),
          onRetry: () => ref.read(settingsControllerProvider.notifier).load(),
        ),
        data: (data) {
          final defaultBankId = data.bankAccounts
              .where((item) => item.isDefault)
              .map((item) => item.id)
              .cast<String?>()
              .firstOrNull;
          final defaultCardId = data.cardMethods
              .where((item) => item.isDefault)
              .map((item) => item.id)
              .cast<String?>()
              .firstOrNull;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bank Transfer',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppTokens.space2),
              AppCard(
                padding: const EdgeInsets.all(AppTokens.space2),
                child: RadioGroup<String>(
                  groupValue: defaultBankId,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setDefaultBankAccount(value);
                    }
                  },
                  child: Column(
                    children: data.bankAccounts
                        .map(
                          (bank) => RadioListTile<String>(
                            value: bank.id,
                            title: Text(bank.bankName),
                            subtitle: Text(bank.accountNumberMasked),
                            secondary:
                                const Icon(Icons.account_balance_rounded),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              Text(
                'Credit / Debit Card',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppTokens.space2),
              AppCard(
                padding: const EdgeInsets.all(AppTokens.space2),
                child: RadioGroup<String>(
                  groupValue: defaultCardId,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setDefaultCard(value);
                    }
                  },
                  child: Column(
                    children: data.cardMethods
                        .map(
                          (card) => RadioListTile<String>(
                            value: card.id,
                            title: Text('${card.brand} **** ${card.last4}'),
                            subtitle: Text('Expiry ${card.expiry}'),
                            secondary: const Icon(Icons.credit_card_rounded),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              SecondaryButton(
                label: 'Add Card',
                leading: const Icon(Icons.add_rounded),
                onPressed: () =>
                    context.push('/account/payment-methods/add-card'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _postalController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Add Card',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _cardController,
            label: 'Card number',
            hint: '1234 1234 1234 1234',
            keyboardType: TextInputType.number,
            leading: const Icon(Icons.credit_card_rounded),
          ),
          const SizedBox(height: AppTokens.space3),
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  controller: _expiryController,
                  label: 'Expiration',
                  hint: 'MM/YY',
                  keyboardType: TextInputType.number,
                  leading: const Icon(Icons.calendar_month_rounded),
                ),
              ),
              const SizedBox(width: AppTokens.space2),
              Expanded(
                child: AuthTextField(
                  controller: _cvcController,
                  label: 'CVC',
                  hint: '123',
                  keyboardType: TextInputType.number,
                  leading: const Icon(Icons.lock_outline_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space3),
          AuthTextField(
            controller: _postalController,
            label: 'Postal code',
            hint: '90210',
            keyboardType: TextInputType.number,
            leading: const Icon(Icons.pin_drop_outlined),
          ),
          const SizedBox(height: AppTokens.space5),
          PrimaryButton(
            label: 'Add Card',
            onPressed: _addCard,
          ),
        ],
      ),
    );
  }

  Future<void> _addCard() async {
    final cardNumber = _cardController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cardNumber.length < 12 ||
        _expiryController.text.trim().isEmpty ||
        _cvcController.text.trim().length < 3) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Enter valid card details')));
      return;
    }

    final brand = switch (cardNumber.substring(0, 1)) {
      '4' => 'Visa',
      '5' => 'Mastercard',
      _ => 'Card',
    };
    final method = CardMethod(
      id: 'card_${DateTime.now().microsecondsSinceEpoch}',
      brand: brand,
      last4: cardNumber.substring(cardNumber.length - 4),
      expiry: _expiryController.text.trim(),
      isDefault: false,
    );
    await ref.read(settingsControllerProvider.notifier).addCardMethod(method);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Card added')));
    Navigator.of(context).maybePop();
  }
}

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String _query = '';
  String? _selectedCode;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);
    return SettingsPageScaffold(
      title: 'Language',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SettingsErrorCard(
          message: error.toString(),
          onRetry: () => ref.read(settingsControllerProvider.notifier).load(),
        ),
        data: (data) {
          _selectedCode ??= data.languageCode;
          final items = data.languages
              .where(
                (lang) =>
                    _query.isEmpty ||
                    lang.label.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList(growable: false);
          return Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Search language',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              AppCard(
                padding: const EdgeInsets.all(AppTokens.space2),
                child: RadioGroup<String>(
                  groupValue: _selectedCode,
                  onChanged: (value) => setState(() => _selectedCode = value),
                  child: Column(
                    children: items
                        .map(
                          (lang) => RadioListTile<String>(
                            value: lang.code,
                            title: Text(lang.label),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space5),
              PrimaryButton(
                label: 'Change language',
                onPressed: () => _saveLanguage(ref),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveLanguage(WidgetRef ref) async {
    final code = _selectedCode;
    if (code == null) {
      return;
    }
    await ref.read(settingsControllerProvider.notifier).updateLanguage(code);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Language updated')));
    Navigator.of(context).maybePop();
  }
}

class PushNotificationsScreen extends ConsumerWidget {
  const PushNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    return SettingsPageScaffold(
      title: 'Notifications',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SettingsErrorCard(
          message: error.toString(),
          onRetry: () => ref.read(settingsControllerProvider.notifier).load(),
        ),
        data: (data) {
          final prefs = data.notificationPrefs;
          return AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space3,
              vertical: AppTokens.space2,
            ),
            child: Column(
              children: [
                _NotificationSwitchRow(
                  title: 'News',
                  subtitle: 'Receive notification for news',
                  value: prefs.news,
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .updateNotificationPrefs(prefs.copyWith(news: value)),
                ),
                _NotificationSwitchRow(
                  title: 'Promotion',
                  subtitle: 'Receive notification for promotion',
                  value: prefs.promotion,
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .updateNotificationPrefs(
                          prefs.copyWith(promotion: value)),
                ),
                _NotificationSwitchRow(
                  title: 'Community',
                  subtitle: 'Get updates from our community',
                  value: prefs.community,
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .updateNotificationPrefs(
                          prefs.copyWith(community: value)),
                ),
                _NotificationSwitchRow(
                  title: 'Telegram',
                  subtitle: 'Get notifications through Telegram',
                  value: prefs.telegram,
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .updateNotificationPrefs(prefs.copyWith(telegram: value)),
                ),
                _NotificationSwitchRow(
                  title: 'Email',
                  subtitle: 'Get notifications through Email',
                  value: prefs.email,
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .updateNotificationPrefs(prefs.copyWith(email: value)),
                ),
                _NotificationSwitchRow(
                  title: 'Whatsapp',
                  subtitle: 'Get notifications through Whatsapp',
                  value: prefs.whatsapp,
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .updateNotificationPrefs(prefs.copyWith(whatsapp: value)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationSwitchRow extends StatelessWidget {
  const _NotificationSwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SettingsErrorCard extends StatelessWidget {
  const _SettingsErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Unable to load settings',
      description: message,
      illustrationName: 'man-with-a-wrench-can-fix-anything',
      primaryAction: EmptyStateAction(label: 'Retry', onPressed: onRetry),
    );
  }
}

extension _IterableFirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
