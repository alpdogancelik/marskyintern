String formatUsd(double value) {
  final negative = value < 0;
  final absolute = value.abs();
  final fixed = absolute.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  final decimal = parts.length > 1 ? parts[1] : '00';
  final withCommas = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${negative ? '-' : ''}\$$withCommas.$decimal';
}

String formatQuantity(double value, {int maxDecimals = 6}) {
  final fixed = value.toStringAsFixed(maxDecimals);
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
