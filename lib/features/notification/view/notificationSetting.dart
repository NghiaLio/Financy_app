// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use

import 'dart:developer';

import 'package:financy_ui/app/services/Local/notifications.dart';
import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/features/notification/cubit/notificationCubit.dart';
import 'package:financy_ui/features/notification/cubit/notificationState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late bool _notificationEnabled;
  late bool _dailyReminder;
  late bool _weeklyReport;
  TimeOfDay? _reminderTime;

  @override
  void initState(){
    super.initState();
    context.read<NotificationCubit>().loadNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    

    TimeOfDay parseTimeOfDay(String timeString) {
      try {
        // Try parsing as full DateTime
        return TimeOfDay.fromDateTime(DateTime.parse(timeString));
      } catch (_) {
        // Try parsing as 'HH:mm'
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 8;
          final minute = int.tryParse(parts[1]) ?? 0;
          return TimeOfDay(hour: hour, minute: minute);
        }
        // Fallback
        return const TimeOfDay(hour: 8, minute: 0);
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.notificationSettings ?? 'Cài đặt Thông báo',
          style: textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.textGrey),
        ),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          log(state.reminderTime.toString());
          _notificationEnabled = state.isNotificationEnabled;
          _dailyReminder = state.isDaily;
          _weeklyReport = state.isWeekly;
          _reminderTime =
              state.reminderTime != null
                  ? parseTimeOfDay(state.reminderTime ?? '11:00')
                  : const TimeOfDay(hour: 8, minute: 0);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Thông báo chính
              _buildSettingCard(
                theme: theme,
                textTheme: textTheme,
                title: l10n?.generalNotifications ?? 'Thông báo tổng quát',
                children: [
                  _buildSwitchTile(
                    theme: theme,
                    textTheme: textTheme,
                    title: l10n?.enableNotifications ?? 'Bật thông báo',
                    subtitle:
                        l10n?.enableNotificationsDesc ??
                        'Nhận tất cả thông báo từ ứng dụng',
                    value: _notificationEnabled,
                    onChanged: (value) async {
                      context.read<NotificationCubit>().toggleNotification(
                        value,
                      );
                    },
                    icon: Icons.notifications,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Nhắc nhở và báo cáo
              _buildSettingCard(
                theme: theme,
                textTheme: textTheme,
                title: l10n?.reminders ?? 'Nhắc nhở',
                children: [
                  _buildSwitchTile(
                    theme: theme,
                    textTheme: textTheme,
                    title: l10n?.dailyReminder ?? 'Nhắc nhở hàng ngày',
                    subtitle:
                        l10n?.dailyReminderDesc ??
                        'Nhận thông báo nhắc nhở mỗi ngày',
                    value: _dailyReminder,
                    onChanged:
                        _notificationEnabled
                            ? (value) async {
                              context
                                  .read<NotificationCubit>()
                                  .toggleDailyReminder(value);
                              if (value == true) {
                                await NotiService().scheduleDailyNotifications(
                                  title: l10n?.titleNotification ?? 'Thông báo',
                                  body:
                                      l10n?.dailyReminderDesc ??
                                      'Hôm nay bạn đã chi tiêu bao nhiêu?',
                                );
                              } else {
                                await NotiService().cancelNotification(1);
                              }
                            }
                            : null,
                    icon: Icons.schedule,
                  ),
                  if (_dailyReminder) _buildTimeSelector(theme, textTheme),
                  _buildSwitchTile(
                    theme: theme,
                    textTheme: textTheme,
                    title: l10n?.weeklyReport ?? 'Báo cáo tuần',
                    subtitle:
                        l10n?.weeklyReportDesc ??
                        'Nhận báo cáo tổng kết hàng tuần',
                    value: _weeklyReport,
                    onChanged:
                        _notificationEnabled
                            ? (value) async {
                              context
                                  .read<NotificationCubit>()
                                  .toggleWeeklyReminder(value);

                              if (value == true) {
                                await NotiService().scheduleWeeklyNotifications(
                                  l10n?.weeklyReport ?? 'Báo cáo tuần',
                                  l10n?.weeklyReportDesc ??
                                      'Đây là thông báo báo cáo tuần',
                                  11,
                                  0,
                                );
                              } else {
                                await NotiService().cancelNotification(3);
                              }
                            }
                            : null,
                    icon: Icons.bar_chart,
                  ),
                ],
              ),

              // Nút test thông báo
              _buildTestButton(theme, textTheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingCard({
    required ThemeData theme,
    required TextTheme textTheme,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textGrey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required ThemeData theme,
    required TextTheme textTheme,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required IconData icon,
  }) {
    final isEnabled = onChanged != null;
    final iconColor = isEnabled ? AppColors.primaryBlue : AppColors.textGrey;
    final backgroundColor =
        isEnabled
            ? AppColors.primaryBlue.withOpacity(0.1)
            : AppColors.textGrey.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color:
                        isEnabled
                            ? theme.textTheme.bodyLarge?.color
                            : AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color:
                        isEnabled
                            ? AppColors.textGrey
                            : AppColors.textGrey.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(ThemeData theme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 40),
      child: InkWell(
        onTap:
            _notificationEnabled
                ? () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime:
                        _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
                    builder: (context, child) {
                      return Theme(
                        data: theme.copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primaryBlue,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    context.read<NotificationCubit>().setReminderTime(
                      picked.format(context),
                    );
                    await NotiService().scheduleDailyNotifications(
                      title:
                          AppLocalizations.of(context)?.titleNotification ??
                          'Thông báo',
                      body:
                          AppLocalizations.of(context)?.bodyNotification ??
                          'Hôm nay bạn đã chi tiêu bao nhiêu?',
                    );
                  }
                }
                : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textGrey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color:
                    _notificationEnabled
                        ? AppColors.primaryBlue
                        : AppColors.textGrey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Thời gian nhắc nhở: ${_reminderTime?.format(context) ?? '8:00'}',
                style: textTheme.bodyMedium?.copyWith(
                  color:
                      _notificationEnabled
                          ? theme.textTheme.bodyMedium?.color
                          : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(ThemeData theme, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            _notificationEnabled
                ? () {
                  NotiService().showNotification(
                    id: 1,
                    title: 'Thông báo thử nghiệm',
                    body: 'Đây là thông báo thử nghiệm',
                  );
                }
                : null,
        icon: const Icon(Icons.send),
        label: Text(
          AppLocalizations.of(context)?.testNotification ??
              'Gửi thông báo thử nghiệm',
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
