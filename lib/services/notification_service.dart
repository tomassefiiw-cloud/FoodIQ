import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_strings.dart';

/// FoodIQ Notification Service.
///
/// Delivers REAL OS push notifications (Android system tray, navigation bar):
///   • Auto-detects device timezone (adaptive)
///   • Requests POST_NOTIFICATIONS permission (Android 13+)
///   • Requests SCHEDULE_EXACT_ALARM permission (Android 12+)
///   • Uses a high-importance notification channel so notifications show on
///     the lock screen + status bar.
///   • Daily-repeating reminders for breakfast, lunch, dinner.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'foodiq_meal_reminder';
  static const String _channelName = 'Meal Reminders';
  static const String _channelDescription =
      'FoodIQ reminders for breakfast, lunch, and dinner';

  static bool _initialized = false;
  static String _tzName = 'UTC';

  // Notification IDs (stable per meal)
  static const int idBreakfast = 1001;
  static const int idLunch = 1002;
  static const int idDinner = 1003;

  /// Initialize the plugin, timezone database, and notification channel.
  /// Safe to call multiple times.
  static Future<void> initialize() async {
    if (_initialized) return;

    // 1) Timezone setup (adaptive to device)
    tz_data.initializeTimeZones();
    try {
      _tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(_tzName));
    } catch (_) {
      try {
        // Offset-based fallback
        final offset = DateTime.now().timeZoneOffset;
        final hours = offset.inHours;
        // For UTC+3 (Addis Ababa) -> Etc/GMT-3 (note the inverted sign)
        final fallbackName =
            'Etc/GMT${hours <= 0 ? '+' : '-'}${hours.abs()}';
        _tzName = fallbackName;
        tz.setLocalLocation(tz.getLocation(fallbackName));
      } catch (_) {
        _tzName = 'UTC';
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    // 2) Plugin init
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    // 3) Create high-importance Android channel so notifications actually
    //    pop in the system tray + nav bar.
    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
    }

    _initialized = true;
  }

  static String get timezoneName => _tzName;

  /// Request all needed permissions. Returns true if notifications are allowed.
  static Future<bool> requestPermission() async {
    if (!_initialized) await initialize();

    bool granted = true;

    if (Platform.isAndroid) {
      // Android 13+ runtime POST_NOTIFICATIONS permission
      final notif = await Permission.notification.request();
      granted = notif.isGranted;

      // Best-effort exact-alarm permission (Android 12+)
      try {
        await Permission.scheduleExactAlarm.request();
      } catch (_) {}

      // Also explicitly ask the plugin (covers some OEM ROMs)
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      try {
        final plug = await androidImpl?.requestNotificationsPermission();
        if (plug != null) granted = granted && plug;
        await androidImpl?.requestExactAlarmsPermission();
      } catch (_) {}
    }

    if (Platform.isIOS) {
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final ok = await iosImpl?.requestPermissions(
        alert: true, badge: true, sound: true);
      granted = ok ?? true;
    }

    return granted;
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Schedule (or re-schedule) the three daily meal reminders.
  /// Pass `enabled=false` to cancel them all.
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

    final breakfast = _parseTime(breakfastTime, fallback: const _T(8, 0));
    final lunch = _parseTime(lunchTime, fallback: const _T(12, 30));
    final dinner = _parseTime(dinnerTime, fallback: const _T(19, 0));

    await _scheduleNotification(
      id: idBreakfast,
      title: AppStrings.breakfastReminderTitle,
      body: NotificationMessages.getBreakfastMessage(DateTime.now().dayOfYear),
      hour: breakfast.h,
      minute: breakfast.m,
    );

    await _scheduleNotification(
      id: idLunch,
      title: AppStrings.lunchReminderTitle,
      body: NotificationMessages.getLunchMessage(DateTime.now().dayOfYear),
      hour: lunch.h,
      minute: lunch.m,
    );

    await _scheduleNotification(
      id: idDinner,
      title: AppStrings.dinnerReminderTitle,
      body: NotificationMessages.getDinnerMessage(DateTime.now().dayOfYear),
      hour: dinner.h,
      minute: dinner.m,
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Try exact alarm first; fall back to inexact if exact-alarm permission
    // is missing (some Android 14+ devices restrict it).
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
    } catch (_) {
      // Fallback: inexact scheduling (still daily-repeating).
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
    }
  }

  /// Show an immediate "test" notification so the user can confirm setup.
  static Future<void> showTestNotification() async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      styleInformation: BigTextStyleInformation(''),
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      9999,
      '🍽️ FoodIQ is on duty!',
      'Reminders armed. We\'ll nudge you at breakfast, lunch, and dinner — '
          'right on your status bar.',
      details,
    );
  }

  /// Cancel a specific scheduled reminder.
  static Future<void> cancel(int id) async => _plugin.cancel(id);

  /// Cancel every reminder.
  static Future<void> cancelAll() async => _plugin.cancelAll();

  /// Returns the list of pending notification requests (debug aid).
  static Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
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
