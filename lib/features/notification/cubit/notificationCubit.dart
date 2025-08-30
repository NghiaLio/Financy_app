// ignore_for_file: file_names

import 'package:financy_ui/app/services/Local/notifications.dart';
import 'package:financy_ui/features/notification/models/notificationModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/features/notification/cubit/notificationState.dart';
import 'package:financy_ui/features/notification/repo/notificationRepo.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo _notificationRepo = NotificationRepoImpl();

  bool? _isEnableNotification;
  bool? _isDaily;
  bool? _isWeekly;
  String? _reminderTime;

  bool? get isEnableNotification => _isEnableNotification;
  bool? get isDaily => _isDaily;
  bool? get isWeekly => _isWeekly;
  String? get reminderTime => _reminderTime;

  NotificationCubit()
    : super(
        NotificationState(
          isNotificationEnabled: false,
          isDaily: false,
          isWeekly: false,
          isError: false,
          errorMessage: '',
        ),
      );

  Future<void> loadNotificationSettings() async {
    final notificationSettings =
        await _notificationRepo.loadNotificationSettings();
    _isEnableNotification = notificationSettings.isNotificationEnabled;
    _isDaily = notificationSettings.isDaily;
    _isWeekly = notificationSettings.isWeekly;
    _reminderTime = notificationSettings.reminderTime;
    emit(
      NotificationState(
        isNotificationEnabled: _isEnableNotification ?? false,
        isDaily: _isDaily ?? false,
        isWeekly: _isWeekly ?? false,
        isError: false,
        errorMessage: '',
        reminderTime: _reminderTime ?? '8:00',
      ),
    );
  }

  Future<void> toggleNotification(bool value) async {
    _isEnableNotification = value;
    await _notificationRepo.saveNotificationSettings(
      NotificationModel(
        isNotificationEnabled: _isEnableNotification ?? false,
        isDaily: _isDaily ?? false,
        isWeekly: _isWeekly ?? false,
        reminderTime: _reminderTime ?? '8:00',
      ),
    );
    if (_isEnableNotification == false) {
      await NotiService().cancelAllNotifications();
    }
    emit(state.copyWith(isNotificationEnabled: _isEnableNotification ?? false));
  }

  Future<void> toggleDailyReminder(bool value) async {
    _isDaily = value;
    await _notificationRepo.saveNotificationSettings(
      NotificationModel(
        isNotificationEnabled: _isEnableNotification ?? false,
        isDaily: _isDaily ?? false,
        isWeekly: _isWeekly ?? false,
        reminderTime: _reminderTime ?? '8:00',
      ),
    );
    emit(state.copyWith(isDaily: _isDaily ?? false));
  }

  Future<void> setReminderTime(String time) async {
    _reminderTime = time;
    await _notificationRepo.saveNotificationSettings(
      NotificationModel(
        isNotificationEnabled: _isEnableNotification ?? false,
        isDaily: _isDaily ?? false,
        isWeekly: _isWeekly ?? false,
        reminderTime: _reminderTime ?? '8:00',
      ),
    );
    
    emit(state.copyWith(reminderTime: _reminderTime ?? '8:00'));
  }

  Future<void> toggleWeeklyReminder(bool value) async {
    _isWeekly = value;
    await _notificationRepo.saveNotificationSettings(
      NotificationModel(
        isNotificationEnabled: _isEnableNotification ?? false,
        isDaily: _isDaily ?? false,
        isWeekly: _isWeekly ?? false,
        reminderTime: _reminderTime ?? '8:00',
      ),
    );
    emit(state.copyWith(isWeekly: _isWeekly ?? false));
  }

  Future<void> showNotification() async {
    await NotiService().showNotification(
      id: 1,
      title: 'Thông báo thử nghiệm',
      body: 'Đây là thông báo thử nghiệm',
    );
  }
}
