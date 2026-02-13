String formatUsd(double value) {
  final negative = value < 0;
  final absolute = value.abs();
  final fixed = absolute.toStringAsFixed(2);
  final parts = fixed.split('.');
  final withCommas = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${negative ? '-' : ''}\$$withCommas.${parts.last}';
}

String formatQuantity(double value, {int decimals = 4}) {
  final fixed = value.toStringAsFixed(decimals);
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
