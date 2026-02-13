import '../domain/entities/activity_transaction.dart';

String formatUsd(double value) {
  final negative = value < 0;
  final absolute = value.abs();
  final fixed = absolute.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${negative ? '-' : ''}\$$whole.${parts.last}';
}

String formatCrypto(double value) {
  final fixed = value.toStringAsFixed(6);
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String dayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final difference = today.difference(target).inDays;
  if (difference == 0) {
    return 'Today';
  }
  if (difference == 1) {
    return 'Yesterday';
  }

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String timeLabel(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String statusLabel(ActivityStatus status) {
  return switch (status) {
    ActivityStatus.completed => 'Completed',
    ActivityStatus.pending => 'Pending',
  };
}
