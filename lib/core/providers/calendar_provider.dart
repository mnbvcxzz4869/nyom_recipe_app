import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';

final calendarBaseDateProvider = Provider<DateTime?>((ref) {
  final signupAsync = ref.watch(userCreatedAtProvider);
  final signupDate = signupAsync.value;
  if (signupDate == null) return null;
  final anchorDate = DateTime(
    signupDate.year,
    signupDate.month,
    signupDate.day,
  );
  return anchorDate.subtract(Duration(days: anchorDate.weekday - 1));
});

final currentWeekNumberProvider = Provider<int?>((ref) {
  final base = ref.watch(calendarBaseDateProvider);
  if (base == null) return null;
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final todayMonday = todayDate.subtract(Duration(days: todayDate.weekday - 1));
  return ((todayMonday.difference(base).inDays) ~/ 7) + 1;
});
