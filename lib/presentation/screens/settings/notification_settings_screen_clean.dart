import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/notification_service.dart';

/// Экран настроек уведомлений - простой и понятный дизайн
class NotificationSettingsScreenClean extends ConsumerStatefulWidget {
  const NotificationSettingsScreenClean({super.key});

  @override
  ConsumerState<NotificationSettingsScreenClean> createState() => _NotificationSettingsScreenCleanState();
}

class _NotificationSettingsScreenCleanState extends ConsumerState<NotificationSettingsScreenClean> {
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
        const SnackBar(
          content: Text('Разрешения на уведомления не предоставлены'),
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
        title: const Text('Уведомления'),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ежедневные напоминания
          _SettingsSection(
            title: 'Ежедневные напоминания',
            children: [
              SwitchListTile(
                title: const Text('Включить напоминания'),
                subtitle: const Text('Ежедневные напоминания о записи настроения'),
                value: _dailyReminders,
                onChanged: (value) => _updateDailyReminders(value),
                activeColor: AppColors.primary,
              ),
              if (_dailyReminders) ...[
                const Divider(height: 1),
                ListTile(
                  title: const Text('Время напоминания'),
                  subtitle: Text(_formatTime(_dailyTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectTime(context, true),
                ),
                ListTile(
                  title: const Text('Тестовое уведомление'),
                  subtitle: const Text('Отправить тестовое уведомление'),
                  trailing: const Icon(Icons.send),
                  onTap: _sendTestNotification,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Еженедельные напоминания
          _SettingsSection(
            title: 'Еженедельные напоминания',
            children: [
              SwitchListTile(
                title: const Text('Включить еженедельные напоминания'),
                subtitle: const Text('Напоминания для рефлексии'),
                value: _weeklyReminders,
                onChanged: (value) => _updateWeeklyReminders(value),
                activeColor: AppColors.primary,
              ),
              if (_weeklyReminders) ...[
                const Divider(height: 1),
                ListTile(
                  title: const Text('День недели'),
                  subtitle: Text(_getDayName(_weeklyDay)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectDay(context),
                ),
                ListTile(
                  title: const Text('Время напоминания'),
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
            title: 'Дополнительные настройки',
            children: [
              ListTile(
                title: const Text('Разрешения'),
                subtitle: const Text('Управление разрешениями приложения'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openAppSettings,
              ),
              ListTile(
                title: const Text('Отменить все уведомления'),
                subtitle: const Text('Очистить все запланированные уведомления'),
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
            content: Text(enabled ? 'Ежедневные напоминания включены' : 'Ежедневные напоминания отключены'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
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
            content: Text(enabled ? 'Еженедельные напоминания включены' : 'Еженедельные напоминания отключены'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
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
      'Понедельник',
      'Вторник', 
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите день недели'),
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
        body: 'Это тестовое уведомление!',
        payload: 'test',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Тестовое уведомление отправлено'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
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
          const SnackBar(
            content: Text('Все уведомления отменены'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
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
    const days = [
      'Понедельник',
      'Вторник',
      'Среда', 
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return days[dayOfWeek - 1];
  }
}

/// Секция настроек
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

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
