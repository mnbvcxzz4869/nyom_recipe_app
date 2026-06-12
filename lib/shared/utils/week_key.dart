String isoWeekKey(String dateKey) {
  final date = DateTime.parse(dateKey);

  // Find the Thursday of the same ISO week (Mon=1 … Sun=7).
  // Adding (4 - weekday) shifts any day to its week's Thursday.
  final thursday = date.add(Duration(days: 4 - date.weekday));

  // Jan 4 is always in week 1 of its ISO year.
  final jan4 = DateTime(thursday.year, 1, 4);
  final firstMondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));

  final weekNumber = (thursday.difference(firstMondayOfWeek1).inDays ~/ 7) + 1;

  return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
}

String todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
