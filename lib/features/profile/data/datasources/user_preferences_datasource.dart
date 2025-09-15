import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_preferences_model.dart';

class UserPreferencesDataSource {
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _dailyReminderHourKey = 'daily_reminder_hour';
  static const String _dailyReminderMinuteKey = 'daily_reminder_minute';
  static const String _aiInsightsEnabledKey = 'ai_insights_enabled';
  static const String _dataCollectionAllowedKey = 'data_collection_allowed';
  static const String _enabledFeaturesKey = 'enabled_features';

  // Get user preferences
  Future<UserPreferencesModel> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return UserPreferencesModel(
        darkMode: prefs.getBool(_darkModeKey) ?? true,
        language: prefs.getString(_languageKey) ?? 'ru',
        notificationsEnabled: prefs.getBool(_notificationsEnabledKey) ?? true,
        dailyReminderHour: prefs.getInt(_dailyReminderHourKey) ?? 20,
        dailyReminderMinute: prefs.getInt(_dailyReminderMinuteKey) ?? 0,
        aiInsightsEnabled: prefs.getBool(_aiInsightsEnabledKey) ?? true,
        dataCollectionAllowed:
            prefs.getBool(_dataCollectionAllowedKey) ?? false,
        enabledFeatures:
            prefs.getStringList(_enabledFeaturesKey) ??
            ['insights', 'patterns', 'gratitude', 'meditation'],
      );
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  // Save user preferences
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_darkModeKey, preferences.darkMode);
      await prefs.setString(_languageKey, preferences.language);
      await prefs.setBool(
        _notificationsEnabledKey,
        preferences.notificationsEnabled,
      );
      await prefs.setInt(_dailyReminderHourKey, preferences.dailyReminderHour);
      await prefs.setInt(
        _dailyReminderMinuteKey,
        preferences.dailyReminderMinute,
      );
      await prefs.setBool(_aiInsightsEnabledKey, preferences.aiInsightsEnabled);
      await prefs.setBool(
        _dataCollectionAllowedKey,
        preferences.dataCollectionAllowed,
      );
      await prefs.setStringList(
        _enabledFeaturesKey,
        preferences.enabledFeatures,
      );
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  // Update specific preference
  Future<void> updateDarkMode(bool darkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, darkMode);
    } catch (e) {
      throw Exception('Failed to update dark mode preference: $e');
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
    } catch (e) {
      throw Exception('Failed to update language preference: $e');
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      throw Exception('Failed to update notifications preference: $e');
    }
  }

  Future<void> updateDailyReminderTime(int hour, int minute) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyReminderHourKey, hour);
      await prefs.setInt(_dailyReminderMinuteKey, minute);
    } catch (e) {
      throw Exception('Failed to update daily reminder time: $e');
    }
  }

  Future<void> updateAiInsightsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_aiInsightsEnabledKey, enabled);
    } catch (e) {
      throw Exception('Failed to update AI insights preference: $e');
    }
  }

  Future<void> updateEnabledFeatures(List<String> features) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_enabledFeaturesKey, features);
    } catch (e) {
      throw Exception('Failed to update enabled features: $e');
    }
  }

  // Reset preferences to default
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_darkModeKey);
      await prefs.remove(_languageKey);
      await prefs.remove(_notificationsEnabledKey);
      await prefs.remove(_dailyReminderHourKey);
      await prefs.remove(_dailyReminderMinuteKey);
      await prefs.remove(_aiInsightsEnabledKey);
      await prefs.remove(_dataCollectionAllowedKey);
      await prefs.remove(_enabledFeaturesKey);
    } catch (e) {
      throw Exception('Failed to reset preferences to defaults: $e');
    }
  }
}
