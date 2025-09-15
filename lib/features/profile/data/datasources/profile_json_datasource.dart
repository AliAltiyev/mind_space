import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_achievements_model.dart';
import '../models/user_profile_model.dart';
import '../models/user_stats_model.dart';

/// Локальный data source для профиля пользователя с использованием JSON файлов и SharedPreferences
class ProfileJsonDataSource {
  static const String _profileKey = 'user_profile';
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
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(profile.toJson());
      await prefs.setString(_profileKey, profileJson);
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('Failed to save user profile');
    }
  }

  Future<void> deleteUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (e) {
      print('Error deleting user profile: $e');
      throw Exception('Failed to delete user profile');
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
      print('Error getting user stats: $e');
      return null;
    }
  }

  Future<void> saveUserStats(UserStatsModel stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toJson());
      await prefs.setString(_statsKey, statsJson);
    } catch (e) {
      print('Error saving user stats: $e');
      throw Exception('Failed to save user stats');
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
      print('Error getting user achievements: $e');
      return null;
    }
  }

  Future<void> saveUserAchievements(UserAchievementsModel achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = json.encode(achievements.toJson());
      await prefs.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      print('Error saving user achievements: $e');
      throw Exception('Failed to save user achievements');
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      await prefs.remove(_statsKey);
      await prefs.remove(_achievementsKey);
    } catch (e) {
      print('Error clearing all data: $e');
      throw Exception('Failed to clear all data');
    }
  }
}
