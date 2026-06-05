import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wellness_log.dart';
import '../services/nutrition_targets.dart';
import 'auth_provider.dart';

/// Active daily macro/calorie/water targets, derived from the user's goal.
/// Re-derives whenever the user's calorie/water goal changes.
final nutritionTargetsProvider = FutureProvider<NutritionTargets>((ref) async {
  final user = ref.watch(currentUserProvider);
  return NutritionTargets.load(
    fallbackCalorieGoal: user?.calorieGoal ?? 2000,
    fallbackWaterMl: user?.waterGoal ?? 2000,
  );
});

/// Today's wellness check-in (mood / stress / energy), if completed.
final todayWellnessProvider = FutureProvider<WellnessCheckin?>((ref) async {
  return WellnessStore.today();
});

/// Recent wellness check-ins for trend display.
final recentWellnessProvider =
    FutureProvider<List<WellnessCheckin>>((ref) async {
  return WellnessStore.recent(days: 7);
});
