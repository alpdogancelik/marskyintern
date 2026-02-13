import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/entities/settings_models.dart';
import '../domain/repositories/settings_repositories.dart';

class SettingsState {
  const SettingsState({
    required this.notificationPrefs,
    required this.languageCode,
    required this.languages,
    required this.bankAccounts,
    required this.cardMethods,
    required this.socialLinks,
    required this.referralCode,
    this.isSaving = false,
    this.errorMessage,
  });

  final NotificationPrefs notificationPrefs;
  final String languageCode;
  final List<AppLanguage> languages;
  final List<BankAccount> bankAccounts;
  final List<CardMethod> cardMethods;
  final List<SocialLink> socialLinks;
  final String referralCode;
  final bool isSaving;
  final String? errorMessage;

  String get languageLabel {
    final match = languages.where((item) => item.code == languageCode);
    return match.isNotEmpty ? match.first.label : languageCode;
  }

  BankAccount? bankById(String id) {
    for (final bank in bankAccounts) {
      if (bank.id == id) {
        return bank;
      }
    }
    return null;
  }

  SettingsState copyWith({
    NotificationPrefs? notificationPrefs,
    String? languageCode,
    List<AppLanguage>? languages,
    List<BankAccount>? bankAccounts,
    List<CardMethod>? cardMethods,
    List<SocialLink>? socialLinks,
    String? referralCode,
    bool? isSaving,
    Object? errorMessage = _sentinel,
  }) {
    return SettingsState(
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
      languageCode: languageCode ?? this.languageCode,
      languages: languages ?? this.languages,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      cardMethods: cardMethods ?? this.cardMethods,
      socialLinks: socialLinks ?? this.socialLinks,
      referralCode: referralCode ?? this.referralCode,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _sentinel = Object();

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<SettingsState>>((ref) {
  return SettingsController(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    bankAccountsRepository: ref.watch(bankAccountsRepositoryProvider),
    paymentMethodsRepository: ref.watch(paymentMethodsRepositoryProvider),
    socialLinksRepository: ref.watch(socialLinksRepositoryProvider),
    referralRepository: ref.watch(referralRepositoryProvider),
  )..load();
});

class SettingsController extends StateNotifier<AsyncValue<SettingsState>> {
  SettingsController({
    required SettingsRepository settingsRepository,
    required BankAccountsRepository bankAccountsRepository,
    required PaymentMethodsRepository paymentMethodsRepository,
    required SocialLinksRepository socialLinksRepository,
    required ReferralRepository referralRepository,
  })  : _settingsRepository = settingsRepository,
        _bankAccountsRepository = bankAccountsRepository,
        _paymentMethodsRepository = paymentMethodsRepository,
        _socialLinksRepository = socialLinksRepository,
        _referralRepository = referralRepository,
        super(const AsyncLoading());

  final SettingsRepository _settingsRepository;
  final BankAccountsRepository _bankAccountsRepository;
  final PaymentMethodsRepository _paymentMethodsRepository;
  final SocialLinksRepository _socialLinksRepository;
  final ReferralRepository _referralRepository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final results = await Future.wait<dynamic>([
        _settingsRepository.getNotificationPrefs(),
        _settingsRepository.getLanguageCode(),
        _bankAccountsRepository.getBankAccounts(),
        _paymentMethodsRepository.getCardMethods(),
        _socialLinksRepository.getSocialLinks(),
        _referralRepository.getReferralCode(),
      ]);

      return SettingsState(
        notificationPrefs: results[0] as NotificationPrefs,
        languageCode: results[1] as String,
        languages: _languages,
        bankAccounts: results[2] as List<BankAccount>,
        cardMethods: results[3] as List<CardMethod>,
        socialLinks: results[4] as List<SocialLink>,
        referralCode: results[5] as String,
      );
    });
  }

  Future<void> updateNotificationPrefs(NotificationPrefs prefs) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(notificationPrefs: prefs));
    await _settingsRepository.saveNotificationPrefs(prefs);
  }

  Future<void> updateLanguage(String code) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(languageCode: code));
    await _settingsRepository.saveLanguageCode(code);
  }

  Future<void> addBankAccount(BankAccount account) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    var next = List<BankAccount>.from(current.bankAccounts);
    final shouldBeDefault = next.isEmpty || account.isDefault;
    if (shouldBeDefault) {
      next = next.map((item) => item.copyWith(isDefault: false)).toList();
    }
    next.add(account.copyWith(isDefault: shouldBeDefault));
    await _bankAccountsRepository.saveBankAccounts(next);
    state = AsyncData(current.copyWith(bankAccounts: next));
  }

  Future<void> setDefaultBankAccount(String bankId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final next = current.bankAccounts
        .map((item) => item.copyWith(isDefault: item.id == bankId))
        .toList(growable: false);
    await _bankAccountsRepository.saveBankAccounts(next);
    state = AsyncData(current.copyWith(bankAccounts: next));
  }

  Future<void> removeBankAccount(String bankId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    var next = current.bankAccounts
        .where((item) => item.id != bankId)
        .toList(growable: false);
    if (next.isNotEmpty && !next.any((item) => item.isDefault)) {
      next = [
        next.first.copyWith(isDefault: true),
        ...next.skip(1),
      ];
    }
    await _bankAccountsRepository.saveBankAccounts(next);
    state = AsyncData(current.copyWith(bankAccounts: next));
  }

  Future<void> addCardMethod(CardMethod card) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    var next = List<CardMethod>.from(current.cardMethods);
    final shouldBeDefault = next.isEmpty || card.isDefault;
    if (shouldBeDefault) {
      next = next.map((item) => item.copyWith(isDefault: false)).toList();
    }
    next.add(card.copyWith(isDefault: shouldBeDefault));
    await _paymentMethodsRepository.saveCardMethods(next);
    state = AsyncData(current.copyWith(cardMethods: next));
  }

  Future<void> setDefaultCard(String cardId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final next = current.cardMethods
        .map((item) => item.copyWith(isDefault: item.id == cardId))
        .toList(growable: false);
    await _paymentMethodsRepository.saveCardMethods(next);
    state = AsyncData(current.copyWith(cardMethods: next));
  }

  Future<void> connectSocial(String provider, {String handle = ''}) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final next = current.socialLinks
        .map(
          (item) => item.provider.toLowerCase() == provider.toLowerCase()
              ? item.copyWith(
                  connected: true,
                  handle: handle.isEmpty
                      ? '@${provider.toLowerCase()}_user'
                      : handle,
                )
              : item,
        )
        .toList(growable: false);
    await _socialLinksRepository.saveSocialLinks(next);
    state = AsyncData(current.copyWith(socialLinks: next));
  }

  String referralShareText() {
    final code = state.valueOrNull?.referralCode ?? 'MARSKY-CODE';
    return _referralRepository.buildShareText(code);
  }
}

const List<AppLanguage> _languages = <AppLanguage>[
  AppLanguage(code: 'en_US', label: 'English (USA)'),
  AppLanguage(code: 'en_GB', label: 'English (UK)'),
  AppLanguage(code: 'id_ID', label: 'Indonesia'),
  AppLanguage(code: 'es_ES', label: 'Espanol'),
  AppLanguage(code: 'fr_FR', label: 'Francais'),
  AppLanguage(code: 'it_IT', label: 'Italiano'),
  AppLanguage(code: 'de_DE', label: 'Deutsch'),
  AppLanguage(code: 'pt_BR', label: 'Portugues (BR)'),
];
