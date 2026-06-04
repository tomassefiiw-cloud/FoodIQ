import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/health_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calorie_provider.dart';
import '../../providers/water_provider.dart';
import '../../services/nutritionist_service.dart';

/// Personal-nutritionist flow: collect health & financial info, then generate
/// (and let the user accept or override) a personalized daily calorie + water
/// goal.
class NutritionPlanScreen extends ConsumerStatefulWidget {
  const NutritionPlanScreen({super.key});

  @override
  ConsumerState<NutritionPlanScreen> createState() =>
      _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends ConsumerState<NutritionPlanScreen> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _age = TextEditingController();
  final _notes = TextEditingController();

  String _gender = 'Male';
  String _activity = 'Moderate';
  String _goal = 'Maintain';
  String _financial = 'Medium';
  final Set<String> _conditions = {};

  bool _generating = false;
  NutritionPlan? _plan;

  // Manual override controllers (used if the user declines the suggestion).
  final _manualCal = TextEditingController();
  final _manualWater = TextEditingController();
  bool _manualMode = false;

  static const _activities = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  ];
  static const _goals = ['Lose Weight', 'Maintain', 'Gain Weight'];
  static const _financials = ['Low', 'Medium', 'High'];
  static const _conditionOptions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'High Cholesterol',
    'Kidney Disease',
    'Gastritis / Ulcer',
    'Pregnancy',
    'None',
  ];

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      if (user.weight > 0) _weight.text = user.weight.toStringAsFixed(1);
      if (user.height > 0) _height.text = user.height.toStringAsFixed(1);
      if (user.age > 0) _age.text = user.age.toString();
      if (user.gender == 'Male' || user.gender == 'Female') {
        _gender = user.gender;
      }
    }
    final saved = await HealthProfile.load();
    if (saved != null && mounted) {
      setState(() {
        if (_weight.text.isEmpty) {
          _weight.text = saved.weightKg.toStringAsFixed(1);
        }
        if (_height.text.isEmpty) {
          _height.text = saved.heightCm.toStringAsFixed(1);
        }
        if (_age.text.isEmpty) _age.text = saved.age.toString();
        _gender = saved.gender == 'Female' ? 'Female' : 'Male';
        _activity = saved.activityLevel;
        _goal = saved.goal;
        _financial = saved.financialStatus;
        _conditions
          ..clear()
          ..addAll(saved.conditions);
        _notes.text = saved.notes;
      });
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _age.dispose();
    _notes.dispose();
    _manualCal.dispose();
    _manualWater.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final w = double.tryParse(_weight.text);
    final h = double.tryParse(_height.text);
    final a = int.tryParse(_age.text);
    if (w == null || h == null || a == null || w <= 0 || h <= 0 || a <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter valid weight, height and age.'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    final conditions = _conditions.where((c) => c != 'None').toList();
    final profile = HealthProfile(
      weightKg: w,
      heightCm: h,
      age: a,
      gender: _gender,
      activityLevel: _activity,
      goal: _goal,
      conditions: conditions,
      financialStatus: _financial,
      notes: _notes.text.trim(),
    );
    await profile.save();

    setState(() {
      _generating = true;
      _plan = null;
      _manualMode = false;
    });

    final plan = await NutritionistService.generatePlan(profile);

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _generating = false;
      _manualCal.text = plan.calorieGoal.toString();
      _manualWater.text = plan.waterGoalMl.toString();
    });
  }

  Future<void> _applyGoals(int calories, int waterMl) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(authProvider.notifier).updateProfile(
          user.copyWith(calorieGoal: calories, waterGoal: waterMl),
        );

    // Persist BMI prefs so reminders & other features stay in sync.
    final prefs = await SharedPreferences.getInstance();
    final h = double.tryParse(_height.text);
    final wt = double.tryParse(_weight.text);
    if (h != null && wt != null && h > 0) {
      final bmi = wt / ((h / 100) * (h / 100));
      await prefs.setDouble('user_bmi', bmi);
    }

    // Refresh dashboard rings.
    ref.invalidate(todayCalorieSummaryProvider);
    ref.invalidate(todayWaterSummaryProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅ Goals updated: $calories kcal • ${(waterMl / 250).round()} glasses/day'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Nutritionist',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primary.withOpacity(0.14),
                  AppColors.primary.withOpacity(0.05)
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.health_and_safety,
                      color: AppColors.primary, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tell me about your health, lifestyle and budget. '
                      'I\'ll calculate a safe, personalized daily calorie & water goal.',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _sectionTitle('Body details'),
            Row(children: [
              Expanded(
                  child: _numField(
                      _weight, 'Weight (kg)', Icons.fitness_center)),
              const SizedBox(width: 10),
              Expanded(child: _numField(_height, 'Height (cm)', Icons.height)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _numField(_age, 'Age', Icons.cake)),
              const SizedBox(width: 10),
              Expanded(
                  child: _dropdown('Gender', _gender,
                      const ['Male', 'Female', 'Other'],
                      (v) => setState(() => _gender = v))),
            ]),
            const SizedBox(height: 16),

            _sectionTitle('Activity level'),
            _dropdown('Activity', _activity, _activities,
                (v) => setState(() => _activity = v)),
            const SizedBox(height: 16),

            _sectionTitle('Your goal'),
            _chips(_goals, _goal, (v) => setState(() => _goal = v)),
            const SizedBox(height: 16),

            _sectionTitle('Health conditions (select any that apply)'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _conditionOptions.map((c) {
                final sel = _conditions.contains(c);
                return FilterChip(
                  label: Text(c,
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 12)),
                  selected: sel,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  onSelected: (v) {
                    setState(() {
                      if (c == 'None') {
                        _conditions.clear();
                        if (v) _conditions.add('None');
                      } else {
                        _conditions.remove('None');
                        v ? _conditions.add(c) : _conditions.remove(c);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            _sectionTitle('Financial status'),
            Text('Helps me suggest foods you can actually afford.',
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            _chips(_financials, _financial,
                (v) => setState(() => _financial = v)),
            const SizedBox(height: 16),

            _sectionTitle('Anything else? (optional)'),
            TextField(
              controller: _notes,
              maxLines: 2,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. lactose intolerant, vegetarian, fasting...',
                hintStyle:
                    const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _generating ? null : _generate,
                icon: _generating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_generating ? 'Analyzing...' : 'Get My Plan',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            if (_plan != null) ...[
              const SizedBox(height: 22),
              _planCard(isDark, _plan!),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _planCard(bool isDark, NutritionPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Your Personalized Plan',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (plan.fromAI ? AppColors.success : AppColors.info)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(plan.fromAI ? 'AI' : 'Calculated',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: plan.fromAI
                            ? AppColors.success
                            : AppColors.info)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _bigStat('Calories', '${plan.calorieGoal}',
                    'kcal/day', AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bigStat(
                    'Water',
                    '${(plan.waterGoalMl / 250).round()}',
                    'glasses (~${plan.waterGoalMl} ml)',
                    AppColors.waterBlue),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(plan.explanation,
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 13, height: 1.5)),
          if (plan.tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...plan.tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                      Expanded(
                          child: Text(t,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.5,
                                  height: 1.45))),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 16),
          Text('Do you accept this plan?',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _applyGoals(plan.calorieGoal, plan.waterGoalMl),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Accept & Apply',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _manualMode = !_manualMode),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Set Manually',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          if (_manualMode) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 6),
            Text('Enter your own goals',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _numField(_manualCal, 'Calories (kcal)',
                      Icons.local_fire_department)),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      _numField(_manualWater, 'Water (ml)', Icons.water_drop)),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final c = int.tryParse(_manualCal.text);
                  final w = int.tryParse(_manualWater.text);
                  if (c == null || w == null || c < 800 || w < 500) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Enter valid calorie & water values.'),
                          backgroundColor: AppColors.error),
                    );
                    return;
                  }
                  _applyGoals(c, w);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Apply My Goals',
                    style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bigStat(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(unit,
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700)),
      );

  Widget _numField(TextEditingController c, String label, IconData icon) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      ValueChanged<String> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 14, color: Colors.black87),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child:
                      Text(e, style: const TextStyle(fontFamily: 'Poppins'))))
              .toList(),
          onChanged: (v) => onChanged(v ?? value),
        ),
      ),
    );
  }

  Widget _chips(
      List<String> items, String selected, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      children: items.map((e) {
        final sel = e == selected;
        return ChoiceChip(
          label: Text(e,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
          selected: sel,
          selectedColor: AppColors.primary.withOpacity(0.2),
          onSelected: (_) => onTap(e),
        );
      }).toList(),
    );
  }
}
