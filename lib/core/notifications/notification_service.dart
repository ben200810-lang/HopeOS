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

  // Channel IDs
  static const _drinkChannelId = 'drink_reminder';
  static const _sleepChannelId = 'sleep_reminder';
  static const _reflectionChannelId = 'daily_reflection';
  static const _quickCaptureChannelId = 'quick_capture';
  static const _patternInsightChannelId = 'pattern_insight';
  static const _dailyCheckInChannelId = 'daily_checkin';

  // Notification IDs
  static const _drinkNotificationId = 1001;
  static const _sleepNotificationId = 1002;
  static const _reflectionNotificationId = 1003;
  static const _quickCaptureNotificationId = 1004;
  static const _patternInsightNotificationId = 1005;
  static const _dailyCheckInNotificationId = 1006;

  // Action IDs for lock screen quick capture
  static const actionNote = 'quick_note';
  static const actionDrink = 'quick_drink';
  static const actionMood = 'quick_mood';
  static const actionExpense = 'quick_expense';
  static const actionIncome = 'quick_income';

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationAction,
    );
    _initialized = true;
  }

  /// Callback for notification action taps.
  /// Set by the app to navigate to the correct capture modal.
  static void Function(String actionId)? onActionTapped;

  static void _onNotificationAction(NotificationResponse response) {
    final action = response.actionId;
    debugPrint('Notification action tapped: $action');
    if (action != null && action.isNotEmpty && onActionTapped != null) {
      onActionTapped!(action);
    } else if (response.payload == 'quick_capture' && onActionTapped != null) {
      onActionTapped!(actionNote);
    }
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

  // ── Persistent Lock Screen Notification ──

  Future<void> showQuickCaptureNotification({
    required bool enabled,
    String title = 'HopeOS Quick Capture',
    String body = 'Tap to log a note, drink, mood, or expense',
  }) async {
    await _plugin.cancel(_quickCaptureNotificationId);
    if (!enabled) return;

    await _plugin.show(
      _quickCaptureNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _quickCaptureChannelId,
          'Quick Capture',
          channelDescription: 'Persistent notification for quick logging',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          actions: const [
            AndroidNotificationAction(
              actionNote,
              '📝 Note',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              actionDrink,
              '💧 Drink',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              actionMood,
              '😊 Mood',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              actionExpense,
              '💸 Expense',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              actionIncome,
              '💰 Income',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      payload: 'quick_capture',
    );
  }

  Future<void> hideQuickCaptureNotification() async {
    await _plugin.cancel(_quickCaptureNotificationId);
  }

  // ── Scheduled Notifications ──

  Future<void> scheduleDrinkReminder({
    required bool enabled,
    String title = 'Stay hydrated!',
    String body = 'Time to drink some water.',
  }) async {
    await _plugin.cancel(_drinkNotificationId);
    if (!enabled) return;

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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily reflection: $e');
    }
  }

  // ── Daily Check-In Notification ──

  Future<void> scheduleDailyCheckIn({
    required bool enabled,
    int hour = 9,
    int minute = 0,
    String title = 'Good morning!',
    String body = 'How are you feeling today? Take a moment to check in.',
  }) async {
    await _plugin.cancel(_dailyCheckInNotificationId);
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
        _dailyCheckInNotificationId,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _dailyCheckInChannelId,
            'Daily Check-In',
            channelDescription: 'Daily morning check-in reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily check-in: $e');
    }
  }

  // ── Pattern Insight Notification ──

  Future<void> showPatternInsightNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      _patternInsightNotificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _patternInsightChannelId,
          'Pattern Insights',
          channelDescription: 'Notifications about detected patterns',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
