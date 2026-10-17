import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'calorai_reminders';
  static const String _channelName = 'Meal & Water Reminders';
  static const String _channelDesc =
      'Daily reminders to log meals and drink water';

  static const int breakfastId = 1;
  static const int lunchId = 2;
  static const int dinnerId = 3;
  static const int waterBaseId = 10;
  static const List<int> waterHours = [8, 10, 12, 14, 16, 18, 20];

  static const String kBreakfast = 'notif_breakfast';
  static const String kLunch = 'notif_lunch';
  static const String kDinner = 'notif_dinner';
  static const String kWater = 'notif_water';

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {}

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // FIX 1: initialize() now requires named param 'settings:' in v20+
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  static Future<bool> requestPermissions() async {
    // FIX 2: DarwinFlutterLocalNotificationsPlugin does NOT exist in v22
    // The correct class is still IOSFlutterLocalNotificationsPlugin
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final granted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? false;
  }

  static Future<void> scheduleAllReminders() async {
    final prefs = await SharedPreferences.getInstance();

    final breakfast = prefs.getBool(kBreakfast) ?? true;
    final lunch = prefs.getBool(kLunch) ?? true;
    final dinner = prefs.getBool(kDinner) ?? true;
    final water = prefs.getBool(kWater) ?? true;

    if (breakfast) {
      await _scheduleDaily(
        id: breakfastId,
        title: '🍳 Breakfast Time',
        body: 'Time to log your breakfast and start the day right!',
        hour: 8,
        minute: 0,
      );
    } else {
      // FIX 3: cancel() now requires named param 'id:' in v20+
      await _plugin.cancel(id: breakfastId);
    }

    if (lunch) {
      await _scheduleDaily(
        id: lunchId,
        title: '🥗 Lunch Time',
        body: "Don't forget to log your lunch!",
        hour: 13,
        minute: 0,
      );
    } else {
      await _plugin.cancel(id: lunchId);
    }

    if (dinner) {
      await _scheduleDaily(
        id: dinnerId,
        title: '🍽 Dinner Time',
        body: 'Log your dinner to stay on track with your goals.',
        hour: 19,
        minute: 0,
      );
    } else {
      await _plugin.cancel(id: dinnerId);
    }

    for (int i = 0; i < waterHours.length; i++) {
      final notifId = waterBaseId + i;
      if (water) {
        await _scheduleDaily(
          id: notifId,
          title: '💧 Hydration Reminder',
          body: 'Time to drink some water and stay hydrated!',
          hour: waterHours[i],
          minute: 0,
        );
      } else {
        await _plugin.cancel(id: notifId);
      }
    }
  }

  static Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextDailyInstance(hour, minute),
      notificationDetails: NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextDailyInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
