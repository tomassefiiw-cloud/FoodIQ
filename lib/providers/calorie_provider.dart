import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calorie_log.dart';
import '../services/log_service.dart';
import 'auth_provider.dart';

// Today's calorie logs
final todayCalorieLogsProvider = FutureProvider<List<CalorieLog>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return LogService.getTodayCalorieLogs(user.id);
});

// Today's calorie summary
final todayCalorieSummaryProvider = FutureProvider<DailySummary>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return DailySummary(date: DateTime.now());
  return LogService.getDailySummary(user.id, DateTime.now());
});

// Calorie progress (0.0 to 1.0+)
final calorieProgressProvider = Provider<double>((ref) {
  final summaryAsync = ref.watch(todayCalorieSummaryProvider);
  final user = ref.watch(currentUserProvider);
  final goal = user?.calorieGoal ?? 2000;
  
  return summaryAsync.when(
    data: (summary) => summary.totalCalories / goal,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Remaining calories
final remainingCaloriesProvider = Provider<double>((ref) {
  final summaryAsync = ref.watch(todayCalorieSummaryProvider);
  final user = ref.watch(currentUserProvider);
  final goal = user?.calorieGoal ?? 2000;
  
  return summaryAsync.when(
    data: (summary) => goal - summary.totalCalories,
    loading: () => goal.toDouble(),
    error: (_, __) => goal.toDouble(),
  );
});

// Weekly logs
final weeklyCalorieLogsProvider = FutureProvider<List<DailySummary>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final summaries = <DailySummary>[];
  final now = DateTime.now();
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    summaries.add(await LogService.getDailySummary(user.id, date));
  }
  return summaries;
});
