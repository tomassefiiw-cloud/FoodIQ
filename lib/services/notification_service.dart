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

  // Channel ID is bumped to _v2 because Android channel importance is
  // immutable after creation; the old v1.1 channel had wrong importance.
  static const String _channelId = 'foodiq_meal_reminder_v2';
  static const String _channelName = 'Meal Reminders';
  static const String _channelDescription =
      'Reminders for breakfast, lunch, and dinner.';

  static bool _initialized = false;
  static String _tzName = 'UTC';

  static const int idBreakfast = 1001;
  static const int idLunch = 1002;
  static const int idDinner = 1003;
  static const int idTest = 9999;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    await _setupTimezone();

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

    if (Platform.isAndroid) {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      // Delete old v1.1 channel; recreate with MAX importance
      try {
        await impl?.deleteNotificationChannel('foodiq_meal_reminder');
      } catch (_) {}
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
  }

  /// Strict OS timezone detection with multiple fallbacks.
  static Future<void> _setupTimezone() async {
    // 1) Plugin (IANA name from OS) — best
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      if (name.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(name));
        _tzName = name;
        return;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Notif] FlutterTimezone failed: $e');
    }

    // 2) Match OS offset to known IANA zone
    try {
      final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset ~/ (60 * 1000) == offsetMinutes) {
          tz.setLocalLocation(loc);
          _tzName = loc.name;
          return;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Notif] offset lookup failed: $e');
    }

    // 3) Etc/GMT±N (POSIX sign INVERTED: UTC+3 -> Etc/GMT-3)
    try {
      final hours = DateTime.now().timeZoneOffset.inHours;
      final etcName = hours == 0
          ? 'UTC'
          : 'Etc/GMT${hours > 0 ? '-' : '+'}${hours.abs()}';
      tz.setLocalLocation(tz.getLocation(etcName));
      _tzName = etcName;
      return;
    } catch (e) {
      // ignore: avoid_print
      print('[Notif] Etc/GMT fallback failed: $e');
    }

    tz.setLocalLocation(tz.getLocation('UTC'));
    _tzName = 'UTC';
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
      } catch (_) {}

      // permission_handler (covers some OEM ROMs)
      try {
        final r = await Permission.notification.request();
        ok = ok && r.isGranted;
      } catch (_) {}

      // Exact alarms (Android 12+). On Android 14+ this may open settings.
      try {
        await impl?.requestExactAlarmsPermission();
      } catch (_) {}
      try {
        await Permission.scheduleExactAlarm.request();
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
    await _plugin.cancel(idBreakfast);
    await _plugin.cancel(idLunch);
    await _plugin.cancel(idDinner);

    if (!enabled) return;

    final b = _parseTime(breakfastTime, fallback: const _T(8, 0));
    final l = _parseTime(lunchTime, fallback: const _T(12, 30));
    final d = _parseTime(dinnerTime, fallback: const _T(19, 0));

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
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
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

    // Try exact alarm first; fall back to inexact if blocked (Android 14+).
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Notif] exact alarm failed, falling back to inexact: $e');
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          _nextInstanceOfTime(hour, minute),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e2) {
        // ignore: avoid_print
        print('[Notif] inexact also failed: $e2');
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
            'lunch, and dinner — right on your status bar.'),
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
  }

  /// Cancel a specific scheduled reminder.
  static Future<void> cancel(int id) async => _plugin.cancel(id);

  /// Cancel every scheduled FoodIQ notification.
  static Future<void> cancelAll() async => _plugin.cancelAll();

  /// Returns pending notification requests (debug aid).
  static Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

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
