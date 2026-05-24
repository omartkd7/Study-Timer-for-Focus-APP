import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'regain_timer',
    'Timer Alerts',
    description: 'Notifies when a focus or break session completes',
    importance: Importance.high,
  );

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'regain_timer',
      'Timer Alerts',
      channelDescription: 'Notifies when a focus or break session completes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    ),
    iOS: DarwinNotificationDetails(sound: 'default'),
  );

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Schedules a notification to fire when the timer completes.
  // Call this on every start/resume, cancel on pause/reset/skip.
  static Future<void> scheduleComplete({
    required int delaySeconds,
    required String title,
    required String body,
  }) async {
    await _plugin.cancel(1);
    await _plugin.zonedSchedule(
      1,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds)),
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
