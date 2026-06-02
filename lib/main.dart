import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_config.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase first
  await SupabaseService.initialize();

  // Initialize notifications (timezone + channel)
  await NotificationService.initialize();

  // Re-schedule meal reminders if they were enabled previously
  try {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('meal_reminders_enabled') ?? false;
    if (enabled) {
      // Request permission again in case it was revoked
      await NotificationService.requestPermission();

      await NotificationService.scheduleMealReminders(
        enabled: true,
        breakfastTime: prefs.getString('reminder_breakfast_time') ??
            AppConfig.defaultBreakfastTime,
        lunchTime: prefs.getString('reminder_lunch_time') ??
            AppConfig.defaultLunchTime,
        dinnerTime: prefs.getString('reminder_dinner_time') ??
            AppConfig.defaultDinnerTime,
      );
      print('[main] ✅ Meal reminders re-scheduled on app start');
    }
  } catch (e) {
    print('[main] ⚠️ Failed to re-schedule reminders: $e');
    // best-effort; settings screen will re-schedule when user opens it
  }

  runApp(const ProviderScope(child: FoodIQApp()));
}
