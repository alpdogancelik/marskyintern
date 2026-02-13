class WalletFeeCalculator {
  const WalletFeeCalculator._();

  static double depositFee(double amount) {
    if (amount >= 500) {
      return 0;
    }
    return _round((amount * 0.005).clamp(0.5, 6).toDouble());
  }

  static double withdrawFee(double amount) {
    return _round((amount * 0.01).clamp(1.5, 18).toDouble());
  }

  static double transferFee(double amount) {
    return _round((amount * 0.003).clamp(0, 4).toDouble());
  }

  static double _round(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}
