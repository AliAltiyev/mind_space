import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для работы с фото профиля
class ProfileImageService {
  static const String _profileImageKey = 'profile_image_path';
  static const String _profileImageFileName = 'profile_image.jpg';

  /// Получить путь к фото профиля
  Future<File?> getProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_profileImageKey);
      
      if (imagePath != null && await File(imagePath).exists()) {
        return File(imagePath);
      }
      return null;
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  /// Сохранить фото профиля
  Future<bool> saveProfileImage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile');
      
      // Создать папку если не существует
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final savedImage = File('${profileDir.path}/$_profileImageFileName');
      
      // Копировать изображение
      await imageFile.copy(savedImage.path);

      // Сохранить путь в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, savedImage.path);

      return true;
    } catch (e) {
      print('Error saving profile image: $e');
      return false;
    }
  }

  /// Удалить фото профиля
  Future<bool> removeProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_profileImageKey);
      
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      // Удалить путь из SharedPreferences
      await prefs.remove(_profileImageKey);

      return true;
    } catch (e) {
      print('Error removing profile image: $e');
      return false;
    }
  }

  /// Проверить, есть ли сохраненное фото
  Future<bool> hasProfileImage() async {
    try {
      final imageFile = await getProfileImage();
      return imageFile != null && await imageFile.exists();
    } catch (e) {
      print('Error checking profile image: $e');
      return false;
    }
  }

  /// Получить размер файла фото
  Future<int?> getProfileImageSize() async {
    try {
      final imageFile = await getProfileImage();
      if (imageFile != null && await imageFile.exists()) {
        return await imageFile.length();
      }
      return null;
    } catch (e) {
      print('Error getting profile image size: $e');
      return null;
    }
  }

  /// Очистить все данные профиля
  Future<bool> clearAllProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileImageKey);

      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile');
      
      if (await profileDir.exists()) {
        await profileDir.delete(recursive: true);
      }

      return true;
    } catch (e) {
      print('Error clearing profile data: $e');
      return false;
    }
  }
}
