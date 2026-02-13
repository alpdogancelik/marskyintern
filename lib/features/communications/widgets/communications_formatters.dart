String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inSeconds < 45) {
    return 'Now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h';
  }
  if (diff.inDays == 1) {
    return 'Yesterday';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d';
  }
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
}

String formatMessageTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
