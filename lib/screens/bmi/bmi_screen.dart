import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/constants/food_database.dart';
import '../../models/food_item.dart';
import '../../providers/auth_provider.dart';
import '../../services/log_service.dart';

class BMIScreen extends ConsumerStatefulWidget {
  const BMIScreen({super.key});

  @override
  ConsumerState<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends ConsumerState<BMIScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Not specified';

  double? _bmi;
  String _bmiCategory = '';
  Color _bmiColor = Colors.grey;
  bool _isCalculating = false;
  bool _isSuggesting = false;
  List<FoodItem> _suggestedMeals = [];
  String _aiSuggestion = '';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _weightController.text = user.weight > 0 ? user.weight.toStringAsFixed(1) : '';
      _heightController.text = user.height > 0 ? user.height.toStringAsFixed(1) : '';
      _ageController.text = user.age > 0 ? user.age.toString() : '';
      _gender = user.gender;

      // If user already has weight and height, auto-calculate BMI
      if (user.weight > 0 && user.height > 0) {
        _calculateBMI();
      }
    }
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid weight (kg) and height (cm)',
              style: TextStyle(fontFamily: 'Poppins')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isCalculating = true);

    // BMI = weight(kg) / (height(m))^2
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);

    String category;
    Color color;

    if (bmi < 16) {
      category = 'Severely Underweight';
      color = Colors.purple;
    } else if (bmi < 18.5) {
      category = 'Underweight';
      color = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normal Weight';
      color = AppColors.success;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = AppColors.warning;
    } else if (bmi < 35) {
      category = 'Obese Class I';
      color = Colors.deepOrange;
    } else if (bmi < 40) {
      category = 'Obese Class II';
      color = Colors.red;
    } else {
      category = 'Obese Class III';
      color = Colors.red[900]!;
    }

    setState(() {
      _bmi = bmi;
      _bmiCategory = category;
      _bmiColor = color;
      _isCalculating = false;
    });

    // Save to user profile
    _saveToProfile(weight, height);

    // Auto-suggest meals based on BMI
    _suggestMealsFromDatabase(bmi);
  }

  Future<void> _saveToProfile(double weight, double height) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final age = int.tryParse(_ageController.text) ?? user.age;
      ref.read(authProvider.notifier).updateProfile(
        user.copyWith(
          weight: weight,
          height: height,
          age: age,
          gender: _gender,
        ),
      );
    }
  }

  /// Suggest meals from the local database based on BMI
  void _suggestMealsFromDatabase(double bmi) {
    final allFoods = FoodDatabase.allFoods;
    List<FoodItem> suggested;

    if (bmi < 18.5) {
      // Underweight: suggest calorie-dense, protein-rich foods
      suggested = allFoods.where((f) =>
        f.calories >= 200 && f.protein >= 10 && f.fat <= 25
      ).toList()..shuffle(Random());
      suggested = suggested.take(8).toList();
    } else if (bmi < 25) {
      // Normal: suggest balanced meals
      suggested = allFoods.where((f) =>
        f.calories >= 100 && f.calories <= 350 && f.protein >= 5
      ).toList()..shuffle(Random());
      suggested = suggested.take(8).toList();
    } else if (bmi < 30) {
      // Overweight: suggest lower calorie, high protein, high fiber
      suggested = allFoods.where((f) =>
        f.calories <= 250 && f.protein >= 8 && f.fiber >= 3
      ).toList()..shuffle(Random());
      suggested = suggested.take(8).toList();
    } else {
      // Obese: suggest very low calorie, high fiber, high protein
      suggested = allFoods.where((f) =>
        f.calories <= 200 && f.fiber >= 4
      ).toList()..shuffle(Random());
      suggested = suggested.take(8).toList();
    }

    // If we don't have enough suggestions, fill with general healthy options
    if (suggested.length < 4) {
      final healthyDefaults = allFoods.where((f) =>
        f.calories <= 300 && f.protein >= 5
      ).toList()..shuffle(Random());
      for (final food in healthyDefaults) {
        if (suggested.length >= 8) break;
        if (!suggested.any((s) => s.id == food.id)) {
          suggested.add(food);
        }
      }
    }

    setState(() {
      _suggestedMeals = suggested;
    });
  }

  /// Get AI-powered meal suggestions based on BMI
  Future<void> _getAISuggestions() async {
    if (_bmi == null) {
      _calculateBMI();
      if (_bmi == null) return;
    }

    setState(() => _isSuggesting = true);

    try {
      final weight = _weightController.text;
      final height = _heightController.text;
      final age = _ageController.text;
      final bmiCategory = _bmiCategory;

      // Build a list of some foods from database for AI context
      final ethFoods = FoodDatabase.ethiopianFoods.take(15).map((f) =>
        '${f.name} (${f.calories} kcal, P:${f.protein}g, C:${f.carbs}g, F:${f.fat}g)'
      ).join(', ');
      final commonFoods = FoodDatabase.commonFoods.take(10).map((f) =>
        '${f.name} (${f.calories} kcal, P:${f.protein}g, C:${f.carbs}g, F:${f.fat}g)'
      ).join(', ');

      final systemPrompt = '''You are FoodIQ AI, a nutrition advisor specializing in Ethiopian and common cuisine.
The user has the following profile:
- Weight: $weight kg
- Height: $height cm
- Age: $age
- BMI: ${_bmi!.toStringAsFixed(1)} ($bmiCategory)

Available foods from database:
Ethiopian: $ethFoods
Common: $commonFoods

Based on their BMI, suggest 5-6 specific meals they should try. For each meal:
1. Name the food (must be from the database above)
2. Explain WHY it's good for their BMI category
3. Include a recommended portion size

Keep the response concise, friendly, and culturally relevant. Use both English and Amharic names when available.''';

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.groqApiKey}',
            },
            body: jsonEncode({
              'model': AppConfig.groqChatModel,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': 'Suggest the best meals for my BMI category. I want practical, tasty options I can actually eat.'},
              ],
              'max_tokens': 1024,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = (data['choices']?[0]?['message']?['content'] as String?)
                ?.trim() ??
            'Could not generate suggestions. Please try again.';
        setState(() {
          _aiSuggestion = reply;
          _isSuggesting = false;
        });
      } else {
        setState(() {
          _aiSuggestion = _getOfflineAISuggestion(_bmi!, _bmiCategory);
          _isSuggesting = false;
        });
      }
    } catch (e) {
      setState(() {
        _aiSuggestion = _getOfflineAISuggestion(_bmi!, _bmiCategory);
        _isSuggesting = false;
      });
    }
  }

  String _getOfflineAISuggestion(double bmi, String category) {
    if (bmi < 18.5) {
      return '''Based on your BMI (${bmi.toStringAsFixed(1)} - $category), here are some great calorie-dense options:

1. Doro Wot (250 kcal, 22g protein) - Rich chicken stew with berbere, perfect for gaining healthy weight
2. Kitfo (320 kcal, 28g protein) - High-protein minced beef, excellent for muscle building
3. Injera + Tibs (380 kcal, 24g protein) - Balanced meal with protein and complex carbs
4. Chechebsa (320 kcal, 8.5g protein) - Shredded flatbread with spiced butter for calorie density
5. Injera + Shiro (305 kcal, 14g protein) - Plant-based protein with fiber

Tips: Eat larger portions, add healthy fats like avocado, and don't skip meals!''';
    } else if (bmi < 25) {
      return '''Your BMI (${bmi.toStringAsFixed(1)} - $category) is in the healthy range! Maintain it with these balanced meals:

1. Injera + Misir Wot (290 kcal, 16g protein) - High-fiber, plant-based protein
2. Ful (220 kcal, 12g protein) - Fava bean stew with great fiber content
3. Kinche (170 kcal, 5.5g protein) - Light cracked wheat porridge for breakfast
4. Gomen (85 kcal, 4.5g protein) - Nutrient-dense collard greens
5. Enkulal Tibs (195 kcal, 13g protein) - Protein-rich eggs, light but filling

Tips: Keep variety in your diet, stay hydrated, and maintain regular meal times!''';
    } else if (bmi < 30) {
      return '''Your BMI (${bmi.toStringAsFixed(1)} - $category) suggests choosing lighter, high-fiber options:

1. Misir Wot (180 kcal, 12g protein, 8g fiber) - High-protein lentil stew keeps you full
2. Gomen (85 kcal, 4.5g protein, 5g fiber) - Low-calorie, nutrient-dense greens
3. Shiro Wot (195 kcal, 10g protein, 6g fiber) - Satisfying chickpea stew with fiber
4. Tikil Gomen (75 kcal, 3g protein, 4.5g fiber) - Very light cabbage dish
5. Kik Alicha (150 kcal, 9.5g protein, 7g fiber) - Mild split pea stew, high fiber

Tips: Choose vegetable wots over meat, control injera portions, and increase water intake!''';
    } else {
      return '''Your BMI (${bmi.toStringAsFixed(1)} - $category) indicates focusing on very low-calorie, high-fiber foods:

1. Gomen (85 kcal, 4.5g protein, 5g fiber) - Extremely light, nutrient-packed
2. Atkilt Wot (105 kcal, 3.5g protein, 4.5g fiber) - Mixed vegetables, filling and low-cal
3. Tikil Gomen (75 kcal, 3g protein, 4.5g fiber) - Cabbage, almost no calories
4. Misir Alicha (155 kcal, 10g protein, 7.5g fiber) - Mild lentils, high protein+fiber
5. Broccoli (34 kcal, 2.8g protein, 2.6g fiber) - Super low calorie, nutrient-dense

Tips: Prioritize vegetable dishes, limit niter kibbeh (butter), eat smaller injera portions, and walk 30 min daily!''';
    }
  }

  void _logSuggestedFood(FoodItem food) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Determine meal type based on current time
    final hour = DateTime.now().hour;
    MealType mealType;
    if (hour < 11) {
      mealType = MealType.breakfast;
    } else if (hour < 16) {
      mealType = MealType.lunch;
    } else {
      mealType = MealType.dinner;
    }

    LogService.addCalorieLog(
      userId: user.id,
      foodId: food.id,
      foodName: food.name,
      mealType: mealType,
      portion: 1.0,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      fiber: food.fiber,
      servingSize: food.servingSize,
    ).then((success) {
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${food.name} added to your ${mealType.name} log!',
                  style: TextStyle(fontFamily: 'Poppins')),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log ${food.name}. Try again.',
                  style: TextStyle(fontFamily: 'Poppins')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.monitor_weight, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Body Mass Index', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700)),
                            Text('Calculate your BMI & get AI meal suggestions', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weight Input
                  _InputField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    icon: Icons.fitness_center,
                    hint: 'e.g. 70',
                  ),
                  const SizedBox(height: 12),

                  // Height Input
                  _InputField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    icon: Icons.height,
                    hint: 'e.g. 170',
                  ),
                  const SizedBox(height: 12),

                  // Age Input
                  _InputField(
                    controller: _ageController,
                    label: 'Age',
                    icon: Icons.cake,
                    hint: 'e.g. 25',
                  ),
                  const SizedBox(height: 12),

                  // Gender Selection
                  Row(
                    children: [
                      Icon(Icons.wc, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Gender:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(width: 12),
                      ...['Male', 'Female', 'Other'].map((g) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g, style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                          selected: _gender == g,
                          onSelected: (_) => setState(() => _gender = g),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCalculating ? null : _calculateBMI,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isCalculating
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Calculate BMI', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),

            // BMI Result
            if (_bmi != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_bmiColor.withOpacity(0.1), _bmiColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _bmiColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Your BMI', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_bmi!.toStringAsFixed(1),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 48, fontWeight: FontWeight.bold, color: _bmiColor),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _bmiColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_bmiCategory,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: _bmiColor),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // BMI Scale
                    _BMIScale(currentBMI: _bmi!),
                  ],
                ),
              ),

              // Suggested Meals from Database
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recommended for You', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
                  Text('Based on BMI', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              ...(_suggestedMeals.map((food) => _SuggestedFoodCard(
                food: food,
                isDark: isDark,
                onLog: () => _logSuggestedFood(food),
              ))),

              // AI Suggestions Section
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkCard, AppColors.darkSurface]
                        : [AppColors.primaryBg, const Color(0xFFFFF0E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.smart_toy, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Meal Suggestions', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
                              Text('Personalized for your BMI', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_aiSuggestion.isEmpty && !_isSuggesting)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _getAISuggestions,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text('Get AI Suggestions', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),

                    if (_isSuggesting)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 12),
                            Text('AI is thinking...', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                          ],
                        ),
                      )),

                    if (_aiSuggestion.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _aiSuggestion,
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isSuggesting ? null : _getAISuggestions,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text('Regenerate', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Poppins'),
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
    );
  }
}

class _BMIScale extends StatelessWidget {
  final double currentBMI;

  const _BMIScale({required this.currentBMI});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(color: Colors.blue),
                ),
                Expanded(
                  flex: 3,
                  child: Container(color: AppColors.success),
                ),
                Expanded(
                  flex: 2,
                  child: Container(color: AppColors.warning),
                ),
                Expanded(
                  flex: 2,
                  child: Container(color: Colors.deepOrange),
                ),
                Expanded(
                  flex: 2,
                  child: Container(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Underweight', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: Colors.blue)),
            Text('Normal', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.success)),
            Text('Overweight', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.warning)),
            Text('Obese', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: Colors.red)),
          ],
        ),
      ],
    );
  }
}

class _SuggestedFoodCard extends StatelessWidget {
  final FoodItem food;
  final bool isDark;
  final VoidCallback onLog;

  const _SuggestedFoodCard({
    required this.food,
    required this.isDark,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: (food.category == FoodCategory.ethiopian ? AppColors.primary : AppColors.proteinBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              food.category == FoodCategory.ethiopian ? Icons.restaurant : Icons.set_meal,
              color: food.category == FoodCategory.ethiopian ? AppColors.primary : AppColors.proteinBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(food.name, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (food.nameAmharic.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(food.nameAmharic, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${food.calories.toStringAsFixed(0)} kcal',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Text('P:${food.protein.toStringAsFixed(0)}g',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.proteinBlue)),
                    const SizedBox(width: 4),
                    Text('C:${food.carbs.toStringAsFixed(0)}g',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.carbsOrange)),
                    const SizedBox(width: 4),
                    Text('F:${food.fat.toStringAsFixed(0)}g',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.fatRed)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onLog,
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            tooltip: 'Log this food',
          ),
        ],
      ),
    );
  }
}
