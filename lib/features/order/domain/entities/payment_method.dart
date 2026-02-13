enum PaymentMethodType { bankTransfer, card, ewallet }

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.feePercent,
  });

  final String id;
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final String iconName;
  final double feePercent;
}
