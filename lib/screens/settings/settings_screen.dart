import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _loaded = false;
  bool _isTestingNotif = false;

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
            content: Text('⚠️ Notification permission was not granted. '
                'Please enable it in your phone settings.',
                style: GoogleFonts.poppins()),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 4),
          ),
        );
        // Still allow enabling — they can grant later
      }
    }

    setState(() => _mealReminders = enabled);
    await NotificationService.scheduleMealReminders(
      enabled: enabled,
      breakfastTime: _breakfastTime,
      lunchTime: _lunchTime,
      dinnerTime: _dinnerTime,
    );
    await _savePrefs();

    if (enabled && mounted) {
      // Show immediate test notification
      await NotificationService.showTestNotification();
      // Also schedule a quick 15-sec test to verify scheduled ones work
      await NotificationService.scheduleQuickTestNotification(delaySeconds: 15);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔔 Reminders ON! A test notification will appear in 15 seconds. '
              'You should see two notifications now.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
    await NotificationService.scheduleMealReminders(
      enabled: true,
      breakfastTime: _breakfastTime,
      lunchTime: _lunchTime,
      dinnerTime: _dinnerTime,
    );

    if (mounted) {
      // Schedule a quick test to verify the new time works
      await NotificationService.scheduleQuickTestNotification(delaySeconds: 15);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⏰ $meal reminder updated to $newTime. Test notification in 15s!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _sendTestNotification() async {
    setState(() => _isTestingNotif = true);

    // First verify permissions
    final enabled = await NotificationService.areNotificationsEnabled();
    if (!enabled) {
      await NotificationService.requestPermission();
    }

    // Show immediate notification
    await NotificationService.showTestNotification();
    // Schedule one for 15 seconds later
    await NotificationService.scheduleQuickTestNotification(delaySeconds: 15);

    setState(() => _isTestingNotif = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🔔 Test sent! You should see 1 notification now and another in 15s. '
            'If you don\'t see them, check your phone\'s notification settings for FoodIQ.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

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
                    onChanged: _toggleReminders,
                  ),
                  if (_mealReminders) ...[
                    const Divider(),
                    _TimeSetting(label: '🌅 Breakfast', time: _breakfastTime, onChanged: (t) => _updateTime('breakfast', t)),
                    _TimeSetting(label: '🍽️ Lunch', time: _lunchTime, onChanged: (t) => _updateTime('lunch', t)),
                    _TimeSetting(label: '🌙 Dinner', time: _dinnerTime, onChanged: (t) => _updateTime('dinner', t)),
                    const Divider(),
                    // Test Notification Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isTestingNotif ? null : _sendTestNotification,
                        icon: _isTestingNotif
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.notifications_active),
                        label: Text(
                          _isTestingNotif ? 'Sending...' : 'Send Test Notification',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💡 Tip: If you don\'t see notifications, go to your phone\'s '
                      'Settings → Apps → FoodIQ → Notifications and make sure '
                      'they\'re allowed. Also check "Alarms & reminders" permission.',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    ),
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
