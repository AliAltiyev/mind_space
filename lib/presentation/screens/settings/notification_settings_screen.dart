import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../widgets/core/amazing_background.dart' as amazing;
import '../../widgets/core/amazing_glass_surface.dart' as amazing;
import '../../../core/services/notification_service.dart';

/// Экран настроек уведомлений
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _dailyRemindersEnabled = false;
  bool _weeklyReflectionEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _weeklyReminderTime = const TimeOfDay(hour: 19, minute: 0);
  int _weeklyReminderDay = 7; // Sunday
  bool _achievementNotifications = true;
  bool _trendNotifications = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _notificationService.initialize();

    // Запрашиваем разрешения
    final hasPermissions = await _notificationService.requestPermissions();
    if (!hasPermissions && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('notifications.permission_denied'.tr()),
          backgroundColor: const Color(0xFFEA2F14),
        ),
      );
    }

    final pendingNotifications = await _notificationService
        .getPendingNotifications();

    setState(() {
      _dailyRemindersEnabled = pendingNotifications.any(
        (n) => n.id >= 1 && n.id <= 7,
      );
      _weeklyReflectionEnabled = pendingNotifications.any((n) => n.id == 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return amazing.AmazingBackground(
      type: amazing.BackgroundType.cosmic,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'settings.notifications'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 10)],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/settings');
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Mood Reminders
              amazing.AmazingGlassSurface(
                effectType: amazing.GlassEffectType.neon,
                colorScheme: amazing.ColorScheme.neon,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'notifications.daily_mood_reminders'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Color(0xFFFB9E3A), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: Text(
                        'notifications.enable_reminders'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'notifications.daily_reminders_desc'.tr(),
                        style: const TextStyle(color: Colors.white60),
                      ),
                      value: _dailyRemindersEnabled,
                      activeThumbColor: const Color(0xFFFB9E3A),
                      onChanged: (value) async {
                        setState(() {
                          _dailyRemindersEnabled = value;
                        });
                        await _updateDailyReminders();
                      },
                    ),

                    if (_dailyRemindersEnabled) ...[
                      ListTile(
                        leading: const Icon(
                          Icons.access_time,
                          color: Color(0xFFFB9E3A),
                        ),
                        title: Text(
                          'notifications.reminder_time'.tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _dailyReminderTime.format(context),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white60,
                        ),
                        onTap: _selectDailyReminderTime,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Weekly Reflection
              amazing.AmazingGlassSurface(
                effectType: amazing.GlassEffectType.cyber,
                colorScheme: amazing.ColorScheme.cyber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'notifications.weekly_reflection_reminders'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Color(0xFFFCEF91), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: Text(
                        'notifications.weekly_reflection_reminders'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'notifications.weekly_reflection_desc'.tr(),
                        style: const TextStyle(color: Colors.white60),
                      ),
                      value: _weeklyReflectionEnabled,
                      activeThumbColor: const Color(0xFFFB9E3A),
                      onChanged: (value) async {
                        setState(() {
                          _weeklyReflectionEnabled = value;
                        });
                        await _updateWeeklyReflection();
                      },
                    ),

                    if (_weeklyReflectionEnabled) ...[
                      ListTile(
                        leading: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFFFB9E3A),
                        ),
                        title: Text(
                          'notifications.reminder_day'.tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _getDayName(_weeklyReminderDay),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white60,
                        ),
                        onTap: _selectWeeklyReminderDay,
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.access_time,
                          color: Color(0xFFFB9E3A),
                        ),
                        title: Text(
                          'notifications.reminder_time'.tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _weeklyReminderTime.format(context),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white60,
                        ),
                        onTap: _selectWeeklyReminderTime,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Other Notifications
              amazing.AmazingGlassSurface(
                effectType: amazing.GlassEffectType.rainbow,
                colorScheme: amazing.ColorScheme.rainbow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'notifications.other_notifications'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Color(0xFFFB9E3A), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: Text(
                        'notifications.achievement_notifications'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'notifications.achievement_notifications_desc'.tr(),
                        style: const TextStyle(color: Colors.white60),
                      ),
                      value: _achievementNotifications,
                      activeThumbColor: const Color(0xFFFB9E3A),
                      onChanged: (value) {
                        setState(() {
                          _achievementNotifications = value;
                        });
                      },
                    ),

                    SwitchListTile(
                      title: Text(
                        'notifications.trend_notifications'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'notifications.trend_notifications_desc'.tr(),
                        style: const TextStyle(color: Colors.white60),
                      ),
                      value: _trendNotifications,
                      activeThumbColor: const Color(0xFFFB9E3A),
                      onChanged: (value) {
                        setState(() {
                          _trendNotifications = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Test Notification Button
              amazing.AmazingGlassSurface(
                effectType: amazing.GlassEffectType.cosmic,
                colorScheme: amazing.ColorScheme.cosmic,
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_active,
                    color: Color(0xFFFB9E3A),
                  ),
                  title: Text(
                    'notifications.test_notification'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'notifications.send_test_notification_desc'.tr(),
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white60,
                  ),
                  onTap: _sendTestNotification,
                ),
              ),

              const SizedBox(height: 20),

              // App Settings
              amazing.AmazingGlassSurface(
                effectType: amazing.GlassEffectType.neon,
                colorScheme: amazing.ColorScheme.neon,
                child: ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFFFB9E3A)),
                  title: Text(
                    'notifications.app_notification_settings'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'notifications.open_system_settings'.tr(),
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white60,
                  ),
                  onTap: () => _notificationService.openNotificationSettings(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateDailyReminders() async {
    try {
      await _notificationService.setupDailyMoodReminders(
        enabled: _dailyRemindersEnabled,
        reminderTime: _dailyReminderTime,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'notifications.error_daily_reminders'.tr()}: $e'),
            backgroundColor: const Color(0xFFEA2F14),
          ),
        );
      }
    }
  }

  Future<void> _updateWeeklyReflection() async {
    try {
      await _notificationService.setupWeeklyReflectionReminders(
        enabled: _weeklyReflectionEnabled,
        reminderTime: _weeklyReminderTime,
        dayOfWeek: _weeklyReminderDay,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'notifications.error_weekly_reminders'.tr()}: $e'),
            backgroundColor: const Color(0xFFEA2F14),
          ),
        );
      }
    }
  }

  Future<void> _selectDailyReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFB9E3A),
              onPrimary: Colors.white,
              surface: Color(0xFF121212),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _dailyReminderTime = time;
      });
      await _updateDailyReminders();
    }
  }

  Future<void> _selectWeeklyReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _weeklyReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFB9E3A),
              onPrimary: Colors.white,
              surface: Color(0xFF121212),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _weeklyReminderTime = time;
      });
      await _updateWeeklyReflection();
    }
  }

  void _selectWeeklyReminderDay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          'notifications.select_day'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            final day = index + 1;
            return RadioListTile<int>(
              title: Text(
                _getDayName(day),
                style: const TextStyle(color: Colors.white),
              ),
              value: day,
              groupValue: _weeklyReminderDay,
              activeColor: const Color(0xFFFB9E3A),
              onChanged: (value) {
                setState(() {
                  _weeklyReminderDay = value!;
                });
                Navigator.of(context).pop();
                _updateWeeklyReflection();
              },
            );
          }),
        ),
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'notifications.monday'.tr();
      case 2:
        return 'notifications.tuesday'.tr();
      case 3:
        return 'notifications.wednesday'.tr();
      case 4:
        return 'notifications.thursday'.tr();
      case 5:
        return 'notifications.friday'.tr();
      case 6:
        return 'notifications.saturday'.tr();
      case 7:
        return 'notifications.sunday'.tr();
      default:
        return 'notifications.unknown_day'.tr();
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.showInstantNotification(
      id: 999,
      title: 'notifications.test_notification_title'.tr(),
      body: 'notifications.test_notification_success'.tr(),
      payload: 'test_notification',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('notifications.test_notification_sent'.tr()),
          backgroundColor: const Color(0xFFFB9E3A),
        ),
      );
    }
  }
}
