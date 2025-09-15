class AppConstants {
  // Название приложения
  static const String appName = 'MindSpace';
  static const String appVersion = '0.1.0';
  
  // Цвета
  static const int primaryColor = 0xFF007AFF;
  static const int backgroundColor = 0xFFF8F9FA;
  static const int textPrimaryColor = 0xFF1A1A1A;
  static const int textSecondaryColor = 0xFF666666;
  static const int textTertiaryColor = 0xFF999999;
  
  // Цвета настроений
  static const int verySadColor = 0xFF6B46C1;
  static const int sadColor = 0xFF3B82F6;
  static const int neutralColor = 0xFF6B7280;
  static const int happyColor = 0xFF10B981;
  static const int veryHappyColor = 0xFFF59E0B;
  
  // Размеры
  static const double borderRadius = 12.0;
  static const double cardPadding = 20.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Hive
  static const String moodEntriesBoxName = 'mood_entries';
  static const String aiInsightsBoxName = 'ai_insights';
  static const String settingsBoxName = 'settings';
  
  // API
  static const String openaiApiUrl = 'https://api.openai.com/v1';
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  // Лимиты
  static const int maxNoteLength = 500;
  static const int maxVoiceNoteDuration = 60; // секунды
  static const int maxInsightsToShow = 10;
  
  // Настройки по умолчанию
  static const bool enableVoiceInput = true;
  static const bool enableNotifications = true;
  static const int reminderHour = 20; // 8 PM
  static const int reminderMinute = 0;
  
  // Тексты
  static const String welcomeMessage = 'Добро пожаловать в MindSpace!';
  static const String howAreYouToday = 'Как дела сегодня?';
  static const String selectMood = 'Выберите настроение';
  static const String tellMore = 'Расскажите подробнее (необязательно)';
  static const String voiceNote = 'Голосовая запись';
  static const String startRecording = 'Начать запись';
  static const String listening = 'Слушаю...';
  static const String save = 'Сохранить';
  static const String today = 'Сегодня';
  static const String history = 'История настроений';
  static const String statistics = 'Статистика';
  static const String recentEntries = 'Последние записи';
  static const String allEntries = 'Все записи';
  static const String filters = 'Фильтры';
  static const String byDate = 'По дате';
  static const String byMood = 'По настроению';
  static const String all = 'Все';
  static const String reset = 'Сбросить';
  static const String close = 'Закрыть';
  static const String noEntries = 'Пока нет записей';
  static const String startTracking = 'Начните записывать свое настроение';
  static const String moodChart = 'График настроений';
  static const String weeklyStatistics = 'Статистика за неделю';
  static const String entries = 'Записи';
  
  // Сообщения об ошибках
  static const String errorLoading = 'Ошибка загрузки';
  static const String errorSaving = 'Ошибка сохранения записи';
  static const String errorUpdating = 'Ошибка обновления записи';
  static const String errorDeleting = 'Ошибка удаления записи';
  static const String errorFiltering = 'Ошибка фильтрации';
  static const String microphonePermissionDenied = 'Разрешение на использование микрофона не предоставлено';
  static const String moodRecorded = 'Настроение записано!';
  static const String pleaseSelectMood = 'Пожалуйста, выберите настроение';
  
  // Успешные сообщения
  static const String moodSaved = 'Настроение сохранено!';
  static const String moodUpdated = 'Настроение обновлено!';
  static const String moodDeleted = 'Настроение удалено!';
}

