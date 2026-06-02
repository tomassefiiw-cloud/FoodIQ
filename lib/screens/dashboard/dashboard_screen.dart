import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
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
                  style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
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
            Text('FoodIQ', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22)),
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
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _getMotivation(),
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
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

              // Macros Row
              calorieSummary.when(
                data: (summary) => _MacrosRow(
                  protein: summary.totalProtein,
                  carbs: summary.totalCarbs,
                  fat: summary.totalFat,
                  fiber: summary.totalFiber,
                ),
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
                      });
                    }
                  },
                  onRemoveGlass: () {
                    final userId = user?.id;
                    if (userId != null) {
                      LogService.removeLastWaterLog(userId).then((_) {
                        ref.invalidate(todayWaterSummaryProvider);
                        ref.invalidate(todayWaterLogsProvider);
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
                    Text('${consumed.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('of $goal', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                    Text('kcal', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remaining', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${(goal - consumed).toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: _getProgressColor())),
                  Text('kcal', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
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
          Text('$label: ', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
          Text(value, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// Macros Row
class _MacrosRow extends StatelessWidget {
  final double protein, carbs, fat, fiber;
  const _MacrosRow({this.protein = 0, this.carbs = 0, this.fat = 0, this.fiber = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroCard(label: 'Protein', value: protein, unit: 'g', color: AppColors.proteinBlue, icon: Icons.fitness_center)),
        const SizedBox(width: 8),
        Expanded(child: _MacroCard(label: 'Carbs', value: carbs, unit: 'g', color: AppColors.carbsOrange, icon: Icons.grain)),
        const SizedBox(width: 8),
        Expanded(child: _MacroCard(label: 'Fat', value: fat, unit: 'g', color: AppColors.fatRed, icon: Icons.water_drop)),
        const SizedBox(width: 8),
        Expanded(child: _MacroCard(label: 'Fiber', value: fiber, unit: 'g', color: AppColors.fiberGreen, icon: Icons.eco)),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label, unit;
  final double value;
  final Color color;
  final IconData icon;
  const _MacroCard({required this.label, required this.value, required this.unit, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Text('${value.toStringAsFixed(1)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ],
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
                    Text('Water Tracker', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('$glasses/$targetGlasses glasses', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
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
          Text('${currentMl.toStringAsFixed(0)} / ${goalMl.toStringAsFixed(0)} ml', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
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
          Expanded(child: Text(tip, style: GoogleFonts.poppins(fontSize: 13, height: 1.5))),
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
            Text("Today's Meals", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodLogScreen())),
              child: Text('Add Food', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
                    Text('No meals logged yet', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Tap + to add your first meal!', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
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
                Text(_getTitle(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text('${totalCal.toStringAsFixed(0)} kcal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
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
              title: Text(log.foodName, style: GoogleFonts.poppins(fontSize: 13)),
              subtitle: Text('P: ${log.protein.toStringAsFixed(1)}g  C: ${log.carbs.toStringAsFixed(1)}g  F: ${log.fat.toStringAsFixed(1)}g',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              trailing: Text('${log.calories.toStringAsFixed(0)} kcal', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ),
          )),
        ],
      ),
    );
  }
}
