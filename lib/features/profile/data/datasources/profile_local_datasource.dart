import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_achievements_model.dart';
import '../models/user_preferences_model.dart';
import '../models/user_profile_model.dart';
import '../models/user_stats_model.dart';

class ProfileLocalDataSource {
  static const String _profileKey = 'user_profile';
  static const String _preferencesKey = 'user_preferences';
  static const String _statsKey = 'user_stats';
  static const String _achievementsKey = 'user_achievements';

  // User Profile operations
  Future<UserProfileModel?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson != null) {
        final profileMap = json.decode(profileJson) as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user profile from local storage: $e');
    }
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(profile.toJson());
      await prefs.setString(_profileKey, profileJson);
    } catch (e) {
      throw Exception('Failed to save user profile to local storage: $e');
    }
  }

  Future<void> deleteUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (e) {
      throw Exception('Failed to delete user profile from local storage: $e');
    }
  }

  // User Preferences operations
  Future<UserPreferencesModel?> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_preferencesKey);

      if (preferencesJson != null) {
        final preferencesMap =
            json.decode(preferencesJson) as Map<String, dynamic>;
        return UserPreferencesModel.fromJson(preferencesMap);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user preferences from local storage: $e');
    }
  }

  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = json.encode(preferences.toJson());
      await prefs.setString(_preferencesKey, preferencesJson);
    } catch (e) {
      throw Exception('Failed to save user preferences to local storage: $e');
    }
  }

  Future<void> resetUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_preferencesKey);
    } catch (e) {
      throw Exception(
        'Failed to reset user preferences from local storage: $e',
      );
    }
  }

  // User Stats operations
  Future<UserStatsModel?> getUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        final statsMap = json.decode(statsJson) as Map<String, dynamic>;
        return UserStatsModel.fromJson(statsMap);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user stats from local storage: $e');
    }
  }

  Future<void> saveUserStats(UserStatsModel stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toJson());
      await prefs.setString(_statsKey, statsJson);
    } catch (e) {
      throw Exception('Failed to save user stats to local storage: $e');
    }
  }

  // User Achievements operations
  Future<UserAchievementsModel?> getUserAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);

      if (achievementsJson != null) {
        final achievementsMap =
            json.decode(achievementsJson) as Map<String, dynamic>;
        return UserAchievementsModel.fromJson(achievementsMap);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user achievements from local storage: $e');
    }
  }

  Future<void> saveUserAchievements(UserAchievementsModel achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = json.encode(achievements.toJson());
      await prefs.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      throw Exception('Failed to save user achievements to local storage: $e');
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      await prefs.remove(_preferencesKey);
      await prefs.remove(_statsKey);
      await prefs.remove(_achievementsKey);
    } catch (e) {
      throw Exception(
        'Failed to clear all profile data from local storage: $e',
      );
    }
  }
}
