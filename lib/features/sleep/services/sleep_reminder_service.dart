import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:easy_localization/easy_localization.dart';

/// Сервис для напоминаний о записи сна
class SleepReminderService {
  static final SleepReminderService _instance =
      SleepReminderService._internal();
  factory SleepReminderService() => _instance;
  SleepReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _alarmChannel = MethodChannel(
    'mindspace/alarm_permissions',
  );

  bool _isInitialized = false;

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Инициализация timezone
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  /// Запросить разрешение на точные уведомления (Android 12+)
  Future<bool> requestExactAlarmsPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      bool granted = false;
      if (androidImplementation != null) {
        granted =
            await androidImplementation.requestExactAlarmsPermission() ?? false;
      }

      if (!granted) {
        await openExactAlarmSettings();
      }
      return granted;
    } catch (e) {
      debugPrint('Ошибка запроса разрешения на точные уведомления: $e');
      await openExactAlarmSettings();
      return false;
    }
  }

  /// Установить напоминание о записи сна
  Future<bool> scheduleSleepReminder({
    required TimeOfDay time,
    bool enabled = true,
  }) async {
    if (!enabled) {
      await cancelSleepReminder();
      return true;
    }

    await initialize();

    // Запрашиваем разрешение на точные уведомления (Android 12+)
    final hasPermission = await requestExactAlarmsPermission();

    const androidDetails = AndroidNotificationDetails(
      'sleep_reminders',
      'Sleep Reminders',
      channelDescription: 'Reminders to log your sleep',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Устанавливаем ежедневное напоминание
      // Используем exactAllowWhileIdle только если есть разрешение
      await _notifications.zonedSchedule(
        1001, // ID для напоминаний о сне
        'sleep.reminder.title'.tr(),
        'sleep.reminder.body'.tr(),
        _nextInstanceOfTime(time),
        details,
        androidScheduleMode: hasPermission
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Ошибка установки напоминания: $e');
      // Если не удалось установить с точным режимом, пробуем без него
      if (hasPermission) {
        try {
          await _notifications.zonedSchedule(
            1001,
            'sleep.reminder.title'.tr(),
            'sleep.reminder.body'.tr(),
            _nextInstanceOfTime(time),
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        } catch (e2) {
          debugPrint('Ошибка установки напоминания (fallback): $e2');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    return hasPermission;
  }

  /// Отменить напоминание
  Future<void> cancelSleepReminder() async {
    await _notifications.cancel(1001);
  }

  /// Получить следующее время для напоминания
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Проверить, установлено ли напоминание
  Future<bool> isReminderScheduled() async {
    final pendingNotifications = await _notifications
        .pendingNotificationRequests();
    return pendingNotifications.any((n) => n.id == 1001);
  }

  /// Тестовая функция: установить напоминание через N секунд (для тестирования)
  Future<void> scheduleTestReminder({int secondsFromNow = 10}) async {
    await initialize();

    final hasPermission = await requestExactAlarmsPermission();

    const androidDetails = AndroidNotificationDetails(
      'sleep_reminders',
      'Sleep Reminders',
      channelDescription: 'Reminders to log your sleep',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(seconds: secondsFromNow));

    try {
      await _notifications.zonedSchedule(
        1002, // Другой ID для тестового напоминания
        'sleep.reminder.test_title'.tr(),
        'sleep.reminder.test_body'.tr(),
        scheduledTime,
        details,
        androidScheduleMode: hasPermission
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ Тестовое напоминание установлено на $scheduledTime');
    } catch (e) {
      debugPrint('❌ Ошибка установки тестового напоминания: $e');
      rethrow;
    }
  }

  /// Отменить тестовое напоминание
  Future<void> cancelTestReminder() async {
    await _notifications.cancel(1002);
  }

  Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _alarmChannel.invokeMethod('openExactAlarmSettings');
    } catch (e) {
      debugPrint('Не удалось открыть настройки точных будильников: $e');
    }
  }
}
