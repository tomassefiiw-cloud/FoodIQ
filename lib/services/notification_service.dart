import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_strings.dart';

/// FoodIQ Notification Service — real OS push notifications.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel ID bumped to _v4 — we need a fresh channel to guarantee
  // MAX importance on every install (Android channel config is immutable
  // after creation; old channels might retain lower importance on some
  // OEMs even after deletion).
  static const String _channelId = 'foodiq_meal_reminder_v4';
  static const String _channelName = 'Meal Reminders';
  static const String _channelDescription =
      'Reminders for breakfast, lunch, and dinner.';

  static bool _initialized = false;
  static String _tzName = 'UTC';

  static const int idBreakfast = 1001;
  static const int idLunch = 1002;
  static const int idDinner = 1003;
  static const int idTest = 9999;
  static const int idConfirm = 9998; // for "reminder set" confirmation
  static const int idQuickTest = 9997; // for quick 15-sec test

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
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      // Delete ALL old channels that might have wrong importance
      for (final old in [
        'foodiq_meal_reminder',
        'foodiq_meal_reminder_v2',
        'foodiq_meal_reminder_v3',
      ]) {
        try {
          await impl?.deleteNotificationChannel(old);
        } catch (_) {}
      }
      // Create the v4 channel with MAX importance
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
    }

    _initialized = true;
    print('[Notif] ✅ Initialized — tz=$_tzName');
  }

  /// Strict OS timezone detection with multiple fallbacks.
  static Future<void> _setupTimezone() async {
    // 1) Plugin (IANA name from OS) — best
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      if (name.isNotEmpty) {
        // Try to resolve the name to a valid location
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

    // 4) Etc/GMT±N (POSIX sign INVERTED: UTC+3 -> Etc/GMT-3)
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
  /// Africa/Nairobi is UTC+3, which is the most common in East Africa.
  static List<String> _guessAfricanTimezone(int offsetMinutes) {
    // Map of offset minutes to likely African timezone names
    final map = <int, List<String>>{
      -60: ['Africa/Lagos', 'Africa/Algiers', 'Africa/Tunis'],   // UTC+1
      -120: ['Africa/Cairo', 'Africa/Johannesburg', 'Africa/Maputo'], // UTC+2
      -180: ['Africa/Nairobi', 'Africa/Addis_Ababa', 'Africa/Kampala', 'Africa/Dar_es_Salaam'], // UTC+3
      -240: ['Africa/Mogadishu'], // UTC+4
      0: ['Africa/Casablanca', 'Africa/Accra', 'Africa/Monrovia'], // UTC+0
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
        print('[Notif] requestNotificationsPermission → $r');
      } catch (_) {}

      // permission_handler (covers some OEM ROMs)
      try {
        final r = await Permission.notification.request();
        ok = ok && r.isGranted;
        print('[Notif] Permission.notification → ${r.name}');
      } catch (_) {}

      // Exact alarms (Android 12+). On Android 14+ this may open settings.
      try {
        await impl?.requestExactAlarmsPermission();
        print('[Notif] requestExactAlarmsPermission done');
      } catch (_) {}
      try {
        final r = await Permission.scheduleExactAlarm.request();
        print('[Notif] scheduleExactAlarm → ${r.name}');
      } catch (_) {}

      // Battery optimization — crucial for OEM ROMs that kill background apps
      try {
        final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
        print('[Notif] ignoreBatteryOptimizations status → $batteryStatus');
        if (!batteryStatus.isGranted) {
          final r = await Permission.ignoreBatteryOptimizations.request();
          print('[Notif] ignoreBatteryOptimizations request → ${r.name}');
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
  }) async {
    if (!_initialized) await initialize();

    // Always cancel existing first
    await _plugin.cancel(idBreakfast);
    await _plugin.cancel(idLunch);
    await _plugin.cancel(idDinner);

    if (!enabled) {
      print('[Notif] 🔕 Reminders DISABLED — all cancelled');
      return;
    }

    final b = _parseTime(breakfastTime, fallback: const _T(8, 0));
    final l = _parseTime(lunchTime, fallback: const _T(12, 30));
    final d = _parseTime(dinnerTime, fallback: const _T(19, 0));

    print('[Notif] 📅 Scheduling: B=${b.h}:${b.m}, L=${l.h}:${l.m}, D=${d.h}:${d.m} (tz=$_tzName)');
    print('[Notif] Current time: ${tz.TZDateTime.now(tz.local)}');

    await _scheduleNotification(
      id: idBreakfast,
      title: AppStrings.breakfastReminderTitle,
      body:
          NotificationMessages.getBreakfastMessage(DateTime.now().dayOfYear),
      hour: b.h,
      minute: b.m,
    );
    await _scheduleNotification(
      id: idLunch,
      title: AppStrings.lunchReminderTitle,
      body: NotificationMessages.getLunchMessage(DateTime.now().dayOfYear),
      hour: l.h,
      minute: l.m,
    );
    await _scheduleNotification(
      id: idDinner,
      title: AppStrings.dinnerReminderTitle,
      body: NotificationMessages.getDinnerMessage(DateTime.now().dayOfYear),
      hour: d.h,
      minute: d.m,
    );

    // Show a confirmation notification so the user knows it's working
    await _showReminderConfirmation(breakfastTime, lunchTime, dinnerTime);

    // Also verify pending notifications for debug
    try {
      final pending = await _plugin.pendingNotificationRequests();
      print('[Notif] ✅ ${pending.length} notifications now pending');
      for (final p in pending) {
        print('[Notif]   id=${p.id} title="${p.title}" body="${p.body?.substring(0, (p.body?.length ?? 20).clamp(0, 40))}..."');
      }
    } catch (_) {}
  }

  /// Show a confirmation notification: "Reminders set for 08:00 / 12:30 / 19:00"
  static Future<void> _showReminderConfirmation(
    String breakfastTime,
    String lunchTime,
    String dinnerTime,
  ) async {
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
        styleInformation: BigTextStyleInformation(
          'Breakfast: $breakfastTime\n'
          'Lunch: $lunchTime\n'
          'Dinner: $dinnerTime\n\n'
          'Reminders will appear at these times every day.\n'
          'Timezone: $_tzName',
        ),
        ticker: 'FoodIQ Reminders Set',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      idConfirm,
      '🍽️ FoodIQ Reminders Are ON',
      'Breakfast $breakfastTime • Lunch $lunchTime • Dinner $dinnerTime',
      details,
    );
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
      print('[Notif] ✅ id=$id scheduled with ${canExact ? "EXACT" : "INEXACT"} alarm at $scheduledDate');
    } catch (e) {
      print('[Notif] ⚠️ primary schedule failed for id=$id: $e');
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
        print('[Notif] ✅ id=$id scheduled with INEXACT alarm (fallback)');
      } catch (e2) {
        print('[Notif] ❌ INEXACT also failed for id=$id: $e2');
      }
    }
  }

  /// Immediate test notification — proves the channel + perms work.
  static Future<void> showTestNotification() async {
    if (!_initialized) await initialize();
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
        styleInformation: BigTextStyleInformation(
            'Reminders are armed. We\'ll nudge you at breakfast, '
            'lunch, and dinner — right on your status bar.\n'
            'Timezone: $_tzName'),
        ticker: 'FoodIQ',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      idTest,
      '🍽️ FoodIQ reminders are ON',
      'You\'ll get push notifications at breakfast, lunch, and dinner — '
          'they\'ll appear on your status bar.',
      details,
    );
    print('[Notif] ✅ Test notification shown');
  }

  /// Schedule a quick test notification that fires after [delaySeconds].
  /// This lets the user verify scheduled notifications work without waiting
  /// until the actual meal time.
  static Future<void> scheduleQuickTestNotification({
    int delaySeconds = 15,
  }) async {
    if (!_initialized) await initialize();

    // Cancel any previous quick test
    await _plugin.cancel(idQuickTest);

    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      Duration(seconds: delaySeconds),
    );

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
        ticker: 'FoodIQ Test',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      final canExact = await canScheduleExactAlarms();
      await _plugin.zonedSchedule(
        idQuickTest,
        '🍽️ FoodIQ Test Reminder',
        'If you see this, scheduled notifications are working! '
            'Your meal reminders will fire at the times you set.',
        scheduledDate,
        details,
        androidScheduleMode: canExact 
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('[Notif] ✅ Quick test scheduled in ${delaySeconds}s (tz=$_tzName, exact=$canExact)');
    } catch (e) {
      print('[Notif] ⚠️ Quick test exact failed: $e');
      try {
        await _plugin.zonedSchedule(
          idQuickTest,
          '🍽️ FoodIQ Test Reminder',
          'If you see this, scheduled notifications are working! '
              'Your meal reminders will fire at the times you set.',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print('[Notif] ✅ Quick test scheduled (inexact fallback) in ${delaySeconds}s');
      } catch (e2) {
        print('[Notif] ❌ Quick test failed entirely: $e2');
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
        'Notifications: ${notifEnabled ? "✅ Enabled" : "❌ Disabled"}\n'
        'Exact Alarms: ${exactAlarms ? "✅ Allowed" : "⚠️ Not allowed"}\n'
        'Battery Optimization: ${batteryOptimized == true ? "✅ Exempt" : batteryOptimized == false ? "⚠️ Not exempt" : "❓ Unknown"}\n'
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
