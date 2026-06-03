import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/calorie_log.dart';
import '../../models/water_log.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calorie_provider.dart';
import '../../providers/water_provider.dart';

/// Live analytics screen — Daily / Weekly / Monthly.
/// All data comes from Riverpod providers and updates immediately
/// after any log (camera, manual, browse).
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    ref.invalidate(todayCalorieSummaryProvider);
    ref.invalidate(todayCalorieLogsProvider);
    ref.invalidate(todayWaterSummaryProvider);
    ref.invalidate(weeklyCalorieLogsProvider);
    ref.invalidate(monthlyCalorieLogsProvider);
    ref.invalidate(weeklyWaterLogsProvider);
    ref.invalidate(monthlyWaterLogsProvider);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _refreshAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle:
              TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: AppColors.primary,
        child: TabBarView(
          controller: _tabController,
          children: [
            _DailyView(isDark: isDark),
            _WeeklyView(isDark: isDark),
            _MonthlyView(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DAILY VIEW
// ============================================================================
class _DailyView extends ConsumerWidget {
  final bool isDark;
  const _DailyView({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todayCalorieSummaryProvider);
    final waterAsync = ref.watch(todayWaterSummaryProvider);
    final logsAsync = ref.watch(todayCalorieLogsProvider);
    final user = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Summary",
              style: TextStyle(fontFamily: 'Poppins', 
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          summaryAsync.when(
            data: (s) => _MacroPieCard(summary: s, isDark: isDark),
            loading: () => _LoadingCard(height: 280, isDark: isDark),
            error: (e, _) => _ErrorCard(message: '$e', isDark: isDark),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: summaryAsync.when(
                  data: (s) => _StatCard(
                    title: 'Calories',
                    value: s.totalCalories.toStringAsFixed(0),
                    unit: '/ ${user?.calorieGoal ?? 2000} kcal',
                    icon: Icons.local_fire_department,
                    color: AppColors.primary,
                    progress: ((user?.calorieGoal ?? 2000) > 0)
                        ? s.totalCalories / (user?.calorieGoal ?? 2000)
                        : 0,
                    isDark: isDark,
                  ),
                  loading: () => _LoadingCard(height: 110, isDark: isDark),
                  error: (e, _) => _ErrorCard(message: '$e', isDark: isDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: waterAsync.when(
                  data: (w) => _StatCard(
                    title: 'Water',
                    value: w.glassCount.toString(),
                    unit:
                        '/ ${((user?.waterGoal ?? 2000) / 250).round()} glasses',
                    icon: Icons.water_drop,
                    color: AppColors.waterBlue,
                    progress: ((user?.waterGoal ?? 2000) > 0)
                        ? w.totalMl / (user?.waterGoal ?? 2000)
                        : 0,
                    isDark: isDark,
                  ),
                  loading: () => _LoadingCard(height: 110, isDark: isDark),
                  error: (e, _) => _ErrorCard(message: '$e', isDark: isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Meals breakdown',
              style: TextStyle(fontFamily: 'Poppins', 
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          logsAsync.when(
            data: (logs) => _MealBreakdownCard(logs: logs, isDark: isDark),
            loading: () => _LoadingCard(height: 160, isDark: isDark),
            error: (e, _) => _ErrorCard(message: '$e', isDark: isDark),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ============================================================================
// WEEKLY VIEW
// ============================================================================
class _WeeklyView extends ConsumerWidget {
  final bool isDark;
  const _WeeklyView({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyCalorieLogsProvider);
    final weeklyWaterAsync = ref.watch(weeklyWaterLogsProvider);
    final user = ref.watch(currentUserProvider);
    final goal = (user?.calorieGoal ?? 2000).toDouble();
    final waterGoal = (user?.waterGoal ?? 2000).toDouble();

    return weeklyAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load: $e',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
        ),
      ),
      data: (days) => _RangeView(
        title: 'Last 7 Days',
        days: days,
        goal: goal,
        labelFormat: 'E',
        isDark: isDark,
        waterDays: weeklyWaterAsync.asData?.value ?? const [],
        waterGoal: waterGoal,
      ),
    );
  }
}

// ============================================================================
// MONTHLY VIEW
// ============================================================================
class _MonthlyView extends ConsumerWidget {
  final bool isDark;
  const _MonthlyView({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(monthlyCalorieLogsProvider);
    final monthlyWaterAsync = ref.watch(monthlyWaterLogsProvider);
    final user = ref.watch(currentUserProvider);
    final goal = (user?.calorieGoal ?? 2000).toDouble();
    final waterGoal = (user?.waterGoal ?? 2000).toDouble();

    return monthlyAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load: $e',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
        ),
      ),
      data: (days) => _RangeView(
        title: 'Last 30 Days',
        days: days,
        goal: goal,
        labelFormat: 'd',
        isDark: isDark,
        waterDays: monthlyWaterAsync.asData?.value ?? const [],
        waterGoal: waterGoal,
      ),
    );
  }
}
// ============================================================================
// Shared range view (weekly + monthly use this)
// ============================================================================
class _RangeView extends StatelessWidget {
  final String title;
  final List<DailySummary> days;
  final double goal;
  final String labelFormat;
  final bool isDark;
  final List<WaterSummary> waterDays;
  final double waterGoal;
  const _RangeView({
    required this.title,
    required this.days,
    required this.goal,
    required this.labelFormat,
    required this.isDark,
    this.waterDays = const [],
    this.waterGoal = 2000,
  });

  @override
  Widget build(BuildContext context) {
    final avgCal = days.isEmpty
        ? 0.0
        : days.map((d) => d.totalCalories).reduce((a, b) => a + b) /
            days.length;
    final totalCal =
        days.fold<double>(0.0, (a, b) => a + b.totalCalories);
    final daysOnTrack = days
        .where((d) => d.totalCalories > 0 && d.totalCalories <= goal)
        .length;
    final maxCal = days.isEmpty
        ? goal * 1.2
        : days.map((d) => d.totalCalories).reduce((a, b) => a > b ? a : b);

    // Avg macros across days that have data
    final daysWithData = days.where((d) => d.totalCalories > 0).toList();
    final avgProt = daysWithData.isEmpty
        ? 0.0
        : daysWithData.map((d) => d.totalProtein).reduce((a, b) => a + b) /
            daysWithData.length;
    final avgCarb = daysWithData.isEmpty
        ? 0.0
        : daysWithData.map((d) => d.totalCarbs).reduce((a, b) => a + b) /
            daysWithData.length;
    final avgFat = daysWithData.isEmpty
        ? 0.0
        : daysWithData.map((d) => d.totalFat).reduce((a, b) => a + b) /
            daysWithData.length;

    // ---- Water stats over the same range ----
    final hasWater = waterDays.isNotEmpty;
    final waterDaysWithData =
        waterDays.where((w) => w.totalMl > 0).toList();
    final avgWaterMl = waterDays.isEmpty
        ? 0.0
        : waterDays.map((w) => w.totalMl).reduce((a, b) => a + b) /
            waterDays.length;
    final totalWaterMl =
        waterDays.fold<double>(0.0, (a, b) => a + b.totalMl);
    final waterDaysOnTrack =
        waterDays.where((w) => w.totalMl >= waterGoal).length;
    final maxWaterMl = waterDays.isEmpty
        ? waterGoal * 1.2
        : waterDays.map((w) => w.totalMl).reduce((a, b) => a > b ? a : b);
    final avgWaterGlasses = avgWaterMl / WaterLog.mlPerGlass;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontFamily: 'Poppins', 
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  title: 'Daily avg',
                  value: avgCal.toStringAsFixed(0),
                  unit: 'kcal',
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  title: 'Total',
                  value: totalCal.toStringAsFixed(0),
                  unit: 'kcal',
                  color: AppColors.carbsOrange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  title: 'On track',
                  value: '$daysOnTrack',
                  unit: '/ ${days.length}',
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily calories',
                    style: TextStyle(fontFamily: 'Poppins', 
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      maxY: (maxCal > goal ? maxCal : goal) * 1.15,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.primary,
                          getTooltipItem: (group, _, rod, __) {
                            final i = group.x.toInt();
                            if (i < 0 || i >= days.length) return null;
                            final d = days[i];
                            return BarTooltipItem(
                              '${DateFormat('MMM d').format(d.date)}\n'
                              '${rod.toY.toStringAsFixed(0)} kcal',
                              TextStyle(fontFamily: 'Poppins', 
                                  color: Colors.white, fontSize: 11),
                            );
                          },
                        ),
                      ),
                      gridData:
                          const FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: days.length > 15 ? 5 : 1,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= days.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                    DateFormat(labelFormat)
                                        .format(days[i].date),
                                    style: TextStyle(fontFamily: 'Poppins', 
                                        fontSize: 9,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) => Text(
                                '${value.toInt()}',
                                style: TextStyle(fontFamily: 'Poppins', 
                                    fontSize: 9, color: Colors.grey)),
                          ),
                        ),
                      ),
                      extraLinesData: ExtraLinesData(horizontalLines: [
                        HorizontalLine(
                          y: goal,
                          color: AppColors.success.withOpacity(0.7),
                          strokeWidth: 1.5,
                          dashArray: [4, 4],
                        ),
                      ]),
                      barGroups: List.generate(days.length, (i) {
                        final v = days[i].totalCalories;
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: v,
                            width: days.length > 15 ? 6 : 14,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 12,
                        height: 2,
                        color: AppColors.success.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text('Goal (${goal.toStringAsFixed(0)} kcal)',
                        style: TextStyle(fontFamily: 'Poppins', 
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Macros average
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Average macros per day',
                    style: TextStyle(fontFamily: 'Poppins', 
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _MacroRow(
                            label: 'Protein',
                            value: avgProt,
                            color: AppColors.proteinBlue)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _MacroRow(
                            label: 'Carbs',
                            value: avgCarb,
                            color: AppColors.carbsOrange)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _MacroRow(
                            label: 'Fat',
                            value: avgFat,
                            color: AppColors.fatRed)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ================= WATER SECTION =================
          Row(
            children: [
              Icon(Icons.water_drop, color: AppColors.waterBlue, size: 18),
              const SizedBox(width: 6),
              Text('Water intake',
                  style: TextStyle(fontFamily: 'Poppins',
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),

          // Water mini-stats
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  title: 'Daily avg',
                  value: avgWaterGlasses.toStringAsFixed(1),
                  unit: 'glasses',
                  color: AppColors.waterBlue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  title: 'Total',
                  value: (totalWaterMl / 1000).toStringAsFixed(1),
                  unit: 'litres',
                  color: AppColors.waterBlue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  title: 'On track',
                  value: '$waterDaysOnTrack',
                  unit: '/ ${waterDays.length}',
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Water bar chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily water (glasses)',
                    style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                if (!hasWater)
                  SizedBox(
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop_outlined,
                              size: 40,
                              color: AppColors.waterBlue.withOpacity(0.3)),
                          const SizedBox(height: 8),
                          Text('No water logged in this period',
                              style: TextStyle(fontFamily: 'Poppins',
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        maxY: ((maxWaterMl > waterGoal
                                    ? maxWaterMl
                                    : waterGoal) *
                                1.15) /
                            WaterLog.mlPerGlass,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => AppColors.waterBlue,
                            getTooltipItem: (group, _, rod, __) {
                              final i = group.x.toInt();
                              if (i < 0 || i >= waterDays.length) return null;
                              final w = waterDays[i];
                              return BarTooltipItem(
                                '${DateFormat('MMM d').format(w.date)}\n'
                                '${rod.toY.toStringAsFixed(1)} glasses\n'
                                '${w.totalMl.toStringAsFixed(0)} ml',
                                TextStyle(fontFamily: 'Poppins',
                                    color: Colors.white, fontSize: 11),
                              );
                            },
                          ),
                        ),
                        gridData: const FlGridData(
                            show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: waterDays.length > 15 ? 5 : 1,
                              getTitlesWidget: (value, _) {
                                final i = value.toInt();
                                if (i < 0 || i >= waterDays.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                      DateFormat(labelFormat)
                                          .format(waterDays[i].date),
                                      style: TextStyle(fontFamily: 'Poppins',
                                          fontSize: 9,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54)),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, _) => Text(
                                  '${value.toInt()}',
                                  style: TextStyle(fontFamily: 'Poppins',
                                      fontSize: 9, color: Colors.grey)),
                            ),
                          ),
                        ),
                        extraLinesData: ExtraLinesData(horizontalLines: [
                          HorizontalLine(
                            y: waterGoal / WaterLog.mlPerGlass,
                            color: AppColors.success.withOpacity(0.7),
                            strokeWidth: 1.5,
                            dashArray: [4, 4],
                          ),
                        ]),
                        barGroups: List.generate(waterDays.length, (i) {
                          final v =
                              waterDays[i].totalMl / WaterLog.mlPerGlass;
                          return BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: v,
                              width: waterDays.length > 15 ? 6 : 14,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.waterBlue,
                                  AppColors.waterBlue.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 12,
                          height: 2,
                          color: AppColors.success.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                          'Goal (${(waterGoal / WaterLog.mlPerGlass).toStringAsFixed(0)} glasses)',
                          style: TextStyle(fontFamily: 'Poppins',
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ============================================================================
// Helpers: cards & widgets
// ============================================================================

class _MacroPieCard extends StatelessWidget {
  final DailySummary summary;
  final bool isDark;
  const _MacroPieCard({required this.summary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final p = summary.totalProtein;
    final c = summary.totalCarbs;
    final f = summary.totalFat;
    final total = p + c + f;
    final hasData = total > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Macro distribution',
              style: TextStyle(fontFamily: 'Poppins', 
                  fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: hasData
                ? Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 38,
                            sections: [
                              PieChartSectionData(
                                color: AppColors.proteinBlue,
                                value: p,
                                title: '${(p / total * 100).round()}%',
                                titleStyle: TextStyle(fontFamily: 'Poppins', 
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11),
                                radius: 50,
                              ),
                              PieChartSectionData(
                                color: AppColors.carbsOrange,
                                value: c,
                                title: '${(c / total * 100).round()}%',
                                titleStyle: TextStyle(fontFamily: 'Poppins', 
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11),
                                radius: 50,
                              ),
                              PieChartSectionData(
                                color: AppColors.fatRed,
                                value: f,
                                title: '${(f / total * 100).round()}%',
                                titleStyle: TextStyle(fontFamily: 'Poppins', 
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11),
                                radius: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LegendRow(
                                color: AppColors.proteinBlue,
                                label: 'Protein',
                                value: '${p.toStringAsFixed(1)} g'),
                            const SizedBox(height: 8),
                            _LegendRow(
                                color: AppColors.carbsOrange,
                                label: 'Carbs',
                                value: '${c.toStringAsFixed(1)} g'),
                            const SizedBox(height: 8),
                            _LegendRow(
                                color: AppColors.fatRed,
                                label: 'Fat',
                                value: '${f.toStringAsFixed(1)} g'),
                            const SizedBox(height: 8),
                            _LegendRow(
                                color: AppColors.fiberGreen,
                                label: 'Fiber',
                                value:
                                    '${summary.totalFiber.toStringAsFixed(1)} g'),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart,
                            size: 56,
                            color: AppColors.primary.withOpacity(0.3)),
                        const SizedBox(height: 8),
                        Text('No data yet today',
                            style: TextStyle(fontFamily: 'Poppins', 
                                color: Colors.grey, fontSize: 13)),
                        Text('Log a meal to see your macro breakdown',
                            style: TextStyle(fontFamily: 'Poppins', 
                                color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendRow(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(label,
                style: TextStyle(fontFamily: 'Poppins', 
                    fontSize: 12, fontWeight: FontWeight.w500))),
        Text(value,
            style: TextStyle(fontFamily: 'Poppins', 
                fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;
  final double progress;
  final bool isDark;
  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(fontFamily: 'Poppins', 
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(fontFamily: 'Poppins', 
                      fontWeight: FontWeight.w700, fontSize: 22)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(unit,
                    style: TextStyle(fontFamily: 'Poppins', 
                        fontSize: 10, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title, value, unit;
  final Color color;
  final bool isDark;
  const _MiniStat({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontFamily: 'Poppins', 
                  fontWeight: FontWeight.w700, fontSize: 18, color: color)),
          Text(unit,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MacroRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Center(
            child: Text(label[0],
                style: TextStyle(fontFamily: 'Poppins', 
                    color: color, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
        Text('${value.toStringAsFixed(1)} g',
            style: TextStyle(fontFamily: 'Poppins', 
                fontWeight: FontWeight.w700, fontSize: 14, color: color)),
      ],
    );
  }
}

class _MealBreakdownCard extends StatelessWidget {
  final List<CalorieLog> logs;
  final bool isDark;
  const _MealBreakdownCard({required this.logs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_menu,
                  size: 48, color: AppColors.primary.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text('No meals logged today',
                  style:
                      TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
              Text('Use the + button to add your first meal',
                  style:
                      TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      );
    }

    // Group by meal type
    final byMeal = <String, List<CalorieLog>>{};
    for (final l in logs) {
      byMeal.putIfAbsent(l.mealType.name, () => []).add(l);
    }

    final mealOrder = ['breakfast', 'lunch', 'dinner', 'snack'];
    final mealColors = {
      'breakfast': AppColors.honey,
      'lunch': AppColors.primary,
      'dinner': AppColors.fatRed,
      'snack': Colors.brown,
    };
    final mealIcons = {
      'breakfast': Icons.free_breakfast,
      'lunch': Icons.lunch_dining,
      'dinner': Icons.dinner_dining,
      'snack': Icons.cookie,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: mealOrder.where(byMeal.containsKey).map((meal) {
          final entries = byMeal[meal]!;
          final cal = entries.fold<double>(0, (a, b) => a + b.calories);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (mealColors[meal] ?? Colors.grey).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(mealIcons[meal] ?? Icons.restaurant,
                      color: mealColors[meal], size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal[0].toUpperCase() + meal.substring(1),
                          style: TextStyle(fontFamily: 'Poppins', 
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('${entries.length} item${entries.length == 1 ? '' : 's'}',
                          style: TextStyle(fontFamily: 'Poppins', 
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Text('${cal.toStringAsFixed(0)} kcal',
                    style: TextStyle(fontFamily: 'Poppins', 
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 14)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  final bool isDark;
  const _LoadingCard({required this.height, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorCard({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
