import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/water_log.dart';
import '../services/log_service.dart';
import 'auth_provider.dart';

// Today's water logs
final todayWaterLogsProvider = FutureProvider<List<WaterLog>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return LogService.getTodayWaterLogs(user.id);
});

// Today's water summary
final todayWaterSummaryProvider = FutureProvider<WaterSummary>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return WaterSummary(date: DateTime.now());
  return LogService.getDailyWaterSummary(user.id, DateTime.now());
});

// Weekly water summaries (last 7 days including today, oldest first)
final weeklyWaterLogsProvider =
    FutureProvider<List<WaterSummary>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return LogService.getWaterSummariesForRange(user.id, 7);
});

// Monthly water summaries (last 30 days, oldest first)
final monthlyWaterLogsProvider =
    FutureProvider<List<WaterSummary>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return LogService.getWaterSummariesForRange(user.id, 30);
});

// Water progress (0.0 to 1.0+)
final waterProgressProvider = Provider<double>((ref) {
  final summaryAsync = ref.watch(todayWaterSummaryProvider);
  final user = ref.watch(currentUserProvider);
  final goal = user?.waterGoal ?? 2000;
  
  return summaryAsync.when(
    data: (summary) => summary.totalMl / goal,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
