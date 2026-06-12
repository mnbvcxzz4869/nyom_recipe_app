import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';

final calendarBaseDateProvider = Provider<DateTime>((ref) {
  final signupDate = ref.watch(userCreatedAtProvider).value;
  final anchor = signupDate ?? DateTime.now();
  final anchorDate = DateTime(anchor.year, anchor.month, anchor.day);
  return anchorDate.subtract(Duration(days: anchorDate.weekday - 1));
});

final currentWeekNumberProvider = Provider<int>((ref) {
  final base = ref.watch(calendarBaseDateProvider);
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final todayMonday = todayDate.subtract(Duration(days: todayDate.weekday - 1));
  return ((todayMonday.difference(base).inDays) ~/ 7) + 1;
});