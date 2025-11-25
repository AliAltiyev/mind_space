import 'package:easy_localization/easy_localization.dart';

class UserConstants {
  // Profile Constants
  static const String defaultUserId = 'user_001';
  static String get defaultUserName => 'profile.user'.tr();
  static const String defaultUserEmail = '';
  static const String defaultUserBio = '';

  // Preferences Constants
  static const bool defaultDarkMode = true;
  static const String defaultLanguage = 'ru';
  static const bool defaultNotificationsEnabled = true;
  static const int defaultDailyReminderHour = 20;
  static const int defaultDailyReminderMinute = 0;
  static const bool defaultAiInsightsEnabled = true;
  static const bool defaultDataCollectionAllowed = false;

  // Available Languages
  static const List<String> availableLanguages = ['ru', 'en'];

  //  Map<String, String> languageNames = {
  static Map<String, String> languageNames = {
    'ru': 'settings.languages.russian'.tr(),
    'en': 'English',
  };

  // Available Interests
  static List<String> availableInterests = [
    'interests.meditation'.tr(),
    'interests.yoga'.tr(),
    'interests.sports'.tr(),
    'interests.reading'.tr(),
    'interests.music'.tr(),
    'interests.art'.tr(),
    'interests.nature'.tr(),
    'interests.travel'.tr(),
    'interests.cooking'.tr(),
    'interests.technology'.tr(),
    'interests.science'.tr(),
    'interests.psychology'.tr(),
    'interests.photography'.tr(),
    'interests.dancing'.tr(),
    'interests.theater'.tr(),
    'interests.movies'.tr(),
    'interests.games'.tr(),
    'interests.programming'.tr(),
    'interests.design'.tr(),
    'interests.gardening'.tr(),
  ];

  // Mental Health Goals
  static List<String> mentalHealthGoals = [
    'goals.improve_mood'.tr(),
    'goals.reduce_stress'.tr(),
    'goals.improve_sleep'.tr(),
    'goals.increase_motivation'.tr(),
    'goals.develop_self_awareness'.tr(),
    'goals.improve_relationships'.tr(),
    'goals.increase_productivity'.tr(),
    'goals.find_life_balance'.tr(),
    'goals.develop_emotional_intelligence'.tr(),
    'goals.overcome_anxiety'.tr(),
  ];

  // Achievement Categories
  static const List<String> achievementCategories = [
    'streak',
    'mood',
    'frequency',
    'milestone',
    'special',
  ];

  // Achievement Rarities
  static const List<String> achievementRarities = [
    'common',
    'uncommon',
    'rare',
    'epic',
    'legendary',
  ];

  // Rarity Colors
  Map<String, int> rarityColors = {
    'common': 0xFF9E9E9E, // Grey
    'uncommon': 0xFF4CAF50, // Green
    'rare': 0xFF2196F3, // Blue
    'epic': 0xFF9C27B0, // Purple
    'legendary': 0xFFFF9800, // Orange
  };

  // Mood Categories
  Map<String, List<int>> moodCategories = {
    'very_low': [1],
    'low': [2],
    'medium': [3],
    'high': [4],
    'very_high': [5],
  };

  // Mood Category Names
  Map<String, String> moodCategoryNames = {
    'very_low': 'mood.moods.very_sad'.tr(),
    'low': 'mood.moods.sad'.tr(),
    'medium': 'mood.moods.neutral'.tr(),
    'high': 'mood.moods.happy'.tr(),
    'very_high': 'mood.moods.very_happy'.tr(),
  };

  // Mood Category Colors
  Map<String, int> moodCategoryColors = {
    'very_low': 0xFFE53E3E, // Red
    'low': 0xFFED8936, // Orange
    'medium': 0xFFECC94B, // Yellow
    'high': 0xFF68D391, // Light Green
    'very_high': 0xFF48BB78, // Green
  };

  // Default Achievement Definitions
  List<Map<String, dynamic>> defaultAchievements = [
    {
      'id': 'first_entry',
      'title': 'achievements.first_entry'.tr(),
      'description': 'achievements.first_entry_desc'.tr(),
      'icon': 'first_entry',
      'target': 1,
      'category': 'milestone',
      'rarity': 'common',
    },
    {
      'id': 'streak_3',
      'title': 'achievements.beginner'.tr(),
      'description': 'achievements.beginner_desc'.tr(),
      'icon': 'streak_3',
      'target': 3,
      'category': 'streak',
      'rarity': 'common',
    },
    {
      'id': 'streak_7',
      'title': 'achievements.week_habit'.tr(),
      'description': 'achievements.week_habit_desc'.tr(),
      'icon': 'streak_7',
      'target': 7,
      'category': 'streak',
      'rarity': 'uncommon',
    },
    {
      'id': 'streak_30',
      'title': 'achievements.month_mindfulness'.tr(),
      'description': 'achievements.month_mindfulness_desc'.tr(),
      'icon': 'streak_30',
      'target': 30,
      'category': 'streak',
      'rarity': 'rare',
    },
    {
      'id': 'streak_100',
      'title': 'achievements.habit_master'.tr(),
      'description': 'achievements.habit_master_desc'.tr(),
      'icon': 'streak_100',
      'target': 100,
      'category': 'streak',
      'rarity': 'epic',
    },
    {
      'id': 'mood_master',
      'title': 'achievements.mood_master'.tr(),
      'description': 'achievements.mood_master_desc'.tr(),
      'icon': 'mood_master',
      'target': 1,
      'category': 'mood',
      'rarity': 'rare',
    },
    {
      'id': 'data_collector',
      'title': 'achievements.data_collector'.tr(),
      'description': 'achievements.data_collector_desc'.tr(),
      'icon': 'data_collector',
      'target': 100,
      'category': 'frequency',
      'rarity': 'uncommon',
    },
    {
      'id': 'early_bird',
      'title': 'achievements.early_bird'.tr(),
      'description': 'achievements.early_bird_desc'.tr(),
      'icon': 'early_bird',
      'target': 10,
      'category': 'special',
      'rarity': 'uncommon',
    },
    {
      'id': 'night_owl',
      'title': 'achievements.night_owl'.tr(),
      'description': 'achievements.night_owl_desc'.tr(),
      'icon': 'night_owl',
      'target': 10,
      'category': 'special',
      'rarity': 'uncommon',
    },
  ];

  // Notification Types
  static const List<String> notificationTypes = [
    'daily_reminder',
    'streak_reminder',
    'achievement_unlocked',
    'weekly_summary',
    'monthly_insights',
  ];

  //Default Notification Preferences
  static const Map<String, bool> defaultNotificationPreferences = {
    'daily_reminder': true,
    'streak_reminder': true,
    'achievement_unlocked': true,
    'weekly_summary': false,
    'monthly_insights': true,
  };

  // Feature Flags
  static const List<String> availableFeatures = [
    'insights',
    'patterns',
    'gratitude',
    'meditatio  n',
    'achievements',
    'stats',
    'export',
    'sync',
  ];

  // Default Enabled Features
  static const List<String> defaultEnabledFeatures = [
    'insights',
    'patterns',
    'gratitude',
    'meditation',
    'achievements',
    'stats',
  ];

  // Profile Image Constants
  static const int maxProfileImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const int profileImageSize = 200; // pixels

  // Validation Constants
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxBioLength = 200;
  static const int maxInterestsCount = 10;
  static const int minAge = 13;
  static const int maxAge = 120;

  // Cache Constants
  static const Duration profileCacheDuration = Duration(hours: 1);
  static const Duration statsCacheDuration = Duration(minutes: 30);
  static const Duration achievementsCacheDuration = Duration(hours: 6);

  // Sync Constants
  static const Duration syncInterval = Duration(hours: 2);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 5);
}
