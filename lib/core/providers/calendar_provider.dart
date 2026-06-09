import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';

/// The Monday of the user's signup week — used as the Week 1 anchor.
/// Time is stripped to midnight to avoid off-by-one week calculations.
final calendarBaseDateProvider = Provider<DateTime>((ref) {
  final signupDate = ref.watch(userCreatedAtProvider).value;
  final anchor = signupDate ?? DateTime.now();
  final anchorDate = DateTime(anchor.year, anchor.month, anchor.day);
  return anchorDate.subtract(Duration(days: anchorDate.weekday - 1));
});

/// The current week number relative to the user's signup week.
final currentWeekNumberProvider = Provider<int>((ref) {
  final base = ref.watch(calendarBaseDateProvider);
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final todayMonday = todayDate.subtract(Duration(days: todayDate.weekday - 1));
  return ((todayMonday.difference(base).inDays) ~/ 7) + 1;
});