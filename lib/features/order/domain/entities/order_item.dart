class OrderItem {
  const OrderItem({
    required this.symbol,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String type = 'crypto';
  final String symbol;
  final String name;
  final double unitPrice;
  final double quantity;

  double get subtotal => unitPrice * quantity;

  OrderItem copyWith({
    String? symbol,
    String? name,
    double? unitPrice,
    double? quantity,
  }) {
    return OrderItem(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
