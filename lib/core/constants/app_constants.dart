/// Константы приложения
class AppConstants {
  // Версия приложения
  static const String appVersion = '1.0.0';

  // Настройки базы данных
  static const String databaseName = 'mind_space.db';
  static const int databaseVersion = 1;

  // Настройки API
  static const String baseUrl = 'https://api.mindspace.app';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Настройки кеширования
  static const Duration cacheExpiration = Duration(hours: 24);

  // Настройки анимации
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Настройки UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Настройки шрифтов
  static const String primaryFontFamily = 'Inter';

  // Настройки локализации
  static const List<String> supportedLocales = ['en', 'ru'];
  static const String defaultLocale = 'en';

  // Настройки уведомлений
  static const String notificationChannelId = 'mood_reminders';
  static const String notificationChannelName = 'Mood Reminders';
  static const String notificationChannelDescription =
      'Reminders to track your mood';

  // Настройки аналитики
  static const String analyticsCollectionEnabled =
      'analytics_collection_enabled';
  static const String crashlyticsCollectionEnabled =
      'crashlytics_collection_enabled';

  // Приватный конструктор
  AppConstants._();
}
