enum WalletPaymentMethodType { bankTransfer, card }

class WalletPaymentMethod {
  const WalletPaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.iconName,
  });

  final String id;
  final WalletPaymentMethodType type;
  final String title;
  final String subtitle;
  final String iconName;
}
