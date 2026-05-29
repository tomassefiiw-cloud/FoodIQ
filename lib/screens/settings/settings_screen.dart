import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _mealReminders = false;
  String _breakfastTime = AppConfig.defaultBreakfastTime;
  String _lunchTime = AppConfig.defaultLunchTime;
  String _dinnerTime = AppConfig.defaultDinnerTime;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calorie Goal
            _SectionHeader(title: 'Daily Calorie Goal'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${user?.calorieGoal ?? 2000} kcal', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const Icon(Icons.local_fire_department, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [1500, 2000, 2500, 3000].map((goal) => 
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text('$goal', style: GoogleFonts.poppins(fontSize: 12)),
                            selected: (user?.calorieGoal ?? 2000) == goal,
                            onSelected: (_) {
                              if (user != null) {
                                ref.read(authProvider.notifier).updateProfile(user.copyWith(calorieGoal: goal));
                              }
                            },
                            selectedColor: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Water Goal
            _SectionHeader(title: 'Daily Water Goal'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${user?.waterGoal ?? 2000} ml', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.waterBlue)),
                      const Icon(Icons.water_drop, color: AppColors.waterBlue),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [1500, 2000, 2500, 3000].map((goal) => 
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text('$goal', style: GoogleFonts.poppins(fontSize: 12)),
                            selected: (user?.waterGoal ?? 2000) == goal,
                            onSelected: (_) {
                              if (user != null) {
                                ref.read(authProvider.notifier).updateProfile(user.copyWith(waterGoal: goal));
                              }
                            },
                            selectedColor: AppColors.waterBlue.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Meal Reminders
            _SectionHeader(title: 'Meal Reminders'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Enable Meal Reminders', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text('Get notified at meal times', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    value: _mealReminders,
                    activeColor: AppColors.primary,
                    onChanged: (v) async {
                      if (v) await NotificationService.requestPermission();
                      setState(() => _mealReminders = v);
                      await NotificationService.scheduleMealReminders(
                        enabled: v,
                        breakfastTime: _breakfastTime,
                        lunchTime: _lunchTime,
                        dinnerTime: _dinnerTime,
                      );
                      if (v) NotificationService.showTestNotification();
                    },
                  ),
                  if (_mealReminders) ...[
                    const Divider(),
                    _TimeSetting(label: '🌅 Breakfast', time: _breakfastTime, onChanged: (t) {
                      setState(() => _breakfastTime = t);
                      NotificationService.scheduleMealReminders(enabled: true, breakfastTime: t, lunchTime: _lunchTime, dinnerTime: _dinnerTime);
                    }),
                    _TimeSetting(label: '🍽️ Lunch', time: _lunchTime, onChanged: (t) {
                      setState(() => _lunchTime = t);
                      NotificationService.scheduleMealReminders(enabled: true, breakfastTime: _breakfastTime, lunchTime: t, dinnerTime: _dinnerTime);
                    }),
                    _TimeSetting(label: '🌙 Dinner', time: _dinnerTime, onChanged: (t) {
                      setState(() => _dinnerTime = t);
                      NotificationService.scheduleMealReminders(enabled: true, breakfastTime: _breakfastTime, lunchTime: _lunchTime, dinnerTime: t);
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dark Mode
            _SectionHeader(title: 'Appearance'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: SwitchListTile(
                title: Text('Dark Mode', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text('Easy on the eyes at night', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                value: darkMode,
                activeColor: AppColors.primary,
                onChanged: (v) => ref.read(darkModeProvider.notifier).state = v,
              ),
            ),
            const SizedBox(height: 16),

            // About
            _SectionHeader(title: 'About'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('App Version', style: GoogleFonts.poppins()),
                      Text('v${AppConfig.appVersion}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Database', style: GoogleFonts.poppins()),
                      Text('183+ foods', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary));
  }
}

class _TimeSetting extends StatelessWidget {
  final String label;
  final String time;
  final Function(String) onChanged;

  const _TimeSetting({required this.label, required this.time, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      trailing: TextButton(
        onPressed: () async {
          final parts = time.split(':');
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
          );
          if (picked != null) {
            onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
          }
        },
        child: Text(time, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 16)),
      ),
    );
  }
}
