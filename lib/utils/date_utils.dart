String formatTimeOfDay(int hour, int minute) {
  final h = hour > 12 ? hour - 12 : hour;
  final ampm = hour >= 12 ? 'PM' : 'AM';
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m $ampm';
}

String formatDateTime(DateTime dateTime) {
  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}
