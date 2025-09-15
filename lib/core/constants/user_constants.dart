class UserConstants {
  // Profile Constants
  static const String defaultUserId = 'user_001';
  static const String defaultUserName = 'Пользователь';
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
  static const List<String> availableLanguages = [
    'ru',
    'en',
    'es',
    'fr',
    'de',
    'zh',
    'ja',
    'ko',
  ];

  // Language Names
  static const Map<String, String> languageNames = {
    'ru': 'Русский',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
  };

  // Available Interests
  static const List<String> availableInterests = [
    'Медитация',
    'Йога',
    'Спорт',
    'Чтение',
    'Музыка',
    'Искусство',
    'Природа',
    'Путешествия',
    'Кулинария',
    'Технологии',
    'Наука',
    'Психология',
    'Фотография',
    'Танцы',
    'Театр',
    'Кино',
    'Игры',
    'Программирование',
    'Дизайн',
    'Садоводство',
  ];

  // Mental Health Goals
  static const List<String> mentalHealthGoals = [
    'Улучшить настроение',
    'Снизить стресс',
    'Улучшить сон',
    'Повысить мотивацию',
    'Развить самосознание',
    'Улучшить отношения',
    'Повысить продуктивность',
    'Найти баланс в жизни',
    'Развить эмоциональный интеллект',
    'Победить тревожность',
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
  static const Map<String, int> rarityColors = {
    'common': 0xFF9E9E9E, // Grey
    'uncommon': 0xFF4CAF50, // Green
    'rare': 0xFF2196F3, // Blue
    'epic': 0xFF9C27B0, // Purple
    'legendary': 0xFFFF9800, // Orange
  };

  // Mood Categories
  static const Map<String, List<int>> moodCategories = {
    'very_low': [1],
    'low': [2],
    'medium': [3],
    'high': [4],
    'very_high': [5],
  };

  // Mood Category Names
  static const Map<String, String> moodCategoryNames = {
    'very_low': 'Очень низкое',
    'low': 'Низкое',
    'medium': 'Среднее',
    'high': 'Хорошее',
    'very_high': 'Отличное',
  };

  // Mood Category Colors
  static const Map<String, int> moodCategoryColors = {
    'very_low': 0xFFE53E3E, // Red
    'low': 0xFFED8936, // Orange
    'medium': 0xFFECC94B, // Yellow
    'high': 0xFF68D391, // Light Green
    'very_high': 0xFF48BB78, // Green
  };

  // Default Achievement Definitions
  static const List<Map<String, dynamic>> defaultAchievements = [
    {
      'id': 'first_entry',
      'title': 'Первая запись',
      'description': 'Создайте свою первую запись настроения',
      'icon': 'first_entry',
      'target': 1,
      'category': 'milestone',
      'rarity': 'common',
    },
    {
      'id': 'streak_3',
      'title': 'Начинающий',
      'description': 'Ведите дневник 3 дня подряд',
      'icon': 'streak_3',
      'target': 3,
      'category': 'streak',
      'rarity': 'common',
    },
    {
      'id': 'streak_7',
      'title': 'Неделя привычки',
      'description': 'Ведите дневник 7 дней подряд',
      'icon': 'streak_7',
      'target': 7,
      'category': 'streak',
      'rarity': 'uncommon',
    },
    {
      'id': 'streak_30',
      'title': 'Месяц осознанности',
      'description': 'Ведите дневник 30 дней подряд',
      'icon': 'streak_30',
      'target': 30,
      'category': 'streak',
      'rarity': 'rare',
    },
    {
      'id': 'streak_100',
      'title': 'Мастер привычек',
      'description': 'Ведите дневник 100 дней подряд',
      'icon': 'streak_100',
      'target': 100,
      'category': 'streak',
      'rarity': 'epic',
    },
    {
      'id': 'mood_master',
      'title': 'Мастер настроения',
      'description': 'Достигните среднего настроения 4.0+ за месяц',
      'icon': 'mood_master',
      'target': 1,
      'category': 'mood',
      'rarity': 'rare',
    },
    {
      'id': 'data_collector',
      'title': 'Сборщик данных',
      'description': 'Создайте 100 записей настроения',
      'icon': 'data_collector',
      'target': 100,
      'category': 'frequency',
      'rarity': 'uncommon',
    },
    {
      'id': 'early_bird',
      'title': 'Ранняя пташка',
      'description': 'Создайте 10 записей до 8 утра',
      'icon': 'early_bird',
      'target': 10,
      'category': 'special',
      'rarity': 'uncommon',
    },
    {
      'id': 'night_owl',
      'title': 'Сова',
      'description': 'Создайте 10 записей после 22:00',
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

  // Default Notification Preferences
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
    'meditation',
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
