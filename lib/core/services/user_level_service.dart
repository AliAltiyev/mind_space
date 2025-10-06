import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

/// Сервис для управления уровнями пользователя
class UserLevelService {
  static const String _levelKey = 'user_level';
  static const String _experienceKey = 'user_experience';
  static const String _totalEntriesKey = 'total_mood_entries';
  static const String _streakKey = 'current_streak';
  static const String _aiChatsKey = 'ai_chat_count';
  static const String _insightsViewedKey = 'insights_viewed_count';

  /// Получить текущий уровень пользователя
  Future<int> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  /// Получить текущий опыт пользователя
  Future<int> getCurrentExperience() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_experienceKey) ?? 0;
  }

  /// Получить опыт до следующего уровня
  Future<int> getExperienceToNextLevel() async {
    final currentLevel = await getCurrentLevel();
    final currentExp = await getCurrentExperience();
    final expNeeded = _getExperienceForLevel(currentLevel + 1);
    return expNeeded - currentExp;
  }

  /// Получить прогресс до следующего уровня (0.0 - 1.0)
  Future<double> getLevelProgress() async {
    final currentLevel = await getCurrentLevel();
    final currentExp = await getCurrentExperience();
    final currentLevelExp = _getExperienceForLevel(currentLevel);
    final nextLevelExp = _getExperienceForLevel(currentLevel + 1);
    
    final progressInCurrentLevel = currentExp - currentLevelExp;
    final expNeededForNextLevel = nextLevelExp - currentLevelExp;
    
    return progressInCurrentLevel / expNeededForNextLevel;
  }

  /// Получить название уровня
  String getLevelName(int level) {
    if (level <= 5) return 'user_level.novice'.tr();
    if (level <= 10) return 'user_level.explorer'.tr();
    if (level <= 15) return 'user_level.expert'.tr();
    if (level <= 20) return 'user_level.master'.tr();
    if (level <= 25) return 'user_level.guru'.tr();
    return 'user_level.legend'.tr();
  }

  /// Получить иконку уровня
  String getLevelIcon(int level) {
    if (level <= 5) return '🌱';
    if (level <= 10) return '🌿';
    if (level <= 15) return '🌳';
    if (level <= 20) return '⭐';
    if (level <= 25) return '🌟';
    return '👑';
  }

  /// Получить описание уровня
  String getLevelDescription(int level) {
    if (level <= 5) return 'user_level.novice_desc'.tr();
    if (level <= 10) return 'user_level.explorer_desc'.tr();
    if (level <= 15) return 'user_level.expert_desc'.tr();
    if (level <= 20) return 'user_level.master_desc'.tr();
    if (level <= 25) return 'user_level.guru_desc'.tr();
    return 'user_level.legend_desc'.tr();
  }

  /// Добавить опыт за запись настроения
  Future<void> addExperienceForMoodEntry() async {
    await _addExperience(10); // 10 опыта за каждую запись
  }

  /// Добавить опыт за серию дней
  Future<void> addExperienceForStreak(int streakDays) async {
    // Бонус за серии: 5 опыта за каждый день серии (максимум 100)
    final bonus = (streakDays * 5).clamp(0, 100);
    await _addExperience(bonus);
  }

  /// Добавить опыт за использование AI чата
  Future<void> addExperienceForAIChat() async {
    await _addExperience(5); // 5 опыта за каждый чат с AI
  }

  /// Добавить опыт за просмотр инсайтов
  Future<void> addExperienceForInsights() async {
    await _addExperience(3); // 3 опыта за просмотр инсайтов
  }

  /// Добавить опыт за достижение недели
  Future<void> addExperienceForWeekCompletion() async {
    await _addExperience(25); // 25 опыта за завершение недели
  }

  /// Добавить опыт за достижение месяца
  Future<void> addExperienceForMonthCompletion() async {
    await _addExperience(100); // 100 опыта за завершение месяца
  }

  /// Добавить опыт
  Future<void> _addExperience(int experience) async {
    final prefs = await SharedPreferences.getInstance();
    final currentExp = await getCurrentExperience();
    final newExp = currentExp + experience;
    
    await prefs.setInt(_experienceKey, newExp);
    
    // Проверить, не повысился ли уровень
    final currentLevel = await getCurrentLevel();
    final newLevel = _getLevelFromExperience(newExp);
    
    if (newLevel > currentLevel) {
      await prefs.setInt(_levelKey, newLevel);
      // Можно добавить уведомление о повышении уровня
    }
  }

  /// Получить уровень на основе опыта
  int _getLevelFromExperience(int experience) {
    int level = 1;
    while (_getExperienceForLevel(level + 1) <= experience) {
      level++;
    }
    return level;
  }

  /// Получить опыт, необходимый для достижения уровня
  int _getExperienceForLevel(int level) {
    if (level <= 1) return 0;
    if (level <= 5) return (level - 1) * 100; // 100, 200, 300, 400
    if (level <= 10) return 400 + (level - 5) * 150; // 550, 700, 850, 1000, 1150
    if (level <= 15) return 1150 + (level - 10) * 200; // 1350, 1550, 1750, 1950, 2150
    if (level <= 20) return 2150 + (level - 15) * 300; // 2450, 2750, 3050, 3350, 3650
    if (level <= 25) return 3650 + (level - 20) * 500; // 4150, 4650, 5150, 5650, 6150
    
    // Для уровней выше 25
    return 6150 + (level - 25) * 1000;
  }

  /// Получить статистику пользователя
  Future<UserLevelStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    return UserLevelStats(
      level: await getCurrentLevel(),
      experience: await getCurrentExperience(),
      experienceToNext: await getExperienceToNextLevel(),
      progress: await getLevelProgress(),
      totalEntries: prefs.getInt(_totalEntriesKey) ?? 0,
      currentStreak: prefs.getInt(_streakKey) ?? 0,
      aiChats: prefs.getInt(_aiChatsKey) ?? 0,
      insightsViewed: prefs.getInt(_insightsViewedKey) ?? 0,
    );
  }

  /// Обновить статистику
  Future<void> updateStats({
    int? totalEntries,
    int? currentStreak,
    int? aiChats,
    int? insightsViewed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (totalEntries != null) {
      await prefs.setInt(_totalEntriesKey, totalEntries);
    }
    if (currentStreak != null) {
      await prefs.setInt(_streakKey, currentStreak);
    }
    if (aiChats != null) {
      await prefs.setInt(_aiChatsKey, aiChats);
    }
    if (insightsViewed != null) {
      await prefs.setInt(_insightsViewedKey, insightsViewed);
    }
  }

  /// Сбросить все данные уровня (для тестирования)
  Future<void> resetLevelData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_levelKey);
    await prefs.remove(_experienceKey);
    await prefs.remove(_totalEntriesKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_aiChatsKey);
    await prefs.remove(_insightsViewedKey);
  }
}

/// Статистика уровня пользователя
class UserLevelStats {
  final int level;
  final int experience;
  final int experienceToNext;
  final double progress;
  final int totalEntries;
  final int currentStreak;
  final int aiChats;
  final int insightsViewed;

  UserLevelStats({
    required this.level,
    required this.experience,
    required this.experienceToNext,
    required this.progress,
    required this.totalEntries,
    required this.currentStreak,
    required this.aiChats,
    required this.insightsViewed,
  });

  /// Получить название уровня
  String get levelName => _getLevelName(level);

  /// Получить иконку уровня
  String get levelIcon => _getLevelIcon(level);

  /// Получить описание уровня
  String get levelDescription => _getLevelDescription(level);

  String _getLevelName(int level) {
    if (level <= 5) return 'user_level.novice'.tr();
    if (level <= 10) return 'user_level.explorer'.tr();
    if (level <= 15) return 'user_level.expert'.tr();
    if (level <= 20) return 'user_level.master'.tr();
    if (level <= 25) return 'user_level.guru'.tr();
    return 'user_level.legend'.tr();
  }

  String _getLevelIcon(int level) {
    if (level <= 5) return '🌱';
    if (level <= 10) return '🌿';
    if (level <= 15) return '🌳';
    if (level <= 20) return '⭐';
    if (level <= 25) return '🌟';
    return '👑';
  }

  String _getLevelDescription(int level) {
    if (level <= 5) return 'user_level.novice_desc'.tr();
    if (level <= 10) return 'user_level.explorer_desc'.tr();
    if (level <= 15) return 'user_level.expert_desc'.tr();
    if (level <= 20) return 'user_level.master_desc'.tr();
    if (level <= 25) return 'user_level.guru_desc'.tr();
    return 'user_level.legend_desc'.tr();
  }
}
