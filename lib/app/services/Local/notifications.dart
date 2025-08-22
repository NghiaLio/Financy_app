
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tr;
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> setLocation() async{
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }
  }

  // Initialize the notification plugin
  Future<void> initNotification() async {
    if (_initialized) return;

    //timezone
    tr.initializeTimeZones();
    await setLocation();

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
     // 🔥 xin quyền runtime trên Android 13+
    final status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted) {
      await Permission.notification.request();
    }

    _initialized = true;
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
    // create scheduled time
    final scheduledTime = tz.TZDateTime.from(
      _nextInstanceOfTime(hour, minute),
      tz.local,
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

  /// Tính giờ tiếp theo (nếu đã qua thì cộng thêm 1 ngày)
  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  //Cancel notification 
  Future<void> cancelNotification(int id) async {
    if (!_initialized) {
      await initNotification();
    }
    await notificationPlugin.cancel(id);
  }

  //cancel all notification
  Future<void> cancelAllNotifications() async {
    if (!_initialized) {
      await initNotification();
    }
    await notificationPlugin.cancelAll();
  }

  //call scheduleNotification
  Future<void> scheduleDailyNotifications({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await initNotification();
    }
    // Schedule notifications for 11am and 8pm
    await scheduleNotification(
      id: 1,
      title: title,
      body: body,
      hour: 11,
      minute: 0,
    );
    await scheduleNotification(
      id: 2,
      title: title,
      body: body, 
      hour: 22,
      minute: 10,
    );
  }
}
