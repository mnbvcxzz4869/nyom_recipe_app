/// Returns the ISO 8601 week key for a given date_key string (e.g. "2025-05-28").
/// Output format: "2025-W22"
///
/// ISO week rules:
///   - Week starts on Monday
///   - Week 1 is the week containing the first Thursday of the year
///   - The year in the key is the ISO week-year, which can differ from the
///     calendar year near Jan 1 / Dec 31
String isoWeekKey(String dateKey) {
  final date = DateTime.parse(dateKey);

  // Find the Thursday of the same ISO week (Mon=1 … Sun=7).
  // Adding (4 - weekday) shifts any day to its week's Thursday.
  final thursday = date.add(Duration(days: 4 - date.weekday));

  // Jan 4 is always in week 1 of its ISO year.
  final jan4 = DateTime(thursday.year, 1, 4);
  final firstMondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));

  final weekNumber =
      (thursday.difference(firstMondayOfWeek1).inDays ~/ 7) + 1;

  return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
}