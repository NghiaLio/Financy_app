// ignore_for_file: file_names

import 'package:financy_ui/features/notification/models/notificationModel.dart';
import 'package:hive/hive.dart';

abstract class NotificationRepo {
  Future<void> saveNotificationSettings(NotificationModel notificationModel);
  Future<NotificationModel> loadNotificationSettings();
}

class NotificationRepoImpl implements NotificationRepo {
  @override
  Future<void> saveNotificationSettings(NotificationModel notificationModel)async {
    final box = Hive.box<NotificationModel>('notificationSettings');
    box.put('notificationSettings', notificationModel);
  }

  @override
  Future<NotificationModel> loadNotificationSettings() async {
    final box = Hive.box<NotificationModel>('notificationSettings');
    return box.get('notificationSettings') ?? NotificationModel(isNotificationEnabled: false, isDaily: false, isWeekly: false, reminderTime: '8:00');
  }
}