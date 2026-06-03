import 'package:uuid/uuid.dart';
import '../models/calorie_log.dart';
import '../models/food_item.dart' show MealType;
import '../models/water_log.dart';
import 'supabase_service.dart';

class LogService {
  static const _uuid = Uuid();

  // ===== CALORIE LOGS =====
  
  static Future<List<CalorieLog>> getTodayCalorieLogs(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    try {
      final response = await SupabaseService.calorieLogs
          .select()
          .eq('user_id', userId)
          .gte('logged_at', startOfDay.toIso8601String())
          .lt('logged_at', endOfDay.toIso8601String())
          .order('logged_at', ascending: false);

      return response.map<CalorieLog>((json) => CalorieLog.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<CalorieLog>> getCalorieLogsForDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final response = await SupabaseService.calorieLogs
          .select()
          .eq('user_id', userId)
          .gte('logged_at', start.toIso8601String())
          .lt('logged_at', end.toIso8601String())
          .order('logged_at', ascending: false);

      return response.map<CalorieLog>((json) => CalorieLog.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addCalorieLog({
    required String userId,
    required String foodId,
    required String foodName,
    required MealType mealType,
    required double portion,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    double fiber = 0,
    double servingSize = 100,
    String? notes,
  }) async {
    try {
      await SupabaseService.calorieLogs.insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'food_id': foodId,
        'food_name': foodName,
        'meal_type': mealType.name,
        'portion': portion,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'serving_size': servingSize,
        'notes': notes,
        'logged_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteCalorieLog(String logId) async {
    try {
      await SupabaseService.calorieLogs.delete().eq('id', logId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<DailySummary> getDailySummary(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final logs = await getCalorieLogsForDateRange(userId, startOfDay, endOfDay);
    return DailySummary.fromLogs(date, logs);
  }

  // ===== WATER LOGS =====

  static Future<List<WaterLog>> getTodayWaterLogs(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    try {
      final response = await SupabaseService.waterLogs
          .select()
          .eq('user_id', userId)
          .gte('logged_at', startOfDay.toIso8601String())
          .lt('logged_at', endOfDay.toIso8601String())
          .order('logged_at', ascending: false);

      return response.map<WaterLog>((json) => WaterLog.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addWaterLog({
    required String userId,
    required double amountMl,
  }) async {
    try {
      await SupabaseService.waterLogs.insert({
        'id': _uuid.v4(),
        'user_id': userId,
        'amount_ml': amountMl,
        'logged_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeLastWaterLog(String userId) async {
    try {
      final logs = await getTodayWaterLogs(userId);
      if (logs.isNotEmpty) {
        await SupabaseService.waterLogs.delete().eq('id', logs.last.id);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<WaterSummary> getDailyWaterSummary(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    try {
      final response = await SupabaseService.waterLogs
          .select()
          .eq('user_id', userId)
          .gte('logged_at', startOfDay.toIso8601String())
          .lt('logged_at', endOfDay.toIso8601String());

      final logs = response.map<WaterLog>((json) => WaterLog.fromJson(json)).toList();
      return WaterSummary.fromLogs(date, logs);
    } catch (e) {
      return WaterSummary(date: date);
    }
  }

  /// Returns one [WaterSummary] per day for the last [days] days (oldest first,
  /// today last). Fetches the whole range in a single query and buckets the
  /// logs by day so the Analytics weekly/monthly water charts stay fast.
  static Future<List<WaterSummary>> getWaterSummariesForRange(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = today.subtract(Duration(days: days - 1));
    final endExclusive = today.add(const Duration(days: 1));

    // Build the ordered list of day buckets (oldest -> today).
    final buckets = <DateTime>[
      for (int i = days - 1; i >= 0; i--)
        DateTime(now.year, now.month, now.day).subtract(Duration(days: i)),
    ];

    try {
      final response = await SupabaseService.waterLogs
          .select()
          .eq('user_id', userId)
          .gte('logged_at', startDay.toIso8601String())
          .lt('logged_at', endExclusive.toIso8601String());

      final logs =
          response.map<WaterLog>((json) => WaterLog.fromJson(json)).toList();

      // Group logs by their local day.
      final byDay = <String, List<WaterLog>>{};
      for (final log in logs) {
        final d = log.loggedAt.toLocal();
        final key = '${d.year}-${d.month}-${d.day}';
        byDay.putIfAbsent(key, () => []).add(log);
      }

      return buckets.map((day) {
        final key = '${day.year}-${day.month}-${day.day}';
        return WaterSummary.fromLogs(day, byDay[key] ?? const []);
      }).toList();
    } catch (e) {
      // On error, return empty summaries so the UI still renders the buckets.
      return buckets.map((day) => WaterSummary(date: day)).toList();
    }
  }
}
