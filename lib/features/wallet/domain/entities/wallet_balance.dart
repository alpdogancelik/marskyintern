class WalletBalance {
  const WalletBalance({
    required this.currency,
    required this.available,
    required this.pending,
  });

  final String currency;
  final double available;
  final double pending;

  WalletBalance copyWith({
    String? currency,
    double? available,
    double? pending,
  }) {
    return WalletBalance(
      currency: currency ?? this.currency,
      available: available ?? this.available,
      pending: pending ?? this.pending,
    );
  }
}
