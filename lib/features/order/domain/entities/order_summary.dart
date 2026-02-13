class OrderSummary {
  const OrderSummary({
    required this.subtotal,
    required this.fees,
    required this.discount,
    required this.total,
  });

  final double subtotal;
  final double fees;
  final double discount;
  final double total;

  static const empty = OrderSummary(
    subtotal: 0,
    fees: 0,
    discount: 0,
    total: 0,
  );
}
