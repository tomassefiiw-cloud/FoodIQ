import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Analytics', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            indicatorColor: AppColors.primary,
            tabs: const [Tab(text: 'Daily'), Tab(text: 'Weekly'), Tab(text: 'Monthly')],
          ),
        ),
        body: TabBarView(
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

class _DailyView extends StatelessWidget {
  final bool isDark;
  const _DailyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Summary', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Macro Pie Chart placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart, size: 60, color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  Text('Macro Distribution', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: AppColors.proteinBlue, label: 'Protein'),
                      const SizedBox(width: 16),
                      _LegendDot(color: AppColors.carbsOrange, label: 'Carbs'),
                      const SizedBox(width: 16),
                      _LegendDot(color: AppColors.fatRed, label: 'Fat'),
                      const SizedBox(width: 16),
                      _LegendDot(color: AppColors.fiberGreen, label: 'Fiber'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats cards
          Row(
            children: [
              Expanded(child: _StatCard(title: 'Avg Calories', value: '1,850', unit: 'kcal/day', icon: Icons.local_fire_department, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Avg Water', value: '6.5', unit: 'glasses/day', icon: Icons.water_drop, color: AppColors.waterBlue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyView extends StatelessWidget {
  final bool isDark;
  const _WeeklyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 60, color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  Text('Weekly Calorie Chart', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatCard(title: 'Weekly Avg', value: '1,920', unit: 'kcal', icon: Icons.trending_up, color: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Best Day', value: '1,800', unit: 'kcal', icon: Icons.star, color: AppColors.warmGold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(title: 'Streak', value: '5', unit: 'days', icon: Icons.local_fire_department, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Avg Water', value: '1,750', unit: 'ml', icon: Icons.water_drop, color: AppColors.waterBlue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyView extends StatelessWidget {
  final bool isDark;
  const _MonthlyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Month', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, size: 60, color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  Text('Monthly Heatmap', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(unit, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 11)),
      ],
    );
  }
}
