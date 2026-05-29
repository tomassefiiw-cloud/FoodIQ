import 'food_item.dart' show MealType;

class CalorieLog {
  final String id;
  final String userId;
  final String foodId;
  final String foodName;
  final MealType mealType;
  final double portion;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double servingSize;
  final String? notes;
  final DateTime loggedAt;

  CalorieLog({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.foodName,
    this.mealType = MealType.snack,
    this.portion = 1.0,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.servingSize = 100,
    this.notes,
    required this.loggedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
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
    'logged_at': loggedAt.toIso8601String(),
  };

  factory CalorieLog.fromJson(Map<String, dynamic> json) => CalorieLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    foodId: json['food_id'] as String,
    foodName: json['food_name'] as String,
    mealType: MealType.values.firstWhere(
      (m) => m.name == json['meal_type'],
      orElse: () => MealType.snack,
    ),
    portion: (json['portion'] as num?)?.toDouble() ?? 1.0,
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num?)?.toDouble() ?? 0,
    carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
    fat: (json['fat'] as num?)?.toDouble() ?? 0,
    fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
    servingSize: (json['serving_size'] as num?)?.toDouble() ?? 100,
    notes: json['notes'] as String?,
    loggedAt: DateTime.parse(json['logged_at'] as String),
  );
}

class DailySummary {
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final int entryCount;

  DailySummary({
    required this.date,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.totalFiber = 0,
    this.entryCount = 0,
  });

  factory DailySummary.fromLogs(DateTime date, List<CalorieLog> logs) {
    return DailySummary(
      date: date,
      totalCalories: logs.fold(0.0, (sum, log) => sum + log.calories),
      totalProtein: logs.fold(0.0, (sum, log) => sum + log.protein),
      totalCarbs: logs.fold(0.0, (sum, log) => sum + log.carbs),
      totalFat: logs.fold(0.0, (sum, log) => sum + log.fat),
      totalFiber: logs.fold(0.0, (sum, log) => sum + log.fiber),
      entryCount: logs.length,
    );
  }
}
