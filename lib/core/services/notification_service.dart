import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:easy_localization/easy_localization.dart';

/// Сервис для управления уведомлениями
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Инициализация сервиса уведомлений
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Инициализация timezone
    tz.initializeTimeZones();

    // Настройка плагина
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Запрос разрешений на уведомления
  Future<bool> requestPermissions() async {
    // Запрашиваем базовые разрешения на уведомления
    final notificationStatus = await Permission.notification.request();
    
    // На Android 12+ также запрашиваем разрешение на точные уведомления
    try {
      await _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('Error requesting exact alarms permission: $e');
    }
    
    return notificationStatus.isGranted;
  }

  /// Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Навигация к экрану добавления записи
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Показать мгновенное уведомление
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'mood_reminders',
      'Mood Reminders',
      channelDescription: 'Reminders to track your mood',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFB9E3A),
      ledColor: Color(0xFFFB9E3A),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Планирование уведомления на определенное время
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'mood_reminders',
      'Mood Reminders',
      channelDescription: 'Reminders to track your mood',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFB9E3A),
      ledColor: Color(0xFFFB9E3A),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Если точные уведомления не разрешены, используем менее точное время
      if (e.toString().contains('exact_alarms_not_permitted')) {
        debugPrint('Exact alarms not permitted, using approximate time');
        
        // Добавляем небольшую задержку для приблизительного времени
        final approximateDate = scheduledDate.add(const Duration(minutes: 5));
        
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(approximateDate, tz.local),
          notificationDetails,
          payload: payload,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        rethrow;
      }
    }
  }

  /// Отмена уведомления
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Отмена всех уведомлений
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Получение всех запланированных уведомлений
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Настройка ежедневных напоминаний о настроении
  Future<void> setupDailyMoodReminders({
    required bool enabled,
    required TimeOfDay reminderTime,
  }) async {
    try {
      if (!enabled) {
        // Отменить все уведомления настроения (ID 1-7 для дней недели)
        for (int i = 1; i <= 7; i++) {
          await cancelNotification(i);
        }
        return;
      }

      // Создать уведомления для каждого дня недели
      final now = DateTime.now();
      final messages = [
        "notifications.monday_message".tr(),
        "notifications.tuesday_message".tr(),
        "notifications.wednesday_message".tr(),
        "notifications.thursday_message".tr(),
        "notifications.friday_message".tr(),
        "notifications.saturday_message".tr(),
        "notifications.sunday_message".tr(),
      ];

      for (int dayOfWeek = 1; dayOfWeek <= 7; dayOfWeek++) {
        final scheduledDate = _getNextWeekday(now, dayOfWeek, reminderTime);
        
        await scheduleNotification(
          id: dayOfWeek,
          title: "notifications.daily_reminder_title".tr(),
          body: messages[dayOfWeek - 1],
          scheduledDate: scheduledDate,
          payload: 'mood_reminder_$dayOfWeek',
        );
      }
    } catch (e) {
      debugPrint('Error setting up daily mood reminders: $e');
      rethrow;
    }
  }

  /// Настройка еженедельных напоминаний о рефлексии
  Future<void> setupWeeklyReflectionReminders({
    required bool enabled,
    required TimeOfDay reminderTime,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
  }) async {
    if (!enabled) {
      await cancelNotification(10); // ID для еженедельных напоминаний
      return;
    }

    final now = DateTime.now();
    final scheduledDate = _getNextWeekday(now, dayOfWeek, reminderTime);

    await scheduleNotification(
      id: 10,
      title: "notifications.weekly_reflection_title".tr(),
      body: "notifications.weekly_reflection_body".tr(),
      scheduledDate: scheduledDate,
      payload: 'weekly_reflection',
    );
  }

  /// Получение следующего дня недели с указанным временем
  DateTime _getNextWeekday(DateTime now, int targetDayOfWeek, TimeOfDay time) {
    final today = now.weekday;
    int daysUntilTarget = (targetDayOfWeek - today) % 7;
    
    // Если сегодня тот же день недели, планируем на следующую неделю
    if (daysUntilTarget == 0) {
      daysUntilTarget = 7;
    }

    final targetDate = now.add(Duration(days: daysUntilTarget));
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      time.hour,
      time.minute,
    );
  }

  /// Настройка уведомлений о достижениях
  Future<void> showAchievementNotification({
    required String title,
    required String body,
    required String achievementId,
  }) async {
    await showInstantNotification(
      id: 100 + achievementId.hashCode % 1000, // Уникальный ID
      title: title,
      body: body,
      payload: 'achievement_$achievementId',
    );
  }

  /// Настройка уведомлений о трендах
  Future<void> showTrendNotification({
    required String title,
    required String body,
    required String trendType,
  }) async {
    await showInstantNotification(
      id: 200 + trendType.hashCode % 1000, // Уникальный ID
      title: title,
      body: body,
      payload: 'trend_$trendType',
    );
  }

  /// Проверка, включены ли уведомления
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Открытие настроек уведомлений
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }
}
