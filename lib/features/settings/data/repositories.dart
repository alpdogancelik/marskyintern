import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../domain/entities/settings_models.dart';
import '../domain/repositories/settings_repositories.dart';

final accountLocalStoreProvider = Provider<AccountLocalStore>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AccountLocalStore(client);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final store = ref.watch(accountLocalStoreProvider);
  final client = ref.watch(supabaseClientProvider);
  return LocalProfileRepository(store: store, client: client);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final store = ref.watch(accountLocalStoreProvider);
  return LocalSettingsRepository(store);
});

final bankAccountsRepositoryProvider = Provider<BankAccountsRepository>((ref) {
  final store = ref.watch(accountLocalStoreProvider);
  return LocalBankAccountsRepository(store);
});

final paymentMethodsRepositoryProvider =
    Provider<PaymentMethodsRepository>((ref) {
  final store = ref.watch(accountLocalStoreProvider);
  return LocalPaymentMethodsRepository(store);
});

final socialLinksRepositoryProvider = Provider<SocialLinksRepository>((ref) {
  final store = ref.watch(accountLocalStoreProvider);
  return LocalSocialLinksRepository(store);
});

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  final store = ref.watch(accountLocalStoreProvider);
  final client = ref.watch(supabaseClientProvider);
  return LocalReferralRepository(store: store, client: client);
});

class AccountLocalStore {
  AccountLocalStore(this._client);

  static const _boxName = 'account_settings_store';
  final SupabaseClient _client;

  Future<dynamic> read(
    String key, {
    dynamic defaultValue,
  }) async {
    final box = await _openBox();
    return box.get(_scopedKey(key), defaultValue: defaultValue);
  }

  Future<void> write(String key, dynamic value) async {
    final box = await _openBox();
    await box.put(_scopedKey(key), value);
  }

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return Hive.openBox<dynamic>(_boxName);
  }

  String _scopedKey(String key) => '${_userScope}_$key';

  String get _userScope => _client.auth.currentUser?.id ?? 'guest';
}

class LocalProfileRepository implements ProfileRepository {
  LocalProfileRepository({
    required AccountLocalStore store,
    required SupabaseClient client,
  })  : _store = store,
        _client = client;

  static const _profileKey = 'profile';

  final AccountLocalStore _store;
  final SupabaseClient _client;

  @override
  Future<UserProfile> getProfile() async {
    final user = _client.auth.currentUser;
    final raw =
        await _store.read(_profileKey, defaultValue: <String, dynamic>{});
    final map =
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    final userMeta = user?.userMetadata ?? const <String, dynamic>{};
    return UserProfile(
      name: (map['name'] as String?) ??
          (userMeta['full_name'] as String?) ??
          user?.email?.split('@').first ??
          'Jerry Thomas',
      email: (map['email'] as String?) ?? user?.email ?? 'user@example.com',
      phone: (map['phone'] as String?) ??
          (userMeta['phone'] as String?) ??
          '+1 234 1234 123',
      avatarUrl:
          (map['avatarUrl'] as String?) ?? (userMeta['avatar_url'] as String?),
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _store.write(_profileKey, profile.toJson());
    try {
      await _client.auth.updateUser(
        UserAttributes(
          data: <String, dynamic>{
            'full_name': profile.name,
            'phone': profile.phone,
            if (profile.avatarUrl != null) 'avatar_url': profile.avatarUrl,
          },
        ),
      );
    } catch (_) {
      // Keep local profile edits resilient even when auth metadata update fails.
    }
  }
}

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._store);

  static const _prefsKey = 'notification_prefs';
  static const _languageKey = 'language_code';
  final AccountLocalStore _store;

  @override
  Future<NotificationPrefs> getNotificationPrefs() async {
    final raw = await _store.read(_prefsKey);
    if (raw is Map) {
      return NotificationPrefs.fromJson(Map<String, dynamic>.from(raw));
    }
    return NotificationPrefs.defaults();
  }

  @override
  Future<void> saveNotificationPrefs(NotificationPrefs prefs) async {
    await _store.write(_prefsKey, prefs.toJson());
  }

  @override
  Future<String> getLanguageCode() async {
    final raw = await _store.read(_languageKey, defaultValue: 'en_US');
    return raw is String ? raw : 'en_US';
  }

  @override
  Future<void> saveLanguageCode(String code) async {
    await _store.write(_languageKey, code);
  }
}

class LocalBankAccountsRepository implements BankAccountsRepository {
  LocalBankAccountsRepository(this._store);

  static const _banksKey = 'bank_accounts';
  final AccountLocalStore _store;

  @override
  Future<List<BankAccount>> getBankAccounts() async {
    final raw = await _store.read(_banksKey, defaultValue: <dynamic>[]);
    final list = raw is List ? raw : const <dynamic>[];
    if (list.isEmpty) {
      return const <BankAccount>[
        BankAccount(
          id: 'bank_1',
          bankName: 'Bank of America',
          accountNumberMasked: '**** **** 2731',
          type: BankAccountType.checking,
          accountHolder: 'Jerry Thomas',
          isDefault: true,
        ),
        BankAccount(
          id: 'bank_2',
          bankName: 'Barclays',
          accountNumberMasked: '**** **** 9807',
          type: BankAccountType.savings,
          accountHolder: 'Jerry Thomas',
          isDefault: false,
        ),
      ];
    }
    return list
        .whereType<Map>()
        .map((item) => BankAccount.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> saveBankAccounts(List<BankAccount> accounts) async {
    await _store.write(
      _banksKey,
      accounts.map((item) => item.toJson()).toList(growable: false),
    );
  }
}

class LocalPaymentMethodsRepository implements PaymentMethodsRepository {
  LocalPaymentMethodsRepository(this._store);

  static const _cardsKey = 'card_methods';
  final AccountLocalStore _store;

  @override
  Future<List<CardMethod>> getCardMethods() async {
    final raw = await _store.read(_cardsKey, defaultValue: <dynamic>[]);
    final list = raw is List ? raw : const <dynamic>[];
    if (list.isEmpty) {
      return const <CardMethod>[
        CardMethod(
          id: 'card_1',
          brand: 'Visa',
          last4: '4567',
          expiry: '12/26',
          isDefault: true,
        ),
        CardMethod(
          id: 'card_2',
          brand: 'Mastercard',
          last4: '5544',
          expiry: '09/27',
          isDefault: false,
        ),
      ];
    }
    return list
        .whereType<Map>()
        .map((item) => CardMethod.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> saveCardMethods(List<CardMethod> methods) async {
    await _store.write(
      _cardsKey,
      methods.map((item) => item.toJson()).toList(growable: false),
    );
  }
}

class LocalSocialLinksRepository implements SocialLinksRepository {
  LocalSocialLinksRepository(this._store);

  static const _socialKey = 'social_links';
  final AccountLocalStore _store;

  @override
  Future<List<SocialLink>> getSocialLinks() async {
    final raw = await _store.read(_socialKey, defaultValue: <dynamic>[]);
    final list = raw is List ? raw : const <dynamic>[];
    if (list.isEmpty) {
      return const <SocialLink>[
        SocialLink(provider: 'Facebook', connected: false, handle: ''),
        SocialLink(provider: 'Instagram', connected: false, handle: ''),
        SocialLink(provider: 'Twitter', connected: false, handle: ''),
        SocialLink(provider: 'Google', connected: false, handle: ''),
        SocialLink(provider: 'Apple', connected: false, handle: ''),
      ];
    }
    return list
        .whereType<Map>()
        .map((item) => SocialLink.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> saveSocialLinks(List<SocialLink> links) async {
    await _store.write(
      _socialKey,
      links.map((item) => item.toJson()).toList(growable: false),
    );
  }
}

class LocalReferralRepository implements ReferralRepository {
  LocalReferralRepository({
    required AccountLocalStore store,
    required SupabaseClient client,
  })  : _store = store,
        _client = client;

  static const _codeKey = 'referral_code';

  final AccountLocalStore _store;
  final SupabaseClient _client;

  @override
  Future<String> getReferralCode() async {
    final raw = await _store.read(_codeKey);
    if (raw is String && raw.trim().isNotEmpty) {
      return raw;
    }

    final userId = _client.auth.currentUser?.id ?? 'guest';
    final seeded = userId.replaceAll('-', '').toUpperCase();
    final suffix = seeded.isEmpty
        ? '${Random().nextInt(9000) + 1000}'
        : seeded.substring(0, min(6, seeded.length));
    final code = 'MARSKY-$suffix';
    await _store.write(_codeKey, code);
    return code;
  }

  @override
  String buildShareText(String code) {
    return 'Join me on Marsky with referral code $code and start investing smarter.';
  }
}
