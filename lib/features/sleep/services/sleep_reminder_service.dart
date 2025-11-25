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

    // Создаем канал уведомлений для Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'sleep_reminders',
        'Sleep Reminders',
        description: 'Reminders to log your sleep',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(androidChannel);
      }
    }

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

    // Запрашиваем базовые разрешения на уведомления
    if (Platform.isAndroid) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        if (granted == null || granted == false) {
          debugPrint('❌ Базовое разрешение на уведомления не предоставлено');
          throw Exception('Notification permission not granted');
        }
      }
    } else if (Platform.isIOS) {
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted == null || granted == false) {
          debugPrint('❌ Разрешение на уведомления iOS не предоставлено');
          throw Exception('Notification permission not granted');
        }
      }
    }

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
      // Сначала отменяем старое напоминание, если оно есть
      await cancelSleepReminder();

      final scheduledTime = _nextInstanceOfTime(time);
      // Логируем в локальном времени для понятности
      final scheduledLocalForLog = DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
      debugPrint(
        '📅 Установка напоминания на (локальное время): ${_formatDateTime(scheduledLocalForLog)}',
      );
      debugPrint(
        '📅 Выбранное время: ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
      );

      // Проверяем, сколько времени до срабатывания
      final now = DateTime.now();
      final timeUntilNotification = scheduledTime.difference(
        tz.TZDateTime.from(now, tz.local),
      );
      final minutesUntil = timeUntilNotification.inMinutes;

      debugPrint('⏰ До срабатывания напоминания: $minutesUntil минут');

      // Устанавливаем ежедневное напоминание
      // Используем exactAllowWhileIdle только если есть разрешение
      try {
        // Всегда используем matchDateTimeComponents для ежедневных напоминаний
        // Это гарантирует, что напоминание будет срабатывать каждый день в выбранное время
        await _notifications.zonedSchedule(
          1001, // ID для напоминаний о сне
          'sleep.reminder.title'.tr(),
          'sleep.reminder.body'.tr(),
          scheduledTime,
          details,
          androidScheduleMode: hasPermission
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        debugPrint(
          '✅ Ежедневное напоминание установлено с matchDateTimeComponents',
        );

        final scheduledLocal = DateTime(
          scheduledTime.year,
          scheduledTime.month,
          scheduledTime.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );

        debugPrint(
          '✅ Ежедневное напоминание успешно установлено на ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        );
        debugPrint(
          '✅ Следующее срабатывание: ${_formatDateTime(scheduledLocal)}',
        );

        // Небольшая задержка перед проверкой, чтобы система успела обработать запрос
        await Future.delayed(const Duration(milliseconds: 500));

        // Проверяем, что напоминание действительно установлено
        final isScheduled = await isReminderScheduled();
        if (!isScheduled) {
          debugPrint(
            '⚠️ Предупреждение: напоминание не найдено в списке запланированных',
          );
          debugPrint(
            '⚠️ Возможно, требуется перезапуск приложения или проверка разрешений',
          );
        }
      } catch (scheduleError) {
        debugPrint('❌ Ошибка при вызове zonedSchedule: $scheduleError');
        rethrow;
      }
    } catch (e) {
      debugPrint('❌ Ошибка установки напоминания: $e');
      // Если не удалось установить с точным режимом, пробуем без него
      if (hasPermission) {
        try {
          debugPrint('🔄 Попытка установки с inexact режимом...');
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
          debugPrint('✅ Напоминание установлено с inexact режимом');
        } catch (e2) {
          debugPrint('❌ Ошибка установки напоминания (fallback): $e2');
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
    // Получаем локальное время устройства (правильное время)
    final deviceNow = DateTime.now();

    var scheduledDate = tz.TZDateTime(
      tz.local,
      deviceNow.year,
      deviceNow.month,
      deviceNow.day,
      time.hour,
      time.minute,
    );

    // Если выбранное время уже прошло сегодня (строго меньше), устанавливаем на завтра
    // Если время равно текущему или в будущем, оставляем на сегодня
    // Используем сравнение с точностью до минуты, чтобы избежать проблем с секундами
    // Используем время устройства для правильного сравнения
    final nowMinutes = deviceNow.hour * 60 + deviceNow.minute;
    final scheduledMinutes = time.hour * 60 + time.minute;

    debugPrint('⏰ Сравнение времени (локальное время устройства):');
    debugPrint(
      '   Текущее: ${deviceNow.hour.toString().padLeft(2, '0')}:${deviceNow.minute.toString().padLeft(2, '0')} ($nowMinutes минут)',
    );
    debugPrint(
      '   Выбранное: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ($scheduledMinutes минут)',
    );

    if (scheduledMinutes < nowMinutes) {
      // Время уже прошло сегодня, устанавливаем на завтра
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      debugPrint(
        '⏰ Выбранное время уже прошло сегодня, устанавливаем на завтра',
      );
    } else {
      debugPrint(
        '⏰ Выбранное время еще не наступило сегодня или равно текущему, устанавливаем на сегодня',
      );
    }

    // Вычисляем разницу в локальном времени устройства
    // Создаем DateTime из scheduledDate
    final scheduledLocal = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    // Вычисляем разницу между запланированным и текущим временем
    // Округляем deviceNow до минут для правильного сравнения
    final deviceNowRounded = DateTime(
      deviceNow.year,
      deviceNow.month,
      deviceNow.day,
      deviceNow.hour,
      deviceNow.minute,
    );

    final difference = scheduledLocal.difference(deviceNowRounded);
    final totalMinutes = difference.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    debugPrint(
      '⏰ Текущее локальное время устройства: ${_formatDateTime(deviceNow)}',
    );
    debugPrint(
      '⏰ Запланированное локальное время: ${_formatDateTime(scheduledLocal)}',
    );
    debugPrint('⏰ Разница: $hoursч $minutesм (${difference.inMinutes} минут)');
    debugPrint(
      '⏰ Выбранное время: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    );

    return scheduledDate;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Проверить, установлено ли напоминание
  Future<bool> isReminderScheduled() async {
    final pendingNotifications = await _notifications
        .pendingNotificationRequests();
    final isScheduled = pendingNotifications.any((n) => n.id == 1001);

    if (isScheduled) {
      final reminder = pendingNotifications.firstWhere((n) => n.id == 1001);
      debugPrint('✅ Напоминание найдено в списке запланированных');
      debugPrint('   ID: ${reminder.id}');
      debugPrint('   Заголовок: ${reminder.title}');
      debugPrint('   Тело: ${reminder.body}');

      // Пытаемся получить детали запланированного времени
      try {
        // Для Android можно получить scheduledDate через payload или другие методы
        debugPrint('   Payload: ${reminder.payload ?? "нет"}');
      } catch (e) {
        debugPrint('   Не удалось получить детали: $e');
      }
    } else {
      debugPrint('❌ Напоминание НЕ найдено в списке запланированных');
      debugPrint(
        '   Всего запланированных уведомлений: ${pendingNotifications.length}',
      );
      for (final n in pendingNotifications) {
        debugPrint('   - ID: ${n.id}, Title: ${n.title}');
      }
    }

    return isScheduled;
  }

  /// Тестовая функция: отправить немедленное уведомление (для тестирования)
  Future<void> scheduleTestReminder({int secondsFromNow = 5}) async {
    await initialize();

    // Проверяем разрешения на уведомления
    if (Platform.isAndroid) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        if (granted != true) {
          throw Exception('Notification permission not granted');
        }
      }
    } else if (Platform.isIOS) {
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted == null || granted == false) {
          throw Exception('Notification permission not granted');
        }
      }
    }

    const androidDetails = AndroidNotificationDetails(
      'sleep_reminders',
      'Sleep Reminders',
      channelDescription: 'Reminders to log your sleep',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
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
      // Для теста отправляем немедленное уведомление
      if (secondsFromNow <= 0) {
        // Немедленное уведомление
        await _notifications.show(
          1002,
          'sleep.reminder.test_title'.tr(),
          'sleep.reminder.test_body'.tr(),
          details,
        );
        debugPrint('✅ Тестовое уведомление отправлено немедленно');
      } else {
        // Запланированное уведомление через N секунд
        final scheduledTime = tz.TZDateTime.now(
          tz.local,
        ).add(Duration(seconds: secondsFromNow));

        await _notifications.zonedSchedule(
          1002,
          'sleep.reminder.test_title'.tr(),
          'sleep.reminder.test_body'.tr(),
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('✅ Тестовое напоминание установлено на $scheduledTime');
      }
    } catch (e) {
      debugPrint('❌ Ошибка отправки тестового уведомления: $e');
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
