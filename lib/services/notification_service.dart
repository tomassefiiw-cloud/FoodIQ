import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/app_strings.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestExactAlarmsPermission() ?? false;
    }
    return true;
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> scheduleMealReminders({
    required bool enabled,
    String breakfastTime = '08:00',
    String lunchTime = '12:30',
    String dinnerTime = '19:00',
  }) async {
    await _plugin.cancelAll();
    
    if (!enabled) return;

    // Breakfast reminder
    final bParts = breakfastTime.split(':');
    await _scheduleNotification(
      id: 1,
      title: AppStrings.breakfastReminderTitle,
      body: NotificationMessages.getBreakfastMessage(DateTime.now().dayOfYear),
      hour: int.parse(bParts[0]),
      minute: int.parse(bParts[1]),
    );

    // Lunch reminder
    final lParts = lunchTime.split(':');
    await _scheduleNotification(
      id: 2,
      title: AppStrings.lunchReminderTitle,
      body: NotificationMessages.getLunchMessage(DateTime.now().dayOfYear),
      hour: int.parse(lParts[0]),
      minute: int.parse(lParts[1]),
    );

    // Dinner reminder
    final dParts = dinnerTime.split(':');
    await _scheduleNotification(
      id: 3,
      title: AppStrings.dinnerReminderTitle,
      body: NotificationMessages.getDinnerMessage(DateTime.now().dayOfYear),
      hour: int.parse(dParts[0]),
      minute: int.parse(dParts[1]),
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
      'foodiq_meal_reminder',
      'Meal Reminders',
      channelDescription: 'Reminders for breakfast, lunch, and dinner',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );
    
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'foodiq_meal_reminder',
      'Meal Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    
    await _plugin.show(
      0,
      '🍽️ FoodIQ Reminder Set!',
      'Your meal reminders are now active. Stay on track with your nutrition goals!',
      details,
    );
  }
}

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year);
    return difference(start).inDays + 1;
  }
}
