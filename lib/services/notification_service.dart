import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'bookings_channel',
    'Booking Reminders',
    description: 'Reminders for upcoming appointments and bookings',
    importance: Importance.high,
  );

  static Future<void> ensureInitialized() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // Best-effort set local timezone; fallback to Asia/Karachi if unknown
    try {
      final guessed = tz.local; // if already set
      // touch to ensure not throwing
      // ignore: unused_local_variable
      final _ = guessed;
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
      } catch (_) {}
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    // Create Android channel
    final androidSpecific = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidSpecific?.createNotificationChannel(_channel);

    _initialized = true;
  }

  static Future<void> requestPermission() async {
    final androidSpecific = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidSpecific?.requestNotificationsPermission();
  }

  static Future<bool> _areOsNotificationsEnabled() async {
    final androidSpecific = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final enabled = await androidSpecific?.areNotificationsEnabled();
    return enabled ?? true;
  }

  static Future<bool> areOsNotificationsEnabled() =>
      _areOsNotificationsEnabled();

  // Note: Exact alarms require a special system permission (SCHEDULE_EXACT_ALARM)
  // that users must enable in system settings. We'll schedule using inexact mode
  // for broad device compatibility.

  static Future<bool> _notificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications') ?? true;
  }

  static NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      'bookings_channel',
      'Booking Reminders',
      channelDescription: 'Reminders for upcoming bookings',
      importance: Importance.high,
      priority: Priority.high,
    );
    return const NotificationDetails(android: android);
  }

  // Immediate notification for testing/sample purposes
  static Future<void> showNow({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!await _notificationsEnabled()) return;
    await ensureInitialized();
    if (!await _areOsNotificationsEnabled()) {
      return; // OS disabled
    }
    await _plugin.show(id, title, body, _details());
  }

  static Future<void> scheduleIn({
    required int seconds,
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!await _notificationsEnabled()) return;
    await ensureInitialized();
    if (!await _areOsNotificationsEnabled()) {
      return; // OS notifications disabled; can't schedule
    }
    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> scheduleAt({
    required DateTime dateTime,
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!await _notificationsEnabled()) return;
    await ensureInitialized();
    if (!await _areOsNotificationsEnabled()) {
      return;
    }
    final when = tz.TZDateTime.from(dateTime, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }
}

DateTime? parseWeeklySlotToNextDateTime(String slot) {
  // Expected formats like: 'Mon 10:00', 'Tue 14:30'
  try {
    final parts = slot.split(' ');
    if (parts.length != 2) return null;
    final dayStr = parts[0].toLowerCase();
    final timeStr = parts[1];

    final weekdayMap = {
      'mon': DateTime.monday,
      'tue': DateTime.tuesday,
      'wed': DateTime.wednesday,
      'thu': DateTime.thursday,
      'fri': DateTime.friday,
      'sat': DateTime.saturday,
      'sun': DateTime.sunday,
    };
    final wd = weekdayMap[dayStr.substring(0, 3)];
    if (wd == null) return null;

    final timeParts = timeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    // Advance to the correct weekday
    int daysAhead = (wd - target.weekday) % 7;
    if (daysAhead < 0) daysAhead += 7;
    target = target.add(Duration(days: daysAhead));
    // If today and time already passed, move to next week
    if (daysAhead == 0 && target.isBefore(now)) {
      target = target.add(const Duration(days: 7));
    }
    return target;
  } catch (_) {
    return null;
  }
}

DateTime? parseExplicitDateTimeLocal(String slot) {
  // Expected format: 'YYYY-MM-DD HH:MM'
  try {
    final dt = DateTime.parse(slot.replaceFirst(' ', 'T'));
    return dt;
  } catch (_) {
    return null;
  }
}
