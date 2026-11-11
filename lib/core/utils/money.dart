/// Formats a rupee amount without depending on a locale database.
String formatMoney(num value) {
  final hasPaise = value % 1 != 0;
  return '₹${value.toStringAsFixed(hasPaise ? 2 : 0)}';
}

/// Parses the local demo date format used by mock orders.
String formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$day/$month/$year $hour:$minute $period';
}
