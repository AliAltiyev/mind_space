import '../entities/user_achievements_entity.dart';
import '../entities/user_preferences_entity.dart';
import '../entities/user_profile_entity.dart';
import '../entities/user_stats_entity.dart';

abstract class ProfileRepository {
  // User Profile operations
  Future<UserProfileEntity> getUserProfile();
  Future<void> updateUserProfile(UserProfileEntity profile);
  Future<void> deleteUserProfile();

  // User Preferences operations
  Future<UserPreferencesEntity> getUserPreferences();
  Future<void> updateUserPreferences(UserPreferencesEntity preferences);
  Future<void> resetUserPreferences();

  // User Stats operations
  Future<UserStatsEntity> getUserStats();
  Future<void> updateUserStats(UserStatsEntity stats);
  Future<void> calculateStatsFromMoodEntries(List<dynamic> moodEntries);

  // User Achievements operations
  Future<UserAchievementsEntity> getUserAchievements();
  Future<void> updateUserAchievements(UserAchievementsEntity achievements);
  Future<void> unlockAchievement(String achievementId);
  Future<void> updateAchievementProgress(String achievementId, int progress);

  // Sync operations
  Future<void> syncWithRemote();
  Future<void> clearLocalData();
}
