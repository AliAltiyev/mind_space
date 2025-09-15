import 'package:flutter/material.dart';

class UserPreferencesEntity {
  final bool darkMode;
  final String language;
  final bool notificationsEnabled;
  final TimeOfDay dailyReminderTime;
  final bool aiInsightsEnabled;
  final bool dataCollectionAllowed;
  final List<String> enabledFeatures;
  final Map<String, dynamic> notificationPreferences;

  UserPreferencesEntity({
    this.darkMode = true,
    this.language = 'ru',
    this.notificationsEnabled = true,
    TimeOfDay? dailyReminderTime,
    this.aiInsightsEnabled = true,
    this.dataCollectionAllowed = false,
    this.enabledFeatures = const [
      'insights',
      'patterns',
      'gratitude',
      'meditation',
    ],
    this.notificationPreferences = const {},
  }) : dailyReminderTime =
           dailyReminderTime ?? const TimeOfDay(hour: 20, minute: 0);

  UserPreferencesEntity copyWith({
    bool? darkMode,
    String? language,
    bool? notificationsEnabled,
    TimeOfDay? dailyReminderTime,
    bool? aiInsightsEnabled,
    bool? dataCollectionAllowed,
    List<String>? enabledFeatures,
    Map<String, dynamic>? notificationPreferences,
  }) {
    return UserPreferencesEntity(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      aiInsightsEnabled: aiInsightsEnabled ?? this.aiInsightsEnabled,
      dataCollectionAllowed:
          dataCollectionAllowed ?? this.dataCollectionAllowed,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferencesEntity &&
        other.darkMode == darkMode &&
        other.language == language &&
        other.notificationsEnabled == notificationsEnabled &&
        other.dailyReminderTime == dailyReminderTime &&
        other.aiInsightsEnabled == aiInsightsEnabled &&
        other.dataCollectionAllowed == dataCollectionAllowed;
  }

  @override
  int get hashCode {
    return Object.hash(
      darkMode,
      language,
      notificationsEnabled,
      dailyReminderTime,
      aiInsightsEnabled,
      dataCollectionAllowed,
    );
  }

  @override
  String toString() {
    return 'UserPreferencesEntity(darkMode: $darkMode, language: $language, notificationsEnabled: $notificationsEnabled, aiInsightsEnabled: $aiInsightsEnabled)';
  }
}
