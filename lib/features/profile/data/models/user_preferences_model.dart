import 'package:flutter/material.dart';

class UserPreferencesModel {
  final bool darkMode;
  final String language;
  final bool notificationsEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final bool aiInsightsEnabled;
  final bool dataCollectionAllowed;
  final List<String> enabledFeatures;
  final Map<String, dynamic> notificationPreferences;

  UserPreferencesModel({
    this.darkMode = true,
    this.language = 'ru',
    this.notificationsEnabled = true,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    this.aiInsightsEnabled = true,
    this.dataCollectionAllowed = false,
    this.enabledFeatures = const [
      'insights',
      'patterns',
      'gratitude',
      'meditation',
    ],
    this.notificationPreferences = const {},
  }) : dailyReminderHour = dailyReminderHour ?? 20,
       dailyReminderMinute = dailyReminderMinute ?? 0;

  TimeOfDay get dailyReminderTime =>
      TimeOfDay(hour: dailyReminderHour, minute: dailyReminderMinute);

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      darkMode: json['darkMode'] ?? true,
      language: json['language'] ?? 'ru',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dailyReminderHour: json['dailyReminderHour'] ?? 20,
      dailyReminderMinute: json['dailyReminderMinute'] ?? 0,
      aiInsightsEnabled: json['aiInsightsEnabled'] ?? true,
      dataCollectionAllowed: json['dataCollectionAllowed'] ?? false,
      enabledFeatures: List<String>.from(
        json['enabledFeatures'] ??
            ['insights', 'patterns', 'gratitude', 'meditation'],
      ),
      notificationPreferences: Map<String, dynamic>.from(
        json['notificationPreferences'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'darkMode': darkMode,
    'language': language,
    'notificationsEnabled': notificationsEnabled,
    'dailyReminderHour': dailyReminderHour,
    'dailyReminderMinute': dailyReminderMinute,
    'aiInsightsEnabled': aiInsightsEnabled,
    'dataCollectionAllowed': dataCollectionAllowed,
    'enabledFeatures': enabledFeatures,
    'notificationPreferences': notificationPreferences,
  };

  UserPreferencesModel copyWith({
    bool? darkMode,
    String? language,
    bool? notificationsEnabled,
    TimeOfDay? dailyReminderTime,
    bool? aiInsightsEnabled,
    bool? dataCollectionAllowed,
    List<String>? enabledFeatures,
    Map<String, dynamic>? notificationPreferences,
  }) {
    return UserPreferencesModel(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderHour: dailyReminderTime?.hour ?? dailyReminderHour,
      dailyReminderMinute: dailyReminderTime?.minute ?? dailyReminderMinute,
      aiInsightsEnabled: aiInsightsEnabled ?? this.aiInsightsEnabled,
      dataCollectionAllowed:
          dataCollectionAllowed ?? this.dataCollectionAllowed,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }
}
