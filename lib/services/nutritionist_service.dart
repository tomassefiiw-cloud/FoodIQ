import 'dart:convert';

import '../models/health_profile.dart';
import 'gemini_balancer.dart';

/// Acts as the user's personal nutritionist: takes their health & financial
/// information and produces an accurate, personalized daily calorie + water
/// recommendation with a professional rationale.
///
/// It first tries Gemini (through the multi-key load balancer, using a
/// low-load light model). If the AI is unavailable/over-quota, it falls back to
/// a medically-grounded offline calculation (Mifflin–St Jeor BMR × activity
/// factor, adjusted for the user's goal and health conditions) so the user
/// ALWAYS gets an accurate number.
class NutritionistService {
  /// Mifflin–St Jeor Basal Metabolic Rate (kcal/day).
  static double _bmr(HealthProfile p) {
    final s = p.gender.toLowerCase().startsWith('m') ? 5.0 : -161.0;
    return (10 * p.weightKg) + (6.25 * p.heightCm) - (5 * p.age) + s;
  }

  static double _activityFactor(String level) {
    switch (level.toLowerCase()) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very active':
        return 1.9;
      default:
        return 1.55;
    }
  }

  /// Accurate offline calculation used as a guaranteed fallback.
  static NutritionPlan computeOffline(HealthProfile p) {
    final bmr = _bmr(p);
    var tdee = bmr * _activityFactor(p.activityLevel);

    // Adjust for goal.
    switch (p.goal.toLowerCase()) {
      case 'lose weight':
        tdee -= 500; // ~0.45 kg/week deficit
        break;
      case 'gain weight':
        tdee += 400; // lean surplus
        break;
      default:
        break; // maintain
    }

    final conditions = p.conditions.map((e) => e.toLowerCase()).toList();
    final tips = <String>[];

    // Condition-aware, conservative adjustments + guidance.
    if (conditions.any((c) => c.contains('diabet'))) {
      tips.add(
          'Diabetes: favor low-glycemic foods (lentils, vegetables, whole grains like teff). Spread carbs evenly across meals and avoid sugary drinks.');
    }
    if (conditions.any((c) => c.contains('hyperten') || c.contains('blood pressure'))) {
      tips.add(
          'Hypertension: keep salt low (<5 g/day), limit berbere-heavy salty stews, and eat potassium-rich foods (gomen, banana, beans).');
    }
    if (conditions.any((c) => c.contains('kidney') || c.contains('renal'))) {
      // Lower protein guidance for renal patients.
      tips.add(
          'Kidney condition: moderate protein and sodium; please confirm targets with your doctor.');
    }
    if (conditions.any((c) => c.contains('heart') || c.contains('cardio') || c.contains('cholesterol'))) {
      tips.add(
          'Heart health: choose lean proteins and unsaturated fats; limit niter kibbeh (clarified butter) and fried foods.');
    }
    if (conditions.any((c) => c.contains('pregnan'))) {
      tdee += 300; // pregnancy energy needs (general)
      tips.add('Pregnancy: added ~300 kcal/day. Take prenatal nutrients and consult your clinician.');
    }
    if (conditions.any((c) => c.contains('ulcer') || c.contains('gastritis'))) {
      tips.add('Gastric issues: eat smaller frequent meals and go easy on very spicy berbere/mitmita.');
    }

    // Financial guidance (affordable, nutrient-dense Ethiopian staples).
    switch (p.financialStatus.toLowerCase()) {
      case 'low':
        tips.add(
            'Budget-friendly nutrition: shiro, misir (lentils), kik (split peas), gomen, and injera give excellent nutrition at low cost.');
        break;
      case 'medium':
        tips.add(
            'Balance cost & variety: mix affordable legumes with eggs and occasional tibs or doro wot for protein.');
        break;
      case 'high':
        tips.add(
            'You can diversify freely: include fish, lean meats, dairy (ayib, yogurt), fruits and nuts for a well-rounded diet.');
        break;
    }

    // Clamp to safe ranges.
    var calories = tdee.round();
    final minSafe = p.gender.toLowerCase().startsWith('m') ? 1500 : 1200;
    if (calories < minSafe) calories = minSafe;
    if (calories > 4000) calories = 4000;
    // Round to nearest 50 for a clean goal.
    calories = (calories / 50).round() * 50;

    // Water: ~35 ml per kg body weight, +500 ml for active levels.
    var water = (p.weightKg * 35).round();
    if (p.activityLevel.toLowerCase().contains('active')) water += 500;
    if (conditions.any((c) => c.contains('kidney') || c.contains('renal'))) {
      tips.add('Note: some kidney conditions require fluid limits — follow your doctor\'s advice on water.');
    }
    if (water < 1500) water = 1500;
    if (water > 4000) water = 4000;
    water = (water / 100).round() * 100;

    tips.insert(0,
        'Based on Mifflin–St Jeor BMR (${_bmr(p).round()} kcal) × your activity level, adjusted for your goal.');

    final explanation =
        'Your estimated maintenance energy is about ${(_bmr(p) * _activityFactor(p.activityLevel)).round()} kcal/day. '
        'For your goal to ${p.goal.toLowerCase()}, a daily target of $calories kcal is recommended, '
        'with about ${(water / 250).round()} glasses (~$water ml) of water per day.';

    return NutritionPlan(
      calorieGoal: calories,
      waterGoalMl: water,
      explanation: explanation,
      tips: tips,
      fromAI: false,
    );
  }

  /// Ask Gemini (via load balancer) for a professional recommendation.
  /// Falls back to [computeOffline] when AI is unavailable.
  static Future<NutritionPlan> generatePlan(HealthProfile p) async {
    // Compute the offline numbers first so we can pass them as an anchor and
    // always have a guaranteed fallback.
    final offline = computeOffline(p);

    final conditionsText =
        p.conditions.isEmpty ? 'none reported' : p.conditions.join(', ');

    final systemPrompt =
        'You are a certified clinical nutritionist and dietitian. You give safe, '
        'accurate, evidence-based daily nutrition targets. You specialize in '
        'Ethiopian cuisine and are mindful of the user\'s budget. Always be '
        'professional, concise and practical. Respond ONLY with valid JSON.';

    final prompt = '''
Create a personalized DAILY nutrition target for this person.

Profile:
- Age: ${p.age}
- Gender: ${p.gender}
- Weight: ${p.weightKg} kg
- Height: ${p.heightCm} cm
- Activity level: ${p.activityLevel}
- Primary goal: ${p.goal}
- Health conditions: $conditionsText
- Financial status: ${p.financialStatus}
- Notes: ${p.notes.isEmpty ? 'none' : p.notes}

A standard Mifflin-St Jeor calculation suggests about ${offline.calorieGoal} kcal/day
and ${offline.waterGoalMl} ml water/day. Use this as a sanity anchor but adjust
appropriately and SAFELY for the health conditions and goal.

Rules:
- calorie_goal must be a safe integer (never below 1200 for women / 1500 for men).
- water_ml integer in a safe range (1500-4000), respecting any condition that limits fluids.
- Tailor tips to the conditions AND the financial status, recommending affordable
  Ethiopian foods when budget is Low.
- Keep "explanation" under 90 words, professional and supportive.
- Provide 3-5 short, specific "tips".

Return ONLY this JSON (no markdown):
{
  "calorie_goal": 2000,
  "water_ml": 2500,
  "explanation": "....",
  "tips": ["tip1", "tip2", "tip3"]
}
''';

    final raw = await GeminiBalancer.instance.generateText(
      prompt: prompt,
      systemPrompt: systemPrompt,
      temperature: 0.4,
      maxOutputTokens: 900,
      jsonMode: true,
    );

    if (raw == null) return offline;

    try {
      final jsonStr = _extractJson(raw);
      final m = jsonDecode(jsonStr) as Map<String, dynamic>;
      var cal = (m['calorie_goal'] as num?)?.round() ?? offline.calorieGoal;
      var water = (m['water_ml'] as num?)?.round() ?? offline.waterGoalMl;

      // Safety clamps regardless of what the model returns.
      final minSafe = p.gender.toLowerCase().startsWith('m') ? 1500 : 1200;
      if (cal < minSafe) cal = minSafe;
      if (cal > 4500) cal = 4500;
      if (water < 1500) water = 1500;
      if (water > 4000) water = 4000;

      final explanation =
          (m['explanation'] as String?)?.trim() ?? offline.explanation;
      final tips = ((m['tips'] as List?)?.map((e) => e.toString()).toList()) ??
          offline.tips;

      return NutritionPlan(
        calorieGoal: cal,
        waterGoalMl: water,
        explanation: explanation,
        tips: tips.isEmpty ? offline.tips : tips,
        fromAI: true,
      );
    } catch (_) {
      return offline;
    }
  }

  static String _extractJson(String s) {
    var t = s.trim();
    if (t.startsWith('```')) {
      t = t.replaceAll(RegExp(r'```(?:json)?'), '').trim();
    }
    final a = t.indexOf('{');
    final b = t.lastIndexOf('}');
    if (a >= 0 && b > a) return t.substring(a, b + 1);
    return t;
  }
}
