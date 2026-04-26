import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _drinkChannelId = 'drink_reminder';
  static const _sleepChannelId = 'sleep_reminder';
  static const _reflectionChannelId = 'daily_reflection';

  static const _drinkNotificationId = 1001;
  static const _sleepNotificationId = 1002;
  static const _reflectionNotificationId = 1003;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleDrinkReminder({
    required bool enabled,
    String title = 'Stay hydrated!',
    String body = 'Time to drink some water.',
  }) async {
    await _plugin.cancel(_drinkNotificationId);
    if (!enabled) return;

    // Schedule every 2 hours between 8:00 and 22:00
    final now = tz.TZDateTime.now(tz.local);
    var nextReminder = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour + (2 - now.hour % 2),
    );
    if (nextReminder.isBefore(now)) {
      nextReminder = nextReminder.add(const Duration(hours: 2));
    }
    if (nextReminder.hour < 8 || nextReminder.hour > 22) {
      nextReminder = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        8,
      );
    }

    try {
      await _plugin.zonedSchedule(
        _drinkNotificationId,
        title,
        body,
        nextReminder,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _drinkChannelId,
            'Drink Reminders',
            channelDescription: 'Reminders to stay hydrated',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule drink reminder: $e');
    }
  }

  Future<void> scheduleSleepReminder({
    required bool enabled,
    int hour = 22,
    int minute = 0,
    String title = 'Time to wind down',
    String body = 'Start preparing for sleep.',
  }) async {
    await _plugin.cancel(_sleepNotificationId);
    if (!enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        _sleepNotificationId,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _sleepChannelId,
            'Sleep Reminders',
            channelDescription: 'Reminders to prepare for sleep',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule sleep reminder: $e');
    }
  }

  Future<void> scheduleDailyReflection({
    required bool enabled,
    int hour = 20,
    int minute = 0,
    String title = 'Daily Reflection',
    String body = 'Take a moment to review your day.',
  }) async {
    await _plugin.cancel(_reflectionNotificationId);
    if (!enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        _reflectionNotificationId,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _reflectionChannelId,
            'Daily Reflection',
            channelDescription: 'Daily reflection reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily reflection: $e');
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
