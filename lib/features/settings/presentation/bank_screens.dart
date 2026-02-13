import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/settings_models.dart';
import '../widgets/settings_widgets.dart';
import 'settings_controller.dart';

class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    return SettingsPageScaffold(
      title: 'Bank Account',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SettingsErrorCard(
          message: error.toString(),
          onRetry: () => ref.read(settingsControllerProvider.notifier).load(),
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.bankAccounts.isEmpty)
              EmptyState(
                title: 'No bank account linked',
                description:
                    'Add your first bank account to withdraw and fund faster.',
                illustrationName:
                    'man-and-a-woman-paid-for-an-international-transfer',
                primaryAction: EmptyStateAction(
                  label: 'Add Bank Account',
                  onPressed: () => context.push('/account/banks/add'),
                ),
              )
            else
              AppCard(
                padding: const EdgeInsets.all(AppTokens.space2),
                child: Column(
                  children: data.bankAccounts
                      .map(
                        (bank) => SettingsMenuTile(
                          title: bank.bankName,
                          subtitle:
                              '${bank.accountNumberMasked}  ${bank.accountHolder}',
                          iconName: 'bank',
                          trailingText: bank.isDefault ? 'Default' : null,
                          onTap: () =>
                              context.push('/account/banks/${bank.id}'),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            const SizedBox(height: AppTokens.space3),
            SecondaryButton(
              label: 'Add Bank Account',
              leading: const Icon(Icons.add_rounded),
              onPressed: () => context.push('/account/banks/add'),
            ),
            const SizedBox(height: AppTokens.space2),
            SecondaryButton(
              label: 'Withdrawal Destination',
              leading: const Icon(Icons.account_balance_wallet_outlined),
              onPressed: () => context.push('/account/withdraw-destination'),
            ),
          ],
        ),
      ),
    );
  }
}

class BankAccountAddScreen extends ConsumerStatefulWidget {
  const BankAccountAddScreen({super.key});

  @override
  ConsumerState<BankAccountAddScreen> createState() =>
      _BankAccountAddScreenState();
}

class _BankAccountAddScreenState extends ConsumerState<BankAccountAddScreen> {
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  String? _selectedBank;
  BankAccountType _type = BankAccountType.checking;
  String? _accountHolderError;
  String? _accountNumberError;
  String? _bankError;

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Add Bank Account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Link your bank',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          SettingsMenuTile(
            title: _selectedBank ?? 'Select bank',
            subtitle: _selectedBank == null
                ? 'Choose withdrawal destination bank'
                : null,
            iconName: 'bank',
            onTap: _selectBank,
          ),
          if (_bankError != null) ...[
            const SizedBox(height: 6),
            InlineErrorText(_bankError!),
          ],
          const SizedBox(height: AppTokens.space3),
          DropdownButtonFormField<BankAccountType>(
            initialValue: _type,
            items: const [
              DropdownMenuItem(
                value: BankAccountType.checking,
                child: Text('Checking'),
              ),
              DropdownMenuItem(
                value: BankAccountType.savings,
                child: Text('Savings'),
              ),
              DropdownMenuItem(
                value: BankAccountType.ewallet,
                child: Text('E-wallet'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          const SizedBox(height: AppTokens.space3),
          AuthTextField(
            controller: _accountHolderController,
            label: 'Account holder',
            hint: 'Jerry Thomas',
            leading: const Icon(Icons.person_outline_rounded),
            errorText: _accountHolderError,
          ),
          const SizedBox(height: AppTokens.space3),
          AuthTextField(
            controller: _accountNumberController,
            label: 'Account number',
            hint: '1234 5678 9012',
            keyboardType: TextInputType.number,
            leading: const Icon(Icons.credit_card_rounded),
            errorText: _accountNumberError,
          ),
          const SizedBox(height: AppTokens.space5),
          PrimaryButton(
            label: 'Confirm',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _selectBank() async {
    final selected =
        await context.push<String>('/account/withdraw-destination?picker=1');
    if (!mounted) {
      return;
    }
    if (selected != null && selected.trim().isNotEmpty) {
      setState(() {
        _selectedBank = selected;
        _bankError = null;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _accountHolderError = null;
      _accountNumberError = null;
      _bankError = null;
    });

    final holder = _accountHolderController.text.trim();
    final digits =
        _accountNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final bank = _selectedBank;

    var valid = true;
    if (bank == null || bank.isEmpty) {
      _bankError = 'Please select a bank';
      valid = false;
    }
    if (holder.isEmpty) {
      _accountHolderError = 'Account holder is required';
      valid = false;
    }
    if (digits.length < 8) {
      _accountNumberError = 'Enter a valid account number';
      valid = false;
    }
    if (!valid) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final masked = '**** **** ${digits.substring(digits.length - 4)}';
    final account = BankAccount(
      id: 'bank_${DateTime.now().microsecondsSinceEpoch}',
      bankName: bank!,
      accountNumberMasked: masked,
      type: _type,
      accountHolder: holder,
      isDefault: false,
    );
    await ref.read(settingsControllerProvider.notifier).addBankAccount(account);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Bank account added')));
    Navigator.of(context).pop();
  }
}

class BankAccountDetailScreen extends ConsumerWidget {
  const BankAccountDetailScreen({
    super.key,
    required this.bankId,
  });

  final String bankId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    return SettingsPageScaffold(
      title: 'Bank Account',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SettingsErrorCard(
          message: error.toString(),
          onRetry: () => ref.read(settingsControllerProvider.notifier).load(),
        ),
        data: (data) {
          final bank = data.bankById(bankId);
          if (bank == null) {
            return EmptyState(
              title: 'Bank account not found',
              description: 'This account was removed or is unavailable.',
              illustrationName:
                  'man-looking-for-someone-to-help-with-a-question',
              primaryAction: EmptyStateAction(
                label: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.bankName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    DataFieldTile(
                        label: 'Account holder', value: bank.accountHolder),
                    const SizedBox(height: AppTokens.space2),
                    DataFieldTile(
                        label: 'Account number',
                        value: bank.accountNumberMasked),
                    const SizedBox(height: AppTokens.space2),
                    DataFieldTile(
                        label: 'Type', value: _bankTypeLabel(bank.type)),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space3,
                  vertical: AppTokens.space2,
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      title: const Text('Default account'),
                      value: bank.isDefault,
                      onChanged: (_) => ref
                          .read(settingsControllerProvider.notifier)
                          .setDefaultBankAccount(bank.id),
                    ),
                    const SizedBox(height: AppTokens.space2),
                    SecondaryButton(
                      label: 'Remove account',
                      onPressed: () => _remove(context, ref, bank.id),
                      leading: const Icon(Icons.delete_outline_rounded),
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

  Future<void> _remove(
      BuildContext context, WidgetRef ref, String bankId) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Remove this bank account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldRemove != true) {
      return;
    }
    await ref
        .read(settingsControllerProvider.notifier)
        .removeBankAccount(bankId);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).maybePop();
  }

  String _bankTypeLabel(BankAccountType type) {
    return switch (type) {
      BankAccountType.checking => 'Checking',
      BankAccountType.savings => 'Savings',
      BankAccountType.ewallet => 'E-wallet',
    };
  }
}

class WithdrawDestinationScreen extends StatefulWidget {
  const WithdrawDestinationScreen({
    super.key,
    required this.pickerMode,
  });

  final bool pickerMode;

  @override
  State<WithdrawDestinationScreen> createState() =>
      _WithdrawDestinationScreenState();
}

class _WithdrawDestinationScreenState extends State<WithdrawDestinationScreen> {
  static const _banks = <String>[
    'Bank of America',
    'Barclays',
    'Chase',
    'Citibank Online',
    'Wells Fargo',
    'U.S Bank',
  ];

  String _query = '';
  String _selected = _banks.first;

  @override
  Widget build(BuildContext context) {
    final filtered = _banks
        .where(
          (bank) =>
              _query.isEmpty ||
              bank.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList(growable: false);
    return SettingsPageScaffold(
      title: 'Withdrawal Destination',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Search bank',
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
              groupValue: _selected,
              onChanged: (value) =>
                  setState(() => _selected = value ?? _selected),
              child: Column(
                children: filtered
                    .map(
                      (bank) => RadioListTile<String>(
                        value: bank,
                        title: Text(bank),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space5),
          PrimaryButton(
            label: 'Confirm',
            onPressed: () {
              if (widget.pickerMode) {
                Navigator.of(context).pop(_selected);
                return;
              }
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Selected $_selected')),
                );
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
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
