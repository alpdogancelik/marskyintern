class PromoCode {
  const PromoCode({
    required this.code,
    required this.title,
    this.discountPercent,
    this.discountAmount,
  });

  final String code;
  final String title;
  final double? discountPercent;
  final double? discountAmount;

  double discountFor(double subtotal) {
    if (subtotal <= 0) {
      return 0;
    }
    if (discountPercent != null) {
      return subtotal * (discountPercent! / 100);
    }
    if (discountAmount != null) {
      return discountAmount!;
    }
    return 0;
  }
}
