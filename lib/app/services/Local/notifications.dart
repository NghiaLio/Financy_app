import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/browser.dart';
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  // Initialize the notification plugin
  Future<void> initNotification() async {
    if (_initialized) return;

    //timezone
    initializeTimeZone();


    setLocalLocation(
      getLocation('Asia/Ho_Chi_Minh'),
    );

    // prepare android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // prepare ios settings
    const initSettingIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initSettingIOS,
    );

    await notificationPlugin.initialize(initSettings);
  }

  //Notification detail setup
  NotificationDetails _notificationDetails() {
    // Android notification details
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    // iOS notification details
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }
  // show notification

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await initNotification();
    }

    await notificationPlugin.show(id, title, body, _notificationDetails());
  }

  //on notify schedule
  /*
  schedule a notification at a sepcific time (e.g 11am and 8pm)
  - hour (0-23)
  - minute (0-59)
  */
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) {
      await initNotification();
    }
    // get current time
    final now = tz.TZDateTime.now(tz.local);

    // create scheduled time
    final scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // schedule notification
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  //Cancel notification 
  Future<void> cancelNotification(int id) async {
    if (!_initialized) {
      await initNotification();
    }
    await notificationPlugin.cancel(id);
  }
}
