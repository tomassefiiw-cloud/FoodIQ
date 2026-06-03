import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _loaded = false;
  String _diagnosticInfo = '';

  static const _kReminders = 'meal_reminders_enabled';
  static const _kBreakfast = 'reminder_breakfast_time';
  static const _kLunch = 'reminder_lunch_time';
  static const _kDinner = 'reminder_dinner_time';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mealReminders = prefs.getBool(_kReminders) ?? false;
      _breakfastTime =
          prefs.getString(_kBreakfast) ?? AppConfig.defaultBreakfastTime;
      _lunchTime = prefs.getString(_kLunch) ?? AppConfig.defaultLunchTime;
      _dinnerTime = prefs.getString(_kDinner) ?? AppConfig.defaultDinnerTime;
      _loaded = true;
    });
    if (_mealReminders) {
      _loadDiagnosticInfo();
    }
  }

  Future<void> _loadDiagnosticInfo() async {
    final info = await NotificationService.getDiagnosticInfo();
    if (mounted) {
      setState(() => _diagnosticInfo = info);
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminders, _mealReminders);
    await prefs.setString(_kBreakfast, _breakfastTime);
    await prefs.setString(_kLunch, _lunchTime);
    await prefs.setString(_kDinner, _dinnerTime);
  }

  Future<void> _toggleReminders(bool enabled) async {
    if (enabled) {
      // Request permissions first
      final granted = await NotificationService.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification permission was not granted. '
                'Please enable it in your phone settings.',
                style: TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    setState(() => _mealReminders = enabled);
    await NotificationService.scheduleMealReminders(
      enabled: enabled,
      breakfastTime: _breakfastTime,
      lunchTime: _lunchTime,
      dinnerTime: _dinnerTime,
      showTest: enabled, // Only show test notification when enabling
    );
    await _savePrefs();

    if (enabled && mounted) {
      await _loadDiagnosticInfo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminders ON! You\'ll get notifications at meal times. '
              'One test notification was sent to confirm it works.',
              style: TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      _loadDiagnosticInfo();
    }
  }

  Future<void> _updateTime(String meal, String newTime) async {
    setState(() {
      switch (meal) {
        case 'breakfast':
          _breakfastTime = newTime;
          break;
        case 'lunch':
          _lunchTime = newTime;
          break;
        case 'dinner':
          _dinnerTime = newTime;
          break;
      }
    });
    await _savePrefs();

    // Re-schedule all reminders with the updated time
    if (_mealReminders) {
      await NotificationService.scheduleMealReminders(
        enabled: true,
        breakfastTime: _breakfastTime,
        lunchTime: _lunchTime,
        dinnerTime: _dinnerTime,
        showTest: false,
      );

      if (mounted) {
        await _loadDiagnosticInfo();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$meal reminder updated to $newTime',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Full repair: re-requests all permissions, recreates the notification
  /// channel, and re-schedules all reminders.
  Future<void> _repairNotifications() async {
    try {
      // 1. Re-request ALL permissions
      await NotificationService.requestPermission();

      // 2. Re-schedule from scratch
      await NotificationService.rescheduleFromPrefs();

      // 3. Update diagnostics
      await _loadDiagnosticInfo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notifications repaired! If you still don\'t see them, check:\n'
              '1. Phone Settings > Apps > FoodIQ > Notifications\n'
              '2. Phone Settings > Apps > FoodIQ > Battery > Unrestricted',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Repair failed: $e',
                style: TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
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
                      Text('${user?.calorieGoal ?? 2000} kcal', style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
                            label: Text('$goal', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
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
                      Text('${user?.waterGoal ?? 2000} ml', style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.waterBlue)),
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
                            label: Text('$goal', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
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
                    title: Text('Enable Meal Reminders', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    subtitle: Text('Get notified at meal times & if you haven\'t logged food', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                    value: _mealReminders,
                    activeColor: AppColors.primary,
                    onChanged: _toggleReminders,
                  ),
                  if (_mealReminders) ...[
                    const Divider(),
                    _TimeSetting(label: 'Breakfast', time: _breakfastTime, onChanged: (t) => _updateTime('breakfast', t)),
                    _TimeSetting(label: 'Lunch', time: _lunchTime, onChanged: (t) => _updateTime('lunch', t)),
                    _TimeSetting(label: 'Dinner', time: _dinnerTime, onChanged: (t) => _updateTime('dinner', t)),
                    const Divider(),

                    // Info about how notifications work
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text('How notifications work',
                                style: TextStyle(fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '1. You get ONE test notification when you first enable reminders\n'
                            '2. Scheduled reminders fire at breakfast, lunch & dinner times\n'
                            '3. If you haven\'t logged a meal, you\'ll get a friendly reminder 1.5 hours after each meal time',
                            style: TextStyle(fontFamily: 'Poppins',
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Repair Notifications Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _repairNotifications,
                        icon: const Icon(Icons.build),
                        label: Text(
                          'Repair Notifications',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(color: AppColors.warning),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Notification Diagnostic Info
                    if (_diagnosticInfo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('Notification Status',
                                  style: TextStyle(fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(_diagnosticInfo,
                              style: TextStyle(fontFamily: 'Poppins',
                                fontSize: 11,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tip: If you don\'t see notifications:\n'
                        '1. Go to Phone Settings > Apps > FoodIQ > Notifications > Enable all\n'
                        '2. Also check "Alarms & reminders" permission\n'
                        '3. Disable battery optimization for FoodIQ\n'
                        '4. On Samsung/Xiaomi/Huawei: lock the app in recent tasks',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey),
                      ),
                    ],
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
                title: Text('Dark Mode', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                subtitle: Text('Easy on the eyes at night', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                value: darkMode,
                activeColor: AppColors.primary,
                onChanged: (v) => ref.read(darkModeProvider.notifier).set(v),
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
                      Text('App Version', style: TextStyle(fontFamily: 'Poppins')),
                      Text('v${AppConfig.appVersion}', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Database', style: TextStyle(fontFamily: 'Poppins')),
                      Text('183+ foods', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.primary)),
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
    return Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary));
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
      title: Text(label, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
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
        child: Text(time, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 16)),
      ),
    );
  }
}
