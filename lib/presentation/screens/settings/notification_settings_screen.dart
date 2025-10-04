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
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
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
    if (!hasPermissions) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permissions are required for reminders'),
            backgroundColor: Color(0xFFEA2F14),
          ),
        );
      }
    }
    
    final pendingNotifications = await _notificationService.getPendingNotifications();
    
    setState(() {
      _dailyRemindersEnabled = pendingNotifications.any((n) => n.id >= 1 && n.id <= 7);
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
                      'Daily Mood Reminders',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text(
                        'Enable Daily Reminders',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Get reminded to track your mood every day',
                        style: TextStyle(color: Colors.white60),
                      ),
                      value: _dailyRemindersEnabled,
                      activeColor: const Color(0xFFFB9E3A),
                      onChanged: (value) async {
                        setState(() {
                          _dailyRemindersEnabled = value;
                        });
                        await _updateDailyReminders();
                      },
                    ),
                    
                    if (_dailyRemindersEnabled) ...[
                      ListTile(
                        leading: const Icon(Icons.access_time, color: Color(0xFFFB9E3A)),
                        title: const Text(
                          'Reminder Time',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _dailyReminderTime.format(context),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white60),
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
                      'Weekly Reflection',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Color(0xFFFCEF91), blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text(
                        'Enable Weekly Reflection',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Get reminded to reflect on your week',
                        style: TextStyle(color: Colors.white60),
                      ),
                      value: _weeklyReflectionEnabled,
                      activeColor: const Color(0xFFFB9E3A),
                      onChanged: (value) async {
                        setState(() {
                          _weeklyReflectionEnabled = value;
                        });
                        await _updateWeeklyReflection();
                      },
                    ),
                    
                    if (_weeklyReflectionEnabled) ...[
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Color(0xFFFB9E3A)),
                        title: const Text(
                          'Reminder Day',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _getDayName(_weeklyReminderDay),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white60),
                        onTap: _selectWeeklyReminderDay,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.access_time, color: Color(0xFFFB9E3A)),
                        title: const Text(
                          'Reminder Time',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _weeklyReminderTime.format(context),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white60),
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
                      'Other Notifications',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text(
                        'Achievement Notifications',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Get notified when you unlock achievements',
                        style: TextStyle(color: Colors.white60),
                      ),
                      value: _achievementNotifications,
                      activeColor: const Color(0xFFFB9E3A),
                      onChanged: (value) {
                        setState(() {
                          _achievementNotifications = value;
                        });
                      },
                    ),
                    
                    SwitchListTile(
                      title: const Text(
                        'Trend Notifications',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Get notified about mood trends and insights',
                        style: TextStyle(color: Colors.white60),
                      ),
                      value: _trendNotifications,
                      activeColor: const Color(0xFFFB9E3A),
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
                  leading: const Icon(Icons.notifications_active, color: Color(0xFFFB9E3A)),
                  title: const Text(
                    'Test Notification',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Send a test notification to verify settings',
                    style: TextStyle(color: Colors.white60),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white60),
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
                  title: const Text(
                    'App Notification Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Open system notification settings',
                    style: TextStyle(color: Colors.white60),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white60),
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
            content: Text('Error setting up daily reminders: $e'),
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
            content: Text('Error setting up weekly reminders: $e'),
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
        title: const Text(
          'Select Day',
          style: TextStyle(color: Colors.white),
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
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.showInstantNotification(
      id: 999,
      title: 'Test Notification',
      body: 'Your notification settings are working correctly! 🎉',
      payload: 'test_notification',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Color(0xFFFB9E3A),
        ),
      );
    }
  }
}

