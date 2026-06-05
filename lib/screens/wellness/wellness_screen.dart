import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/wellness_log.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calorie_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/wellness_provider.dart';

/// Wellness hub — Mental Wellness & Personal Lifestyle Intelligence.
///
/// Combines a daily mood/stress/energy check-in with a "Daily Wellness Score"
/// that blends nutrition adherence, hydration and mental wellbeing into one
/// number, plus simple, supportive guidance.
class WellnessScreen extends ConsumerStatefulWidget {
  const WellnessScreen({super.key});

  @override
  ConsumerState<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends ConsumerState<WellnessScreen> {
  int _mood = 3;
  int _stress = 3;
  int _energy = 3;
  final _note = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final t = await WellnessStore.today();
    if (t != null && mounted) {
      setState(() {
        _mood = t.mood;
        _stress = t.stress;
        _energy = t.energy;
        _note.text = t.note;
        _loaded = true;
      });
    } else {
      setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final c = WellnessCheckin(
      dateKey: WellnessStore.dateKeyFor(DateTime.now()),
      mood: _mood,
      stress: _stress,
      energy: _energy,
      note: _note.text.trim(),
    );
    await WellnessStore.upsert(c);
    ref.invalidate(todayWellnessProvider);
    ref.invalidate(recentWellnessProvider);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Wellness check-in saved. Take care of yourself! 💚'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final calorieSummary = ref.watch(todayCalorieSummaryProvider);
    final waterSummary = ref.watch(todayWaterSummaryProvider);

    // Compute the wellness score from currently available data.
    final calGoal = (user?.calorieGoal ?? 2000).toDouble();
    final waterGoal = (user?.waterGoal ?? 2000).toDouble();
    final consumed = calorieSummary.asData?.value.totalCalories ?? 0;
    final water = waterSummary.asData?.value.totalMl ?? 0;

    final score = _wellnessScore(
      calorieConsumed: consumed,
      calorieGoal: calGoal,
      waterMl: water,
      waterGoalMl: waterGoal,
      mood: _mood,
      stress: _stress,
      energy: _energy,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Wellness',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _scoreCard(isDark, score),
                  const SizedBox(height: 18),

                  _sectionTitle('How are you feeling today?'),
                  const SizedBox(height: 6),
                  Text(
                    'A quick daily check-in for your mental wellbeing.',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 14),

                  _emojiScale(
                    title: 'Mood',
                    value: _mood,
                    onChanged: (v) => setState(() => _mood = v),
                    emojis: const ['😞', '😕', '😐', '🙂', '😄'],
                  ),
                  const SizedBox(height: 14),
                  _emojiScale(
                    title: 'Stress',
                    value: _stress,
                    onChanged: (v) => setState(() => _stress = v),
                    emojis: const ['😌', '🙂', '😐', '😰', '🤯'],
                  ),
                  const SizedBox(height: 14),
                  _emojiScale(
                    title: 'Energy',
                    value: _energy,
                    onChanged: (v) => setState(() => _energy = v),
                    emojis: const ['🔋', '🔋', '⚡', '⚡', '⚡'],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _note,
                    maxLines: 2,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Optional note — what\'s on your mind?',
                      hintStyle: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.favorite),
                      label: const Text('Save Check-in',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Wellness tips for you'),
                  const SizedBox(height: 10),
                  ..._tips(score, _stress, water, waterGoal).map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡 ',
                                  style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(t,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        height: 1.45)),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),

                  _recentTrend(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ---- Scoring ----
  int _wellnessScore({
    required double calorieConsumed,
    required double calorieGoal,
    required double waterMl,
    required double waterGoalMl,
    required int mood,
    required int stress,
    required int energy,
  }) {
    // Nutrition adherence (0..1): closeness to goal, penalize over/under.
    double nutrition = 0;
    if (calorieGoal > 0) {
      final ratio = calorieConsumed / calorieGoal;
      nutrition = (1 - (1 - ratio).abs()).clamp(0.0, 1.0);
      if (calorieConsumed == 0) nutrition = 0;
    }
    // Hydration adherence (0..1).
    final hydration =
        waterGoalMl > 0 ? (waterMl / waterGoalMl).clamp(0.0, 1.0) : 0.0;
    // Mental wellbeing (0..1): mood & energy up, stress down.
    final mental =
        (((mood - 1) / 4) + ((energy - 1) / 4) + ((5 - stress) / 4)) / 3.0;

    // Weighted blend.
    final score = nutrition * 0.35 + hydration * 0.25 + mental * 0.40;
    return (score * 100).round().clamp(0, 100);
  }

  List<String> _tips(int score, int stress, double water, double waterGoal) {
    final tips = <String>[];
    if (stress >= 4) {
      tips.add(
          'Your stress is high. Try a 4-7-8 breathing cycle: inhale 4s, hold 7s, exhale 8s — repeat 4 times.');
      tips.add(
          'A warm cup of Ethiopian buna or a short walk can help reset a stressful afternoon.');
    }
    if (water < waterGoal * 0.6) {
      tips.add('You\'re behind on hydration — sip a glass of water now. 💧');
    }
    if (score >= 80) {
      tips.add('Great balance today! Keep your routine going — consistency wins.');
    } else if (score < 50) {
      tips.add(
          'Small steps count: log one healthy meal and one glass of water to lift your score.');
    }
    tips.add(
        'Aim for 7–8 hours of sleep tonight; rest is the foundation of wellness.');
    return tips;
  }

  // ---- UI helpers ----
  Widget _scoreCard(bool isDark, int score) {
    Color c;
    String label;
    if (score >= 80) {
      c = AppColors.success;
      label = 'Thriving';
    } else if (score >= 60) {
      c = AppColors.primary;
      label = 'Doing well';
    } else if (score >= 40) {
      c = AppColors.warning;
      label = 'Needs care';
    } else {
      c = AppColors.error;
      label = 'Let\'s improve';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [c.withOpacity(0.95), c.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: c.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 78,
                  height: 78,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 7,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text('$score',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Wellness Score',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95))),
                const SizedBox(height: 4),
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('Nutrition + hydration + mood',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700));

  Widget _emojiScale({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
    required List<String> emojis,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final v = i + 1;
            final sel = v == value;
            return GestureDetector(
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary.withOpacity(0.18)
                      : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(emojis[i],
                      style: TextStyle(fontSize: sel ? 26 : 22)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _recentTrend(bool isDark) {
    final recentAsync = ref.watch(recentWellnessProvider);
    return recentAsync.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent mood',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: list.reversed.map((c) {
                  const moodEmojis = ['😞', '😕', '😐', '🙂', '😄'];
                  final day = c.dateKey.substring(8); // dd
                  return Column(
                    children: [
                      Text(moodEmojis[(c.mood - 1).clamp(0, 4)],
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(day,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.grey)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}
