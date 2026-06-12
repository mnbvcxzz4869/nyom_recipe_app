String isoWeekKey(String dateKey) {
  final date = DateTime.parse(dateKey);

  final thursday = date.add(Duration(days: 4 - date.weekday));

  final jan4 = DateTime(thursday.year, 1, 4);
  final firstMondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));

  final weekNumber = (thursday.difference(firstMondayOfWeek1).inDays ~/ 7) + 1;

  return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
}

String todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
