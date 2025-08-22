// ignore_for_file: file_names

class NotificationState {
  final bool isNotificationEnabled;
  final bool isDaily;
  final bool isWeekly;
  final bool isError;
  final String errorMessage;
  final String? reminderTime;

  NotificationState({
    required this.isNotificationEnabled,
    required this.isDaily,
    required this.isWeekly,
    required this.isError,
    required this.errorMessage,
    this.reminderTime,
  });

  NotificationState copyWith({
    bool? isNotificationEnabled,
    bool? isLoading,
    bool? isDaily,
    bool? isWeekly,
    bool? isError,
    String? errorMessage,
    String? reminderTime,
  }) {
    return NotificationState(
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      isDaily: isDaily ?? this.isDaily,
      isWeekly: isWeekly ?? this.isWeekly,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}