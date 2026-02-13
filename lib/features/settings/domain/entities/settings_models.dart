enum BankAccountType { checking, savings, ewallet }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    Object? avatarUrl = _sentinel,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: identical(avatarUrl, _sentinel)
          ? this.avatarUrl
          : avatarUrl as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class BankAccount {
  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumberMasked,
    required this.type,
    required this.accountHolder,
    required this.isDefault,
  });

  final String id;
  final String bankName;
  final String accountNumberMasked;
  final BankAccountType type;
  final String accountHolder;
  final bool isDefault;

  BankAccount copyWith({
    String? id,
    String? bankName,
    String? accountNumberMasked,
    BankAccountType? type,
    String? accountHolder,
    bool? isDefault,
  }) {
    return BankAccount(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumberMasked: accountNumberMasked ?? this.accountNumberMasked,
      type: type ?? this.type,
      accountHolder: accountHolder ?? this.accountHolder,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'bankName': bankName,
      'accountNumberMasked': accountNumberMasked,
      'type': type.name,
      'accountHolder': accountHolder,
      'isDefault': isDefault,
    };
  }

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: (json['id'] as String?) ?? '',
      bankName: (json['bankName'] as String?) ?? '',
      accountNumberMasked: (json['accountNumberMasked'] as String?) ?? '',
      type: _bankAccountTypeFromString(json['type'] as String?),
      accountHolder: (json['accountHolder'] as String?) ?? '',
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }
}

class CardMethod {
  const CardMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.isDefault,
  });

  final String id;
  final String brand;
  final String last4;
  final String expiry;
  final bool isDefault;

  CardMethod copyWith({
    String? id,
    String? brand,
    String? last4,
    String? expiry,
    bool? isDefault,
  }) {
    return CardMethod(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'brand': brand,
      'last4': last4,
      'expiry': expiry,
      'isDefault': isDefault,
    };
  }

  factory CardMethod.fromJson(Map<String, dynamic> json) {
    return CardMethod(
      id: (json['id'] as String?) ?? '',
      brand: (json['brand'] as String?) ?? '',
      last4: (json['last4'] as String?) ?? '',
      expiry: (json['expiry'] as String?) ?? '',
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }
}

class SocialLink {
  const SocialLink({
    required this.provider,
    required this.connected,
    required this.handle,
  });

  final String provider;
  final bool connected;
  final String handle;

  SocialLink copyWith({
    String? provider,
    bool? connected,
    String? handle,
  }) {
    return SocialLink(
      provider: provider ?? this.provider,
      connected: connected ?? this.connected,
      handle: handle ?? this.handle,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'provider': provider,
      'connected': connected,
      'handle': handle,
    };
  }

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      provider: (json['provider'] as String?) ?? '',
      connected: (json['connected'] as bool?) ?? false,
      handle: (json['handle'] as String?) ?? '',
    );
  }
}

class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.label,
  });

  final String code;
  final String label;
}

class NotificationPrefs {
  const NotificationPrefs({
    required this.news,
    required this.promotion,
    required this.community,
    required this.telegram,
    required this.email,
    required this.whatsapp,
  });

  final bool news;
  final bool promotion;
  final bool community;
  final bool telegram;
  final bool email;
  final bool whatsapp;

  factory NotificationPrefs.defaults() {
    return const NotificationPrefs(
      news: true,
      promotion: false,
      community: true,
      telegram: true,
      email: true,
      whatsapp: false,
    );
  }

  NotificationPrefs copyWith({
    bool? news,
    bool? promotion,
    bool? community,
    bool? telegram,
    bool? email,
    bool? whatsapp,
  }) {
    return NotificationPrefs(
      news: news ?? this.news,
      promotion: promotion ?? this.promotion,
      community: community ?? this.community,
      telegram: telegram ?? this.telegram,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'news': news,
      'promotion': promotion,
      'community': community,
      'telegram': telegram,
      'email': email,
      'whatsapp': whatsapp,
    };
  }

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) {
    return NotificationPrefs(
      news: (json['news'] as bool?) ?? true,
      promotion: (json['promotion'] as bool?) ?? false,
      community: (json['community'] as bool?) ?? true,
      telegram: (json['telegram'] as bool?) ?? true,
      email: (json['email'] as bool?) ?? true,
      whatsapp: (json['whatsapp'] as bool?) ?? false,
    );
  }
}

const _sentinel = Object();

BankAccountType _bankAccountTypeFromString(String? raw) {
  return switch (raw) {
    'savings' => BankAccountType.savings,
    'ewallet' => BankAccountType.ewallet,
    _ => BankAccountType.checking,
  };
}
