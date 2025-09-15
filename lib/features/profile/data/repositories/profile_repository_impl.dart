import '../../domain/entities/user_achievements_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/user_preferences_datasource.dart';
import '../models/user_achievements_model.dart';
import '../models/user_preferences_model.dart';
import '../models/user_profile_model.dart';
import '../models/user_stats_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final UserPreferencesDataSource preferencesDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.preferencesDataSource,
  });

  // User Profile operations
  @override
  Future<UserProfileEntity> getUserProfile() async {
    try {
      final localProfile = await localDataSource.getUserProfile();
      if (localProfile != null) {
        return _mapProfileModelToEntity(localProfile);
      }

      // If no profile exists, create a default one
      final defaultProfile = UserProfileModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Пользователь',
        joinedDate: DateTime.now(),
      );

      await localDataSource.saveUserProfile(defaultProfile);
      return _mapProfileModelToEntity(defaultProfile);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfileEntity profile) async {
    try {
      final model = _mapProfileEntityToModel(profile);
      await localDataSource.saveUserProfile(model);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserProfile() async {
    try {
      await localDataSource.deleteUserProfile();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // User Preferences operations
  @override
  Future<UserPreferencesEntity> getUserPreferences() async {
    try {
      final preferences = await preferencesDataSource.getUserPreferences();
      return _mapPreferencesModelToEntity(preferences);
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  @override
  Future<void> updateUserPreferences(UserPreferencesEntity preferences) async {
    try {
      final model = _mapPreferencesEntityToModel(preferences);
      await preferencesDataSource.saveUserPreferences(model);
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  @override
  Future<void> resetUserPreferences() async {
    try {
      await preferencesDataSource.resetToDefaults();
    } catch (e) {
      throw Exception('Failed to reset user preferences: $e');
    }
  }

  // User Stats operations
  @override
  Future<UserStatsEntity> getUserStats() async {
    try {
      final localStats = await localDataSource.getUserStats();
      if (localStats != null) {
        return _mapStatsModelToEntity(localStats);
      }

      // If no stats exist, create default ones
      final defaultStats = UserStatsModel(lastEntryDate: DateTime.now());

      await localDataSource.saveUserStats(defaultStats);
      return _mapStatsModelToEntity(defaultStats);
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  @override
  Future<void> updateUserStats(UserStatsEntity stats) async {
    try {
      final model = _mapStatsEntityToModel(stats);
      await localDataSource.saveUserStats(model);
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }

  @override
  Future<void> calculateStatsFromMoodEntries(List<dynamic> moodEntries) async {
    try {
      // Calculate stats from mood entries
      final totalEntries = moodEntries.length;
      double totalMood = 0;
      final moodDistribution = <String, int>{};
      int currentStreak = 0;
      int longestStreak = 0;
      DateTime? lastEntryDate;

      if (moodEntries.isNotEmpty) {
        // Calculate average mood and distribution
        for (final entry in moodEntries) {
          final rating = entry.rating ?? 0;
          totalMood += rating;

          final moodCategory = _getMoodCategory(rating);
          moodDistribution[moodCategory] =
              (moodDistribution[moodCategory] ?? 0) + 1;
        }

        // Calculate streaks
        final sortedEntries = List.from(moodEntries)
          ..sort((a, b) => b.date.compareTo(a.date));

        lastEntryDate = sortedEntries.first.date;

        // Calculate current streak
        DateTime currentDate = DateTime.now();
        for (final entry in sortedEntries) {
          final entryDate = entry.date;
          final daysDifference = currentDate.difference(entryDate).inDays;

          if (daysDifference <= 1) {
            currentStreak++;
            currentDate = entryDate;
          } else {
            break;
          }
        }

        // Calculate longest streak
        int tempStreak = 0;
        DateTime? prevDate;
        for (final entry in sortedEntries.reversed) {
          final entryDate = entry.date;
          if (prevDate == null || entryDate.difference(prevDate).inDays == 1) {
            tempStreak++;
            longestStreak = tempStreak > longestStreak
                ? tempStreak
                : longestStreak;
          } else {
            tempStreak = 1;
          }
          prevDate = entryDate;
        }
      }

      final averageMood = totalEntries > 0 ? totalMood / totalEntries : 0.0;

      final stats = UserStatsEntity(
        totalEntries: totalEntries,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        averageMood: averageMood,
        moodDistribution: moodDistribution,
        lastEntryDate: lastEntryDate ?? DateTime.now(),
      );

      await updateUserStats(stats);
    } catch (e) {
      throw Exception('Failed to calculate stats from mood entries: $e');
    }
  }

  // User Achievements operations
  @override
  Future<UserAchievementsEntity> getUserAchievements() async {
    try {
      final localAchievements = await localDataSource.getUserAchievements();
      if (localAchievements != null) {
        return _mapAchievementsModelToEntity(localAchievements);
      }

      // If no achievements exist, create default ones
      final defaultAchievements = UserAchievementsModel(
        achievements: _getDefaultAchievements(),
      );

      await localDataSource.saveUserAchievements(defaultAchievements);
      return _mapAchievementsModelToEntity(defaultAchievements);
    } catch (e) {
      throw Exception('Failed to get user achievements: $e');
    }
  }

  @override
  Future<void> updateUserAchievements(
    UserAchievementsEntity achievements,
  ) async {
    try {
      final model = _mapAchievementsEntityToModel(achievements);
      await localDataSource.saveUserAchievements(model);
    } catch (e) {
      throw Exception('Failed to update user achievements: $e');
    }
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    try {
      final achievements = await getUserAchievements();
      final updatedAchievements = achievements.achievements.map((achievement) {
        if (achievement.id == achievementId && !achievement.unlocked) {
          return achievement.copyWith(
            unlocked: true,
            unlockedDate: DateTime.now(),
          );
        }
        return achievement;
      }).toList();

      final totalUnlocked = updatedAchievements.where((a) => a.unlocked).length;
      final updatedEntity = achievements.copyWith(
        achievements: updatedAchievements,
        totalUnlocked: totalUnlocked,
      );

      await updateUserAchievements(updatedEntity);
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  @override
  Future<void> updateAchievementProgress(
    String achievementId,
    int progress,
  ) async {
    try {
      final achievements = await getUserAchievements();
      final updatedAchievements = achievements.achievements.map((achievement) {
        if (achievement.id == achievementId) {
          final newProgress = achievement.progress + progress;
          final shouldUnlock =
              newProgress >= achievement.target && !achievement.unlocked;

          return achievement.copyWith(
            progress: newProgress,
            unlocked: shouldUnlock,
            unlockedDate: shouldUnlock
                ? DateTime.now()
                : achievement.unlockedDate,
          );
        }
        return achievement;
      }).toList();

      final totalUnlocked = updatedAchievements.where((a) => a.unlocked).length;
      final updatedEntity = achievements.copyWith(
        achievements: updatedAchievements,
        totalUnlocked: totalUnlocked,
      );

      await updateUserAchievements(updatedEntity);
    } catch (e) {
      throw Exception('Failed to update achievement progress: $e');
    }
  }

  // Sync operations - теперь только локальные операции
  @override
  Future<void> syncWithRemote() async {
    // Локальная синхронизация - просто обновляем данные из настроек
    try {
      // Можно добавить логику для синхронизации между разными устройствами
      // через локальные файлы или другие локальные методы
    } catch (e) {
      throw Exception('Failed to sync local data: $e');
    }
  }

  @override
  Future<void> clearLocalData() async {
    try {
      await localDataSource.clearAllData();
    } catch (e) {
      throw Exception('Failed to clear local data: $e');
    }
  }

  // Helper methods for mapping
  UserProfileEntity _mapProfileModelToEntity(UserProfileModel model) {
    return UserProfileEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      dateOfBirth: model.dateOfBirth,
      profileImageUrl: model.profileImageUrl,
      bio: model.bio,
      interests: model.interests,
      mentalHealthGoals: model.mentalHealthGoals,
      joinedDate: model.joinedDate,
      streakDays: model.streakDays,
      moodStatistics: model.moodStatistics,
      totalEntries: model.totalEntries,
      averageMood: model.averageMood,
    );
  }

  UserProfileModel _mapProfileEntityToModel(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      dateOfBirth: entity.dateOfBirth,
      profileImageUrl: entity.profileImageUrl,
      bio: entity.bio,
      interests: entity.interests,
      mentalHealthGoals: entity.mentalHealthGoals,
      joinedDate: entity.joinedDate,
      streakDays: entity.streakDays,
      moodStatistics: entity.moodStatistics,
      totalEntries: entity.totalEntries,
      averageMood: entity.averageMood,
    );
  }

  UserPreferencesEntity _mapPreferencesModelToEntity(
    UserPreferencesModel model,
  ) {
    return UserPreferencesEntity(
      darkMode: model.darkMode,
      language: model.language,
      notificationsEnabled: model.notificationsEnabled,
      dailyReminderTime: model.dailyReminderTime,
      aiInsightsEnabled: model.aiInsightsEnabled,
      dataCollectionAllowed: model.dataCollectionAllowed,
      enabledFeatures: model.enabledFeatures,
      notificationPreferences: model.notificationPreferences,
    );
  }

  UserPreferencesModel _mapPreferencesEntityToModel(
    UserPreferencesEntity entity,
  ) {
    return UserPreferencesModel(
      darkMode: entity.darkMode,
      language: entity.language,
      notificationsEnabled: entity.notificationsEnabled,
      dailyReminderHour: entity.dailyReminderTime.hour,
      dailyReminderMinute: entity.dailyReminderTime.minute,
      aiInsightsEnabled: entity.aiInsightsEnabled,
      dataCollectionAllowed: entity.dataCollectionAllowed,
      enabledFeatures: entity.enabledFeatures,
      notificationPreferences: entity.notificationPreferences,
    );
  }

  UserStatsEntity _mapStatsModelToEntity(UserStatsModel model) {
    return UserStatsEntity(
      totalEntries: model.totalEntries,
      currentStreak: model.currentStreak,
      longestStreak: model.longestStreak,
      averageMood: model.averageMood,
      moodDistribution: model.moodDistribution,
      activityFrequency: model.activityFrequency,
      lastEntryDate: model.lastEntryDate,
      weeklyStats: model.weeklyStats,
      monthlyStats: model.monthlyStats,
    );
  }

  UserStatsModel _mapStatsEntityToModel(UserStatsEntity entity) {
    return UserStatsModel(
      totalEntries: entity.totalEntries,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      averageMood: entity.averageMood,
      moodDistribution: entity.moodDistribution,
      activityFrequency: entity.activityFrequency,
      lastEntryDate: entity.lastEntryDate,
      weeklyStats: entity.weeklyStats,
      monthlyStats: entity.monthlyStats,
    );
  }

  UserAchievementsEntity _mapAchievementsModelToEntity(
    UserAchievementsModel model,
  ) {
    return UserAchievementsEntity(
      achievements: model.achievements
          .map(
            (a) => AchievementEntity(
              id: a.id,
              title: a.title,
              description: a.description,
              icon: a.icon,
              unlocked: a.unlocked,
              unlockedDate: a.unlockedDate,
              progress: a.progress,
              target: a.target,
              category: a.category,
              rarity: a.rarity,
            ),
          )
          .toList(),
      totalUnlocked: model.totalUnlocked,
      totalAchievements: model.totalAchievements,
    );
  }

  UserAchievementsModel _mapAchievementsEntityToModel(
    UserAchievementsEntity entity,
  ) {
    return UserAchievementsModel(
      achievements: entity.achievements
          .map(
            (a) => AchievementModel(
              id: a.id,
              title: a.title,
              description: a.description,
              icon: a.icon,
              unlocked: a.unlocked,
              unlockedDate: a.unlockedDate,
              progress: a.progress,
              target: a.target,
              category: a.category,
              rarity: a.rarity,
            ),
          )
          .toList(),
      totalUnlocked: entity.totalUnlocked,
      totalAchievements: entity.totalAchievements,
    );
  }

  String _getMoodCategory(int rating) {
    if (rating <= 1) return 'very_low';
    if (rating <= 2) return 'low';
    if (rating <= 3) return 'medium';
    if (rating <= 4) return 'high';
    return 'very_high';
  }

  List<AchievementModel> _getDefaultAchievements() {
    return [
      AchievementModel(
        id: 'first_entry',
        title: 'Первая запись',
        description: 'Создайте свою первую запись о настроении',
        icon: '📝',
        target: 1,
        category: 'basic',
        rarity: 'common',
      ),
      AchievementModel(
        id: 'week_streak',
        title: 'Неделя подряд',
        description: 'Ведите дневник настроения 7 дней подряд',
        icon: '🔥',
        target: 7,
        category: 'streak',
        rarity: 'uncommon',
      ),
      AchievementModel(
        id: 'month_streak',
        title: 'Месяц подряд',
        description: 'Ведите дневник настроения 30 дней подряд',
        icon: '🏆',
        target: 30,
        category: 'streak',
        rarity: 'rare',
      ),
      AchievementModel(
        id: 'hundred_entries',
        title: 'Сотня записей',
        description: 'Создайте 100 записей о настроении',
        icon: '💯',
        target: 100,
        category: 'milestone',
        rarity: 'epic',
      ),
    ];
  }
}
