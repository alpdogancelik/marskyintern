import '../entities/settings_models.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> saveProfile(UserProfile profile);
}

abstract class SettingsRepository {
  Future<NotificationPrefs> getNotificationPrefs();
  Future<void> saveNotificationPrefs(NotificationPrefs prefs);
  Future<String> getLanguageCode();
  Future<void> saveLanguageCode(String code);
}

abstract class BankAccountsRepository {
  Future<List<BankAccount>> getBankAccounts();
  Future<void> saveBankAccounts(List<BankAccount> accounts);
}

abstract class PaymentMethodsRepository {
  Future<List<CardMethod>> getCardMethods();
  Future<void> saveCardMethods(List<CardMethod> methods);
}

abstract class SocialLinksRepository {
  Future<List<SocialLink>> getSocialLinks();
  Future<void> saveSocialLinks(List<SocialLink> links);
}

abstract class ReferralRepository {
  Future<String> getReferralCode();
  String buildShareText(String code);
}
