import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_profile.dart';

/// Daily macro targets (grams) derived from the user's calorie goal.
///
/// This makes "everything based on the goal" real: once a calorie goal is set
/// (by the AI Nutritionist or manually), protein / carbs / fat / fiber targets
/// are computed from it and shown across the app (dashboard progress, wellness
/// score, etc.). Splits are condition-aware (e.g. lower-carb for diabetes).
class NutritionTargets {
  final int calorieGoal;
  final int waterMl;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;

  const NutritionTargets({
    required this.calorieGoal,
    required this.waterMl,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
  });

  Map<String, dynamic> toJson() => {
        'calorieGoal': calorieGoal,
        'waterMl': waterMl,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'fiberG': fiberG,
      };

  factory NutritionTargets.fromJson(Map<String, dynamic> j) => NutritionTargets(
        calorieGoal: (j['calorieGoal'] as num?)?.toInt() ?? 2000,
        waterMl: (j['waterMl'] as num?)?.toInt() ?? 2000,
        proteinG: (j['proteinG'] as num?)?.toDouble() ?? 0,
        carbsG: (j['carbsG'] as num?)?.toDouble() ?? 0,
        fatG: (j['fatG'] as num?)?.toDouble() ?? 0,
        fiberG: (j['fiberG'] as num?)?.toDouble() ?? 0,
      );

  /// Compute macro gram targets from a calorie goal, adjusting the macro split
  /// for the user's health conditions when available.
  ///
  /// Default split: 25% protein / 45% carbs / 30% fat. Fiber ≈ 14 g / 1000 kcal.
  static NutritionTargets compute({
    required int calorieGoal,
    required int waterMl,
    List<String> conditions = const [],
  }) {
    double proteinPct = 0.25;
    double carbsPct = 0.45;
    double fatPct = 0.30;

    final c = conditions.map((e) => e.toLowerCase()).toList();
    final hasDiabetes = c.any((x) => x.contains('diabet'));
    final hasHeart =
        c.any((x) => x.contains('heart') || x.contains('cholesterol') || x.contains('cardio'));
    final hasKidney = c.any((x) => x.contains('kidney') || x.contains('renal'));

    if (hasDiabetes) {
      // Lower carbohydrate, higher protein & healthy fat for glycemic control.
      proteinPct = 0.30;
      carbsPct = 0.40;
      fatPct = 0.30;
    }
    if (hasHeart) {
      // Slightly lower fat for cardiovascular health.
      fatPct = 0.25;
      carbsPct = hasDiabetes ? 0.45 : 0.50;
      proteinPct = 1.0 - carbsPct - fatPct;
    }
    if (hasKidney) {
      // Moderate protein for renal care.
      proteinPct = 0.18;
      carbsPct = 0.52;
      fatPct = 0.30;
    }

    final cal = calorieGoal.toDouble();
    final protein = (cal * proteinPct) / 4.0; // 4 kcal/g
    final carbs = (cal * carbsPct) / 4.0; // 4 kcal/g
    final fat = (cal * fatPct) / 9.0; // 9 kcal/g
    final fiber = (cal / 1000.0) * 14.0; // dietary guideline

    return NutritionTargets(
      calorieGoal: calorieGoal,
      waterMl: waterMl,
      proteinG: protein.roundToDouble(),
      carbsG: carbs.roundToDouble(),
      fatG: fat.roundToDouble(),
      fiberG: fiber.roundToDouble(),
    );
  }

  static const _prefsKey = 'nutrition_targets_json';

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toJson()));
  }

  /// Load saved targets. If none saved, derive sensible targets from the given
  /// [fallbackCalorieGoal] / [fallbackWaterMl] so the app always has targets.
  static Future<NutritionTargets> load({
    int fallbackCalorieGoal = 2000,
    int fallbackWaterMl = 2000,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final t = NutritionTargets.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
        // If the stored target matches the current goal, use it; otherwise
        // recompute so targets always track the active calorie goal.
        if (t.calorieGoal == fallbackCalorieGoal) return t;
      } catch (_) {}
    }
    final hp = await HealthProfile.load();
    return compute(
      calorieGoal: fallbackCalorieGoal,
      waterMl: fallbackWaterMl,
      conditions: hp?.conditions ?? const [],
    );
  }
}
