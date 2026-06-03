import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_strings.dart';
import 'notification_message_generator.dart';

/// FoodIQ Notification Service — real OS push notifications.
///
/// v6 — cleaned up notification behavior:
///  - Only ONE test notification on first install (when user enables reminders)
///  - NO confirmation notification after scheduling
///  - NO quick test notification
///  - Scheduled notifications at meal times only
///  - Meal logging reminder if user hasn't logged any food
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel ID bumped to _v6 — fresh channel
  static const String _channelId = 'foodiq_meal_reminder_v6';
  static const String _channelName = 'Meal Reminders';
  static const String _channelDescription =
      'Reminders for breakfast, lunch, and dinner.';

  // Second channel for meal logging reminders
  static const String _reminderChannelId = 'foodiq_meal_log_reminder';
  static const String _reminderChannelName = 'Meal Logging Reminders';
  static const String _reminderChannelDescription =
      'Reminds you to log your meals if you haven\'t eaten yet.';

  static bool _initialized = false;
  static String _tzName = 'UTC';

  static const int idBreakfast = 1001;
  static const int idLunch = 1002;
  static const int idDinner = 1003;
  static const int idInstallTest = 9999; // ONE test on install
  static const int idMealLogReminder = 2001; // meal logging reminder

  static Future<void> initialize() async {
    if (_initialized) return;

    // 1. Load timezone database
    tz_data.initializeTimeZones();
    await _setupTimezone();

    // 2. Initialize the plugin
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (_) {});

    // 3. On Android: delete old channels & create fresh high-importance one
    if (Platform.isAndroid) {
      await _ensureChannelExists();
    }

    _initialized = true;
    print('[Notif] Initialized — tz=$_tzName');
  }

  /// Ensure the v6 notification channel exists with MAX importance.
  static Future<void> _ensureChannelExists() async {
    if (!Platform.isAndroid) return;

    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Delete ALL old channels that might have wrong importance
    for (final old in [
      'foodiq_meal_reminder',
      'foodiq_meal_reminder_v2',
      'foodiq_meal_reminder_v3',
      'foodiq_meal_reminder_v4',
      'foodiq_meal_reminder_v5',
    ]) {
      try {
        await impl?.deleteNotificationChannel(old);
      } catch (_) {}
    }

    // Always (re)create the v6 channel with MAX importance.
    try {
      await impl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        ),
      );
    } catch (e) {
      print('[Notif] createNotificationChannel failed: $e');
    }

    // Create the meal log reminder channel
    try {
      await impl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _reminderChannelId,
          _reminderChannelName,
          description: _reminderChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
    } catch (e) {
      print('[Notif] createReminderChannel failed: $e');
    }
  }

  /// Strict OS timezone detection with multiple fallbacks.
  static Future<void> _setupTimezone() async {
    // 1) Plugin (IANA name from OS) — best
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      if (name.isNotEmpty) {
        final location = _safeGetLocation(name);
        if (location != null) {
          tz.setLocalLocation(location);
          _tzName = name;
          print('[Notif] Timezone from plugin: $_tzName');
          return;
        }
      }
    } catch (e) {
      print('[Notif] FlutterTimezone failed: $e');
    }

    // 2) Try common African timezone names directly
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    final africanTzs = _guessAfricanTimezone(offsetMinutes);
    for (final tzName in africanTzs) {
      final location = _safeGetLocation(tzName);
      if (location != null) {
        tz.setLocalLocation(location);
        _tzName = tzName;
        print('[Notif] Timezone from African guess: $_tzName');
        return;
      }
    }

    // 3) Match OS offset to known IANA zone
    try {
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset ~/ (60 * 1000) == offsetMinutes) {
          tz.setLocalLocation(loc);
          _tzName = loc.name;
          print('[Notif] Timezone from offset match: $_tzName');
          return;
        }
      }
    } catch (e) {
      print('[Notif] offset lookup failed: $e');
    }

    // 4) Etc/GMT+N (POSIX sign INVERTED: UTC+3 -> Etc/GMT-3)
    try {
      final hours = DateTime.now().timeZoneOffset.inHours;
      final etcName = hours == 0
          ? 'UTC'
          : 'Etc/GMT${hours > 0 ? '-' : '+'}${hours.abs()}';
      final location = _safeGetLocation(etcName);
      if (location != null) {
        tz.setLocalLocation(location);
        _tzName = etcName;
        print('[Notif] Timezone from Etc/GMT: $_tzName');
        return;
      }
    } catch (e) {
      print('[Notif] Etc/GMT fallback failed: $e');
    }

    tz.setLocalLocation(tz.getLocation('UTC'));
    _tzName = 'UTC';
  }

  /// Safely get a timezone location, returning null on failure.
  static tz.Location? _safeGetLocation(String name) {
    try {
      return tz.getLocation(name);
    } catch (_) {
      return null;
    }
  }

  /// Guess African timezone names from the current UTC offset.
  static List<String> _guessAfricanTimezone(int offsetMinutes) {
    final map = <int, List<String>>{
      -60: ['Africa/Lagos', 'Africa/Algiers', 'Africa/Tunis'],
      -120: ['Africa/Cairo', 'Africa/Johannesburg', 'Africa/Maputo'],
      -180: ['Africa/Nairobi', 'Africa/Addis_Ababa', 'Africa/Kampala', 'Africa/Dar_es_Salaam'],
      -240: ['Africa/Mogadishu'],
      0: ['Africa/Casablanca', 'Africa/Accra', 'Africa/Monrovia'],
    };
    return map[offsetMinutes] ?? [];
  }

  static String get timezoneName => _tzName;

  /// Returns true if OS reports notifications enabled for this app.
  static Future<bool> areNotificationsEnabled() async {
    if (!Platform.isAndroid) return true;
    try {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await impl?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if exact alarms are allowed (Android 12+).
  static Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await impl?.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request all necessary permissions for reliable notifications.
  static Future<bool> requestPermission() async {
    if (!_initialized) await initialize();

    if (Platform.isAndroid) {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      bool ok = true;

      // Plugin-based request (most reliable on Pixel + stock Android)
      try {
        final r = await impl?.requestNotificationsPermission();
        if (r != null) ok = r;
        print('[Notif] requestNotificationsPermission -> $r');
      } catch (_) {}

      // permission_handler (covers some OEM ROMs)
      try {
        final r = await Permission.notification.request();
        ok = ok && r.isGranted;
        print('[Notif] Permission.notification -> ${r.name}');
      } catch (_) {}

      // Exact alarms (Android 12+). On Android 14+ this may open settings.
      try {
        await impl?.requestExactAlarmsPermission();
        print('[Notif] requestExactAlarmsPermission done');
      } catch (_) {}
      try {
        final r = await Permission.scheduleExactAlarm.request();
        print('[Notif] scheduleExactAlarm -> ${r.name}');
      } catch (_) {}

      // Battery optimization — crucial for OEM ROMs that kill background apps
      try {
        final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
        print('[Notif] ignoreBatteryOptimizations status -> $batteryStatus');
        if (!batteryStatus.isGranted) {
          final r = await Permission.ignoreBatteryOptimizations.request();
          print('[Notif] ignoreBatteryOptimizations request -> ${r.name}');
        }
      } catch (_) {}

      return ok;
    }

    if (Platform.isIOS) {
      try {
        final iosImpl = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        return await iosImpl?.requestPermissions(
                alert: true, badge: true, sound: true) ??
            true;
      } catch (_) {
        return true;
      }
    }
    return true;
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Schedule (or reschedule) the three daily meal reminders.
  static Future<void> scheduleMealReminders({
    required bool enabled,
    String breakfastTime = '08:00',
    String lunchTime = '12:30',
    String dinnerTime = '19:00',
    bool showTest = false,
  }) async {
    if (!_initialized) await initialize();

    // Always ensure channel exists before scheduling
    await _ensureChannelExists();

    // Always cancel existing first
    await _plugin.cancel(idBreakfast);
    await _plugin.cancel(idLunch);
    await _plugin.cancel(idDinner);

    if (!enabled) {
      print('[Notif] Reminders DISABLED — all cancelled');
      return;
    }

    // Brief pause to let AlarmManager fully process cancellations.
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    final bmiCategory = prefs.getString('user_bmi_category') ?? 'Normal Weight';

    final b = _parseTime(breakfastTime, fallback: const _T(8, 0));
    final l = _parseTime(lunchTime, fallback: const _T(12, 30));
    final d = _parseTime(dinnerTime, fallback: const _T(19, 0));

    print('[Notif] Scheduling: B=${b.h}:${b.m}, L=${l.h}:${l.m}, D=${d.h}:${d.m} (tz=$_tzName)');

    await _scheduleNotification(
      id: idBreakfast,
      title: AppStrings.breakfastReminderTitle,
      body: NotificationMessageGenerator.generateMealReminder(
        time: MealTime.breakfast,
        bmiCategory: bmiCategory,
        dayOfYear: DateTime.now().dayOfYear,
      ),
      hour: b.h,
      minute: b.m,
    );
    await _scheduleNotification(
      id: idLunch,
      title: AppStrings.lunchReminderTitle,
      body: NotificationMessageGenerator.generateMealReminder(
        time: MealTime.lunch,
        bmiCategory: bmiCategory,
        dayOfYear: DateTime.now().dayOfYear,
      ),
      hour: l.h,
      minute: l.m,
    );
    await _scheduleNotification(
      id: idDinner,
      title: AppStrings.dinnerReminderTitle,
      body: NotificationMessageGenerator.generateMealReminder(
        time: MealTime.dinner,
        bmiCategory: bmiCategory,
        dayOfYear: DateTime.now().dayOfYear,
      ),
      hour: d.h,
      minute: d.m,
    );

    // Only show test notification if explicitly requested and not already shown
    if (showTest) {
      final hasShownInstallTest = prefs.getBool('install_test_shown') ?? false;
      if (!hasShownInstallTest) {
        await showInstallTestNotification();
        await prefs.setBool('install_test_shown', true);
      }
    }

    // Schedule meal logging reminders
    await scheduleMealLogReminders(
      breakfastTime: breakfastTime,
      lunchTime: lunchTime,
      dinnerTime: dinnerTime,
    );

    // Verify pending notifications for debug
    try {
      final pending = await _plugin.pendingNotificationRequests();
      print('[Notif] ${pending.length} notifications now pending');
    } catch (_) {}
  }

  /// Show ONE test notification on first install/enabled — confirms notifications work.
  static Future<void> showInstallTestNotification() async {
    if (!_initialized) await initialize();
    await _ensureChannelExists();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        autoCancel: true,
        showWhen: true,
        styleInformation: BigTextStyleInformation(
            'FoodIQ reminders are now active! You\'ll receive notifications at '
            'breakfast, lunch, and dinner times. If you haven\'t logged a meal, '
            'we\'ll gently remind you too!'),
        ticker: 'FoodIQ',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      idInstallTest,
      'FoodIQ Reminders Are ON',
      'You\'ll be notified at meal times. This is the only test notification!',
      details,
    );
    print('[Notif] Install test notification shown (one-time only)');
  }

  /// Schedule meal logging reminders — if user hasn't logged a meal by a
  /// certain time after the meal reminder, send a follow-up reminder.
  static Future<void> scheduleMealLogReminders({
    String breakfastTime = '08:00',
    String lunchTime = '12:30',
    String dinnerTime = '19:00',
  }) async {
    if (!_initialized) await initialize();

    // Cancel all potential meal log reminder IDs
    for (int i = 0; i < 24; i++) {
      await _plugin.cancel(idMealLogReminder + i);
    }

    final prefs = await SharedPreferences.getInstance();
    final bmiCategory = prefs.getString('user_bmi_category') ?? 'Normal Weight';

    final b = _parseTime(breakfastTime, fallback: const _T(8, 0));
    final l = _parseTime(lunchTime, fallback: const _T(12, 30));
    final d = _parseTime(dinnerTime, fallback: const _T(19, 0));

    await _scheduleMealLogCheck(
      hour: b.h == 8 ? 9 : b.h + 1, 
      minute: 30, 
      time: MealTime.breakfast, 
      bmiCategory: bmiCategory,
    ); 
    await _scheduleMealLogCheck(
      hour: l.h == 12 ? 14 : l.h + 1, 
      minute: 0, 
      time: MealTime.lunch, 
      bmiCategory: bmiCategory,
    ); 
    await _scheduleMealLogCheck(
      hour: d.h == 19 ? 20 : d.h + 1, 
      minute: 30, 
      time: MealTime.dinner, 
      bmiCategory: bmiCategory,
    ); 
    
    print('[Notif] Meal log reminder notifications scheduled');
  }

  /// Schedule a single meal log check notification
  static Future<void> _scheduleMealLogCheck({
    required int hour,
    required int minute,
    required MealTime time,
    required String bmiCategory,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: _reminderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        styleInformation: BigTextStyleInformation(
          NotificationMessageGenerator.generateLogReminder(
            time: time,
            bmiCategory: bmiCategory,
          ),
        ),
        autoCancel: true,
        showWhen: true,
        ticker: 'FoodIQ',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    String title;
    if (time == MealTime.breakfast) title = 'Breakfast Reminder';
    else if (time == MealTime.lunch) title = 'Lunch Reminder';
    else title = 'Dinner Reminder';

    try {
      final canExact = await canScheduleExactAlarms();
      await _plugin.zonedSchedule(
        idMealLogReminder + hour,
        title,
        NotificationMessageGenerator.generateLogReminder(time: time, bmiCategory: bmiCategory),
        scheduledDate,
        details,
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('[Notif] Meal log check schedule failed: $e');
    }
  }

  /// Convenience: re-schedule from SharedPreferences.
  /// Safe to call from anywhere — app start, lifecycle observer, etc.
  static Future<void> rescheduleFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('meal_reminders_enabled') ?? false;
      if (!enabled) {
        print('[Notif] rescheduleFromPrefs: reminders disabled, skipping');
        return;
      }

      if (!_initialized) await initialize();

      // Re-request permissions in case they were revoked
      await requestPermission();

      final breakfastTime =
          prefs.getString('reminder_breakfast_time') ?? '08:00';
      final lunchTime =
          prefs.getString('reminder_lunch_time') ?? '12:30';
      final dinnerTime =
          prefs.getString('reminder_dinner_time') ?? '19:00';

      await scheduleMealReminders(
        enabled: true,
        breakfastTime: breakfastTime,
        lunchTime: lunchTime,
        dinnerTime: dinnerTime,
      );
      print('[Notif] rescheduleFromPrefs done');
    } catch (e) {
      print('[Notif] rescheduleFromPrefs failed: $e');
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    print('[Notif] Scheduling id=$id "$title" at $scheduledDate (tz=$_tzName)');

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        styleInformation: BigTextStyleInformation(body),
        ticker: 'FoodIQ',
        autoCancel: false,
        showWhen: true,
        onlyAlertOnce: false,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Try exact alarm first; fall back to inexact if blocked (Android 12+).
    try {
      final canExact = await canScheduleExactAlarms();
      print('[Notif] canScheduleExactAlarms = $canExact');

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('[Notif] id=$id scheduled with ${canExact ? "EXACT" : "INEXACT"} alarm at $scheduledDate');
    } catch (e) {
      print('[Notif] primary schedule failed for id=$id: $e');
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        print('[Notif] id=$id scheduled with INEXACT alarm (fallback)');
      } catch (e2) {
        print('[Notif] INEXACT also failed for id=$id: $e2');
        // Last resort: try without matchDateTimeComponents (one-shot)
        try {
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            scheduledDate,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          print('[Notif] id=$id scheduled as ONE-SHOT (last resort)');
        } catch (e3) {
          print('[Notif] ALL scheduling methods failed for id=$id: $e3');
        }
      }
    }
  }

  /// Cancel a specific scheduled reminder.
  static Future<void> cancel(int id) async => _plugin.cancel(id);

  /// Cancel every scheduled FoodIQ notification.
  static Future<void> cancelAll() async => _plugin.cancelAll();

  /// Returns pending notification requests (debug aid).
  static Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  /// Get a diagnostic summary string for display in settings.
  static Future<String> getDiagnosticInfo() async {
    final notifEnabled = await areNotificationsEnabled();
    final exactAlarms = await canScheduleExactAlarms();
    final pendingNotifs = await pending();

    bool? batteryOptimized;
    try {
      batteryOptimized = await Permission.ignoreBatteryOptimizations.isGranted;
    } catch (_) {
      batteryOptimized = null;
    }

    return 'Timezone: $_tzName\n'
        'Notifications: ${notifEnabled ? "Enabled" : "Disabled"}\n'
        'Exact Alarms: ${exactAlarms ? "Allowed" : "Not allowed"}\n'
        'Battery Optimization: ${batteryOptimized == true ? "Exempt" : batteryOptimized == false ? "Not exempt" : "Unknown"}\n'
        'Channel: $_channelId\n'
        'Pending: ${pendingNotifs.length} notification(s)\n'
        'Current time: ${tz.TZDateTime.now(tz.local).toString().substring(0, 19)}';
  }

  static _T _parseTime(String s, {required _T fallback}) {
    try {
      final parts = s.split(':');
      final h = int.parse(parts[0]);
      final m = parts.length > 1 ? int.parse(parts[1]) : 0;
      return _T(h, m);
    } catch (_) {
      return fallback;
    }
  }
}

class _T {
  final int h;
  final int m;
  const _T(this.h, this.m);
}

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year);
    return difference(start).inDays + 1;
  }
}
