// ignore_for_file: file_names

import 'package:hive/hive.dart';

part 'notificationModel.g.dart';

@HiveType(typeId: 9)
class NotificationModel extends HiveObject {
  @HiveField(0)
  bool isNotificationEnabled;

  @HiveField(1)
  bool isDaily;

  @HiveField(2)
  bool isWeekly;

  @HiveField(3)
  String reminderTime;

  NotificationModel({
    required this.isNotificationEnabled,
    required this.isDaily,
    required this.isWeekly,
    required this.reminderTime,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      isNotificationEnabled: json['isNotificationEnabled'],
      isDaily: json['isDaily'],
      isWeekly: json['isWeekly'],
      reminderTime: json['reminderTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isNotificationEnabled': isNotificationEnabled,
      'isDaily': isDaily,
      'isWeekly': isWeekly,
      'reminderTime': reminderTime,
    };
  }
}