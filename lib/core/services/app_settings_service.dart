import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления настройками приложения
class AppSettingsService {
  // Ключи для хранения настроек
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _dailyReminderKey = 'daily_reminder';
  static const String _reminderTimeKey = 'reminder_time';
  static const String _weeklyReportKey = 'weekly_report';
  static const String _moodTrackingGoalKey = 'mood_tracking_goal';
  static const String _dataExportKey = 'data_export_enabled';
  static const String _analyticsEnabledKey = 'analytics_enabled';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _groqApiKeyKey = 'groq_api_key';
  static const String _openRouterApiKeyKey = 'openrouter_api_key';

  /// Тема приложения
  Future<AppTheme> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    return AppTheme.values.firstWhere(
      (theme) => theme.name == themeString,
      orElse: () => AppTheme.system,
    );
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
  }

  /// Язык приложения
  Future<AppLanguage> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageString = prefs.getString(_languageKey) ?? 'ru';
    return AppLanguage.values.firstWhere(
      (language) => language.code == languageString,
      orElse: () => AppLanguage.russian,
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
  }

  /// Уведомления
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// Ежедневные напоминания
  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyReminderKey) ?? true;
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderKey, enabled);
  }

  /// Время напоминания
  Future<TimeOfDay> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_reminderTimeKey) ?? '20:00';
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_reminderTimeKey, timeString);
  }

  /// Еженедельные отчеты
  Future<bool> isWeeklyReportEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_weeklyReportKey) ?? true;
  }

  Future<void> setWeeklyReportEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklyReportKey, enabled);
  }

  /// Цель отслеживания настроения
  Future<int> getMoodTrackingGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_moodTrackingGoalKey) ?? 7; // 7 дней в неделю
  }

  Future<void> setMoodTrackingGoal(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_moodTrackingGoalKey, days);
  }

  /// Экспорт данных
  Future<bool> isDataExportEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dataExportKey) ?? true;
  }

  Future<void> setDataExportEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataExportKey, enabled);
  }

  /// Аналитика
  Future<bool> isAnalyticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_analyticsEnabledKey) ?? true;
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsEnabledKey, enabled);
  }

  /// Звуки
  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  /// Тактильная обратная связь
  Future<bool> isHapticFeedbackEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticFeedbackKey) ?? true;
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticFeedbackKey, enabled);
  }

  /// Groq API ключ (хранится безопасно в SharedPreferences)
  /// ВАЖНО: Никогда не коммитьте API ключи в репозиторий!
  Future<String?> getGroqApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_groqApiKeyKey);
  }

  Future<void> setGroqApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_groqApiKeyKey, apiKey);
  }

  Future<void> clearGroqApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_groqApiKeyKey);
  }

  /// OpenRouter API ключ (хранится безопасно в SharedPreferences)
  /// ВАЖНО: Никогда не коммитьте API ключи в репозиторий!
  Future<String?> getOpenRouterApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_openRouterApiKeyKey);
  }

  Future<void> setOpenRouterApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_openRouterApiKeyKey, apiKey);
  }

  Future<void> clearOpenRouterApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_openRouterApiKeyKey);
  }

  /// Получить все настройки
  Future<AppSettings> getAllSettings() async {
    return AppSettings(
      theme: await getTheme(),
      language: await getLanguage(),
      notificationsEnabled: await areNotificationsEnabled(),
      dailyReminderEnabled: await isDailyReminderEnabled(),
      reminderTime: await getReminderTime(),
      weeklyReportEnabled: await isWeeklyReportEnabled(),
      moodTrackingGoal: await getMoodTrackingGoal(),
      dataExportEnabled: await isDataExportEnabled(),
      analyticsEnabled: await isAnalyticsEnabled(),
      soundEnabled: await isSoundEnabled(),
      hapticFeedbackEnabled: await isHapticFeedbackEnabled(),
    );
  }

  /// Сбросить все настройки
  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_notificationsEnabledKey);
    await prefs.remove(_dailyReminderKey);
    await prefs.remove(_reminderTimeKey);
    await prefs.remove(_weeklyReportKey);
    await prefs.remove(_moodTrackingGoalKey);
    await prefs.remove(_dataExportKey);
    await prefs.remove(_analyticsEnabledKey);
    await prefs.remove(_soundEnabledKey);
    await prefs.remove(_hapticFeedbackKey);
    // НЕ удаляем API ключи при сбросе настроек - они должны удаляться отдельно
    // await prefs.remove(_groqApiKeyKey);
    // await prefs.remove(_openRouterApiKeyKey);
  }
}

/// Тема приложения
enum AppTheme {
  light('settings.themes.light'),
  dark('settings.themes.dark'),
  system('settings.themes.system');

  const AppTheme(this.displayNameKey);
  final String displayNameKey;
}

/// Язык приложения
enum AppLanguage {
  russian('settings.languages.russian', 'ru'),
  english('settings.languages.english', 'en');

  const AppLanguage(this.displayNameKey, this.code);
  final String displayNameKey;
  final String code;
}

/// Модель настроек приложения
class AppSettings {
  final AppTheme theme;
  final AppLanguage language;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final TimeOfDay reminderTime;
  final bool weeklyReportEnabled;
  final int moodTrackingGoal;
  final bool dataExportEnabled;
  final bool analyticsEnabled;
  final bool soundEnabled;
  final bool hapticFeedbackEnabled;

  AppSettings({
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
    required this.dailyReminderEnabled,
    required this.reminderTime,
    required this.weeklyReportEnabled,
    required this.moodTrackingGoal,
    required this.dataExportEnabled,
    required this.analyticsEnabled,
    required this.soundEnabled,
    required this.hapticFeedbackEnabled,
  });
}
