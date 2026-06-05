import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calorie_provider.dart';
import '../../providers/water_provider.dart';
import '../../services/log_service.dart';
import '../../models/calorie_log.dart';
import '../food_log/food_log_screen.dart';
import '../analytics/analytics_screen.dart';
import '../camera/camera_screen.dart';
import '../profile/profile_screen.dart';
import '../assistant/assistant_screen.dart';
import '../bmi/bmi_screen.dart';
import '../nutrition/nutrition_plan_screen.dart';
import '../wellness/wellness_screen.dart';
import '../../providers/wellness_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    AnalyticsScreen(),
    CameraScreen(),
    AssistantScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt_rounded), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.smart_toy_rounded), label: 'AI'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSheet(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add, size: 26),
              label: Text('Add',
                  style: TextStyle(fontFamily: 'Poppins', 
                      fontWeight: FontWeight.w600, fontSize: 15)),
            )
          : null,
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('What would you like to do?',
                style: TextStyle(fontFamily: 'Poppins', 
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _AddOption(
              icon: Icons.camera_alt_rounded,
              color: AppColors.primary,
              title: 'Scan with camera',
              subtitle: 'Identify food with AI from a photo',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            _AddOption(
              icon: Icons.restaurant_menu_rounded,
              color: AppColors.proteinBlue,
              title: 'Browse food database',
              subtitle: '180+ Ethiopian & common foods',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FoodLogScreen()));
              },
            ),
            _AddOption(
              icon: Icons.edit_note_rounded,
              color: AppColors.success,
              title: 'Add manually',
              subtitle: 'Type in food + nutrition by hand',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FoodLogScreen(initialTab: 2)));
              },
            ),
            _AddOption(
              icon: Icons.smart_toy_rounded,
              color: AppColors.carbsOrange,
              title: 'Ask FoodIQ AI',
              subtitle: 'Chat with our nutrition assistant',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _AddOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontFamily: 'Poppins', 
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontFamily: 'Poppins', 
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final calorieSummary = ref.watch(todayCalorieSummaryProvider);
    final waterSummary = ref.watch(todayWaterSummaryProvider);
    final calorieProgress = ref.watch(calorieProgressProvider);
    final waterProgress = ref.watch(waterProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Text('FoodIQ', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayCalorieSummaryProvider);
          ref.invalidate(weeklyCalorieLogsProvider);
          ref.invalidate(monthlyCalorieLogsProvider);
          ref.invalidate(todayWaterSummaryProvider);
          ref.invalidate(todayCalorieLogsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                _getGreeting() + ', ${user?.name ?? "Friend"}! 👋',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _getMotivation(),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Calorie Ring Card
              calorieSummary.when(
                data: (summary) => _CalorieRingCard(
                  consumed: summary.totalCalories,
                  goal: user?.calorieGoal ?? 2000,
                  progress: calorieProgress,
                  protein: summary.totalProtein,
                  carbs: summary.totalCarbs,
                  fat: summary.totalFat,
                  fiber: summary.totalFiber,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // Macros Row — shows progress vs goal-derived targets
              calorieSummary.when(
                data: (summary) {
                  final targets = ref.watch(nutritionTargetsProvider).asData?.value;
                  return _MacrosRow(
                    protein: summary.totalProtein,
                    carbs: summary.totalCarbs,
                    fat: summary.totalFat,
                    fiber: summary.totalFiber,
                    proteinTarget: targets?.proteinG ?? 0,
                    carbsTarget: targets?.carbsG ?? 0,
                    fatTarget: targets?.fatG ?? 0,
                    fiberTarget: targets?.fiberG ?? 0,
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // Water Tracker Card
              waterSummary.when(
                data: (water) => _WaterTrackerCard(
                  currentMl: water.totalMl,
                  goalMl: (user?.waterGoal ?? 2000).toDouble(),
                  glasses: water.glassCount,
                  progress: waterProgress,
                  onAddGlass: () {
                    final userId = user?.id;
                    if (userId != null) {
                      LogService.addWaterLog(userId: userId, amountMl: 250).then((_) {
                        ref.invalidate(todayWaterSummaryProvider);
                        ref.invalidate(todayWaterLogsProvider);
                        ref.invalidate(weeklyWaterLogsProvider);
                        ref.invalidate(monthlyWaterLogsProvider);
                      });
                    }
                  },
                  onRemoveGlass: () {
                    final userId = user?.id;
                    if (userId != null) {
                      LogService.removeLastWaterLog(userId).then((_) {
                        ref.invalidate(todayWaterSummaryProvider);
                        ref.invalidate(todayWaterLogsProvider);
                        ref.invalidate(weeklyWaterLogsProvider);
                        ref.invalidate(monthlyWaterLogsProvider);
                      });
                    }
                  },
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // AI Tip
              _AITipCard(tip: _getContextualTip(calorieProgress)),
              const SizedBox(height: 16),

              // AI Nutritionist Quick Access — personalized goals
              _NutritionistQuickCard(),
              const SizedBox(height: 16),

              // Wellness Quick Access — mood/stress check-in + wellness score
              _WellnessQuickCard(),
              const SizedBox(height: 16),

              // BMI Quick Access
              _BMIQuickCard(user: user),
              const SizedBox(height: 16),

              // Today's Meals
              const _TodayMealsSection(),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getMotivation() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Start your day with a healthy breakfast! 🌅';
    if (hour < 17) return 'Keep going, you\'re doing great! 💪';
    return 'Time to wrap up your nutrition goals! 🌙';
  }

  String _getContextualTip(double progress) {
    if (progress < 0.3) return 'You\'re just getting started! Try logging your breakfast to build momentum. 🥐';
    if (progress < 0.5) return 'Good progress! Keep logging your meals throughout the day. 🎯';
    if (progress < 0.7) return 'You\'re more than halfway there! Great dedication! 🌟';
    if (progress < 0.9) return 'Almost at your goal! Consider if you need more or if you\'re satisfied. 🤔';
    if (progress < 1.0) return 'Nearing your calorie goal. Choose wisely for your next meal! 🍽️';
    return 'You\'ve exceeded your goal. That\'s okay sometimes — tomorrow is a new day! 💪';
  }
}

// Calorie Ring Card
class _CalorieRingCard extends StatelessWidget {
  final double consumed;
  final int goal;
  final double progress;
  final double protein, carbs, fat, fiber;

  const _CalorieRingCard({
    required this.consumed,
    required this.goal,
    required this.progress,
    this.protein = 0, this.carbs = 0, this.fat = 0, this.fiber = 0,
  });

  Color _getProgressColor() {
    if (progress < 0.7) return AppColors.ringGreen;
    if (progress < 0.9) return AppColors.ringYellow;
    if (progress < 1.0) return AppColors.ringOrange;
    return AppColors.ringRed;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : null,
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 80,
                lineWidth: 14,
                percent: progress.clamp(0.0, 1.0),
                animation: true,
                animateFromLastPercent: true,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: _getProgressColor(),
                backgroundColor: _getProgressColor().withOpacity(0.15),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${consumed.toStringAsFixed(0)}', style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('of $goal', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
                    Text('kcal', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remaining', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${(goal - consumed).toStringAsFixed(0)}', style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.bold, color: _getProgressColor())),
                  Text('kcal', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _MiniMacro(label: 'Protein', value: '${protein.toStringAsFixed(1)}g', color: AppColors.proteinBlue),
                  _MiniMacro(label: 'Carbs', value: '${carbs.toStringAsFixed(1)}g', color: AppColors.carbsOrange),
                  _MiniMacro(label: 'Fat', value: '${fat.toStringAsFixed(1)}g', color: AppColors.fatRed),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniMacro({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label: ', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
          Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// Macros Row
class _MacrosRow extends StatelessWidget {
  final double protein, carbs, fat, fiber;
  final double proteinTarget, carbsTarget, fatTarget, fiberTarget;
  const _MacrosRow({
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.proteinTarget = 0,
    this.carbsTarget = 0,
    this.fatTarget = 0,
    this.fiberTarget = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroCard(label: 'Protein', value: protein, target: proteinTarget, unit: 'g', color: AppColors.proteinBlue, icon: Icons.fitness_center)),
        const SizedBox(width: 8),
        Expanded(child: _MacroCard(label: 'Carbs', value: carbs, target: carbsTarget, unit: 'g', color: AppColors.carbsOrange, icon: Icons.grain)),
        const SizedBox(width: 8),
        Expanded(child: _MacroCard(label: 'Fat', value: fat, target: fatTarget, unit: 'g', color: AppColors.fatRed, icon: Icons.water_drop)),
        const SizedBox(width: 8),
        Expanded(child: _MacroCard(label: 'Fiber', value: fiber, target: fiberTarget, unit: 'g', color: AppColors.fiberGreen, icon: Icons.eco)),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label, unit;
  final double value;
  final double target;
  final Color color;
  final IconData icon;
  const _MacroCard({required this.label, required this.value, required this.unit, required this.color, required this.icon, this.target = 0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTarget = target > 0;
    final progress = hasTarget ? (value / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value.toStringAsFixed(0), style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
          // Show the goal-derived target so macros track the calorie goal.
          Text(hasTarget ? '/ ${target.toStringAsFixed(0)}$unit' : '$unit',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: Colors.grey)),
          Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.grey)),
          if (hasTarget) ...[
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick-access card to the Wellness hub (mood/stress + wellness score).
class _WellnessQuickCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = ref.watch(todayWellnessProvider).asData?.value;
    final done = today != null;
    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const WellnessScreen())),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.self_improvement, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wellness Check-in',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                      done
                          ? 'Today logged — view your wellness score'
                          : 'Track mood & stress, get your wellness score',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (done)
              const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            else
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// Water Tracker Card
class _WaterTrackerCard extends StatelessWidget {
  final double currentMl, goalMl, progress;
  final int glasses;
  final VoidCallback onAddGlass, onRemoveGlass;

  const _WaterTrackerCard({
    required this.currentMl, required this.goalMl, required this.glasses,
    required this.progress, required this.onAddGlass, required this.onRemoveGlass,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final targetGlasses = (goalMl / 250).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.waterBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.water_drop, color: AppColors.waterBlue),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Water Tracker', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('$glasses/$targetGlasses glasses', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
                  ]),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onRemoveGlass,
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.waterBlue),
                  ),
                  IconButton(
                    onPressed: onAddGlass,
                    icon: const Icon(Icons.add_circle, color: AppColors.waterBlue, size: 32),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.waterLight.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.waterBlue),
            ),
          ),
          const SizedBox(height: 8),
          Text('${currentMl.toStringAsFixed(0)} / ${goalMl.toStringAsFixed(0)} ml', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// AI Tip Card
class _AITipCard extends StatelessWidget {
  final String tip;
  const _AITipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [AppColors.darkCard, AppColors.darkSurface] : [AppColors.primaryBg, const Color(0xFFFFF0E5)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.smart_toy, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }
}

// Today's Meals Section
class _TodayMealsSection extends ConsumerWidget {
  const _TodayMealsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todayCalorieLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Meals", style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodLogScreen())),
              child: Text('Add Food', style: TextStyle(fontFamily: 'Poppins', color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        logsAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.restaurant, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('No meals logged yet', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Tap + to add your first meal!', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                  ],
                ),
              );
            }

            final grouped = <String, List<CalorieLog>>{};
            for (final log in logs) {
              final key = log.mealType.name;
              grouped.putIfAbsent(key, () => []).add(log);
            }

            return Column(
              children: grouped.entries.map((entry) => _MealGroup(
                mealType: entry.key,
                logs: entry.value,
                onDelete: (id) async {
                  await LogService.deleteCalorieLog(id);
                  ref.invalidate(todayCalorieLogsProvider);
                  ref.invalidate(todayCalorieSummaryProvider);
                  ref.invalidate(weeklyCalorieLogsProvider);
                  ref.invalidate(monthlyCalorieLogsProvider);
                },
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }
}

class _MealGroup extends StatelessWidget {
  final String mealType;
  final List<CalorieLog> logs;
  final Function(String) onDelete;

  const _MealGroup({required this.mealType, required this.logs, required this.onDelete});

  IconData _getIcon() {
    switch (mealType) {
      case 'breakfast': return Icons.wb_sunny;
      case 'lunch': return Icons.wb_cloudy;
      case 'dinner': return Icons.nightlight;
      default: return Icons.cookie;
    }
  }

  String _getTitle() {
    switch (mealType) {
      case 'breakfast': return 'Breakfast';
      case 'lunch': return 'Lunch';
      case 'dinner': return 'Dinner';
      default: return 'Snack';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCal = logs.fold(0.0, (sum, log) => sum + log.calories);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(_getIcon(), size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(_getTitle(), style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text('${totalCal.toStringAsFixed(0)} kcal', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
              ],
            ),
          ),
          ...logs.map((log) => Dismissible(
            key: Key(log.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onDelete(log.id),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: AppColors.error,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(log.foodName, style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              subtitle: Text('P: ${log.protein.toStringAsFixed(1)}g  C: ${log.carbs.toStringAsFixed(1)}g  F: ${log.fat.toStringAsFixed(1)}g',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.grey)),
              trailing: Text('${log.calories.toStringAsFixed(0)} kcal', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
            ),
          )),
        ],
      ),
    );
  }
}

// BMI Quick Access Card
/// Prominent entry point to the AI Nutritionist (personalized goals).
class _NutritionistQuickCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const NutritionPlanScreen())),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.success.withOpacity(0.95),
            AppColors.success.withOpacity(0.75),
          ]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.success.withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.health_and_safety, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Nutritionist',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                      'Get a personalized calorie & water goal from your health info',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.92))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _BMIQuickCard extends StatelessWidget {
  final dynamic user;
  const _BMIQuickCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weight = user?.weight ?? 0.0;
    final height = user?.height ?? 0.0;

    // Calculate BMI if data available
    double? bmi;
    String bmiLabel = 'Not set';
    Color bmiColor = Colors.grey;

    if (weight > 0 && height > 0) {
      final heightM = height / 100;
      final calculatedBmi = weight / (heightM * heightM);
      bmi = calculatedBmi;
      if (calculatedBmi < 18.5) {
        bmiLabel = 'Underweight';
        bmiColor = Colors.blue;
      } else if (calculatedBmi < 25) {
        bmiLabel = 'Normal';
        bmiColor = AppColors.success;
      } else if (calculatedBmi < 30) {
        bmiLabel = 'Overweight';
        bmiColor = AppColors.warning;
      } else {
        bmiLabel = 'Obese';
        bmiColor = Colors.red;
      }
    }

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BMIScreen())),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: bmiColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.monitor_weight, color: bmiColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BMI Calculator', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  if (bmi != null)
                    Text('BMI: ${bmi.toStringAsFixed(1)} ($bmiLabel)', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: bmiColor))
                  else
                    Text('Set your weight & height to get started', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(bmi != null ? 'View' : 'Set up', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
