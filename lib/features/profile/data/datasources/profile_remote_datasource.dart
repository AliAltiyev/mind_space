import 'package:dio/dio.dart';

import '../models/user_achievements_model.dart';
import '../models/user_preferences_model.dart';
import '../models/user_profile_model.dart';
import '../models/user_stats_model.dart';

class ProfileRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://api.mindspace.app/v1';

  ProfileRemoteDataSource({required Dio dio}) : _dio = dio;

  // User Profile operations
  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await _dio.get('$_baseUrl/profile');
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get user profile from remote: $e');
    }
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    try {
      await _dio.put('$_baseUrl/profile', data: profile.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile on remote: $e');
    }
  }

  Future<void> deleteUserProfile() async {
    try {
      await _dio.delete('$_baseUrl/profile');
    } catch (e) {
      throw Exception('Failed to delete user profile on remote: $e');
    }
  }

  // User Preferences operations
  Future<UserPreferencesModel> getUserPreferences() async {
    try {
      final response = await _dio.get('$_baseUrl/profile/preferences');
      return UserPreferencesModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get user preferences from remote: $e');
    }
  }

  Future<void> updateUserPreferences(UserPreferencesModel preferences) async {
    try {
      await _dio.put(
        '$_baseUrl/profile/preferences',
        data: preferences.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to update user preferences on remote: $e');
    }
  }

  Future<void> resetUserPreferences() async {
    try {
      await _dio.delete('$_baseUrl/profile/preferences');
    } catch (e) {
      throw Exception('Failed to reset user preferences on remote: $e');
    }
  }

  // User Stats operations
  Future<UserStatsModel> getUserStats() async {
    try {
      final response = await _dio.get('$_baseUrl/profile/stats');
      return UserStatsModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get user stats from remote: $e');
    }
  }

  Future<void> updateUserStats(UserStatsModel stats) async {
    try {
      await _dio.put('$_baseUrl/profile/stats', data: stats.toJson());
    } catch (e) {
      throw Exception('Failed to update user stats on remote: $e');
    }
  }

  // User Achievements operations
  Future<UserAchievementsModel> getUserAchievements() async {
    try {
      final response = await _dio.get('$_baseUrl/profile/achievements');
      return UserAchievementsModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get user achievements from remote: $e');
    }
  }

  Future<void> updateUserAchievements(
    UserAchievementsModel achievements,
  ) async {
    try {
      await _dio.put(
        '$_baseUrl/profile/achievements',
        data: achievements.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to update user achievements on remote: $e');
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    try {
      await _dio.post('$_baseUrl/profile/achievements/$achievementId/unlock');
    } catch (e) {
      throw Exception('Failed to unlock achievement on remote: $e');
    }
  }

  Future<void> updateAchievementProgress(
    String achievementId,
    int progress,
  ) async {
    try {
      await _dio.put(
        '$_baseUrl/profile/achievements/$achievementId/progress',
        data: {'progress': progress},
      );
    } catch (e) {
      throw Exception('Failed to update achievement progress on remote: $e');
    }
  }

  // Sync operations
  Future<Map<String, dynamic>> syncProfileData() async {
    try {
      final response = await _dio.get('$_baseUrl/profile/sync');
      return response.data;
    } catch (e) {
      throw Exception('Failed to sync profile data: $e');
    }
  }
}
