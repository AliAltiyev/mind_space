import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/notification_service.dart';

/// Экран настроек уведомлений - простой и понятный дизайн
class NotificationSettingsScreenClean extends ConsumerStatefulWidget {
  const NotificationSettingsScreenClean({super.key});

  @override
  ConsumerState<NotificationSettingsScreenClean> createState() =>
      _NotificationSettingsScreenCleanState();
}

class _NotificationSettingsScreenCleanState
    extends ConsumerState<NotificationSettingsScreenClean> {
  final _notificationService = NotificationService();

  bool _dailyReminders = false;
  bool _weeklyReminders = false;
  TimeOfDay _dailyTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _weeklyTime = const TimeOfDay(hour: 19, minute: 0);
  int _weeklyDay = 7; // Воскресенье

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  /// Инициализация настроек
  Future<void> _initializeSettings() async {
    await _notificationService.initialize();
    final hasPermission = await _notificationService.requestPermissions();

    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('notifications.permission_denied'.tr()),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('notifications.title'.tr()),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ежедневные напоминания
          _SettingsSection(
            title: 'notifications.daily_reminders'.tr(),
            children: [
              SwitchListTile(
                title: Text('notifications.enable_reminders'.tr()),
                subtitle: Text('notifications.daily_mood_reminders'.tr()),
                value: _dailyReminders,
                onChanged: (value) => _updateDailyReminders(value),
                activeThumbColor: AppColors.primary,
              ),
              if (_dailyReminders) ...[
                const Divider(height: 1),
                ListTile(
                  title: Text('notifications.reminder_time'.tr()),
                  subtitle: Text(_formatTime(_dailyTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectTime(context, true),
                ),
                ListTile(
                  title: Text('notifications.test_notification'.tr()),
                  subtitle: Text('notifications.send_test_notification'.tr()),
                  trailing: const Icon(Icons.send),
                  onTap: _sendTestNotification,
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Еженедельные напоминания
          _SettingsSection(
            title: 'notifications.weekly_reminders'.tr(),
            children: [
              SwitchListTile(
                title: Text('notifications.enable_weekly_reminders'.tr()),
                subtitle: Text(
                  'notifications.weekly_reflection_reminders'.tr(),
                ),
                value: _weeklyReminders,
                onChanged: (value) => _updateWeeklyReminders(value),
                activeThumbColor: AppColors.primary,
              ),
              if (_weeklyReminders) ...[
                const Divider(height: 1),
                ListTile(
                  title: Text('notifications.day_of_week'.tr()),
                  subtitle: Text(_getDayName(_weeklyDay)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectDay(context),
                ),
                ListTile(
                  title: Text('notifications.reminder_time'.tr()),
                  subtitle: Text(_formatTime(_weeklyTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectTime(context, false),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Дополнительные настройки
          _SettingsSection(
            title: 'notifications.additional_settings'.tr(),
            children: [
              ListTile(
                title: Text('notifications.permissions'.tr()),
                subtitle: Text('notifications.manage_permissions'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openAppSettings,
              ),
              ListTile(
                title: Text('notifications.cancel_all_notifications'.tr()),
                subtitle: Text(
                  'notifications.clear_scheduled_notifications'.tr(),
                ),
                trailing: const Icon(Icons.clear_all),
                onTap: _cancelAllNotifications,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Обновление ежедневных напоминаний
  Future<void> _updateDailyReminders(bool enabled) async {
    setState(() => _dailyReminders = enabled);

    try {
      await _notificationService.setupDailyMoodReminders(
        enabled: enabled,
        reminderTime: _dailyTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'notifications.daily_reminders_enabled'.tr()
                  : 'notifications.daily_reminders_disabled'.tr(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.unknown_error'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Обновление еженедельных напоминаний
  Future<void> _updateWeeklyReminders(bool enabled) async {
    setState(() => _weeklyReminders = enabled);

    try {
      await _notificationService.setupWeeklyReflectionReminders(
        enabled: enabled,
        reminderTime: _weeklyTime,
        dayOfWeek: _weeklyDay,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'notifications.weekly_reminders_enabled'.tr()
                  : 'notifications.weekly_reminders_disabled'.tr(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.unknown_error'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Выбор времени
  Future<void> _selectTime(BuildContext context, bool isDaily) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: isDaily ? _dailyTime : _weeklyTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (isDaily) {
          _dailyTime = selectedTime;
        } else {
          _weeklyTime = selectedTime;
        }
      });

      // Обновляем настройки уведомлений
      if (isDaily && _dailyReminders) {
        await _updateDailyReminders(true);
      } else if (!isDaily && _weeklyReminders) {
        await _updateWeeklyReminders(true);
      }
    }
  }

  /// Выбор дня недели
  Future<void> _selectDay(BuildContext context) async {
    final days = [
      'notifications.monday'.tr(),
      'notifications.tuesday'.tr(),
      'notifications.wednesday'.tr(),
      'notifications.thursday'.tr(),
      'notifications.friday'.tr(),
      'notifications.saturday'.tr(),
      'notifications.sunday'.tr(),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('notifications.select_day'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            return RadioListTile<int>(
              title: Text(days[index]),
              value: index + 1,
              groupValue: _weeklyDay,
              onChanged: (value) {
                setState(() => _weeklyDay = value!);
                Navigator.of(context).pop();
                if (_weeklyReminders) {
                  _updateWeeklyReminders(true);
                }
              },
            );
          }),
        ),
      ),
    );
  }

  /// Отправка тестового уведомления
  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.showInstantNotification(
        id: 999,
        title: 'Mind Space',
        body: 'notifications.test_notification_body'.tr(),
        payload: 'test',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('notifications.test_notification_sent'.tr()),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.unknown_error'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Открытие настроек приложения
  Future<void> _openAppSettings() async {
    await _notificationService.openNotificationSettings();
  }

  /// Отмена всех уведомлений
  Future<void> _cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('notifications.all_notifications_cancelled'.tr()),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.unknown_error'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Форматирование времени
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Получение названия дня недели
  String _getDayName(int dayOfWeek) {
    final days = [
      'notifications.monday'.tr(),
      'notifications.tuesday'.tr(),
      'notifications.wednesday'.tr(),
      'notifications.thursday'.tr(),
      'notifications.friday'.tr(),
      'notifications.saturday'.tr(),
      'notifications.sunday'.tr(),
    ];
    return days[dayOfWeek - 1];
  }
}

/// Секция настроек
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
