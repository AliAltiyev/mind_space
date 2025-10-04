import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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
    final status = await Permission.notification.request();
    return status.isGranted;
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
      "How's your mood today? Start your week with positive energy! 🌟",
      "Take a moment to check in with yourself today 💭",
      "Mid-week mood check! How are you feeling? 🤔",
      "Thursday vibes! What's your mood today? ✨",
      "TGIF! How was your mood this Friday? 🎉",
      "Weekend mood check! How are you feeling? 😌",
      "Sunday reflection time! How's your mood? 🌅",
    ];

    for (int dayOfWeek = 1; dayOfWeek <= 7; dayOfWeek++) {
      final scheduledDate = _getNextWeekday(now, dayOfWeek, reminderTime);
      
      await scheduleNotification(
        id: dayOfWeek,
        title: "Mind Space Reminder",
        body: messages[dayOfWeek - 1],
        scheduledDate: scheduledDate,
        payload: 'mood_reminder_$dayOfWeek',
      );
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
      title: "Weekly Reflection Time",
      body: "Take some time to reflect on your week and track your mood patterns 📊",
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
