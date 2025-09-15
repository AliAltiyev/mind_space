import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local DataSource для кэширования AI ответов
class AILocalDataSource {
  static const String _cachePrefix = 'ai_cache_';
  static const String _settingsPrefix = 'ai_setting_';

  /// Инициализация локального хранилища
  Future<void> initialize() async {
    // SharedPreferences не требует явной инициализации
    print('✅ AILocalDataSource инициализирован');
  }

  /// Кэширование AI ответа
  Future<void> cacheAIResponse(String key, dynamic response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': response,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'key': key,
      };

      final cacheJson = json.encode(cacheData);
      await prefs.setString('$_cachePrefix$key', cacheJson);

      print('💾 AI ответ закэширован: $key');
    } catch (e) {
      print('❌ Ошибка кэширования: $e');
      throw Exception('Failed to cache AI response: $e');
    }
  }

  /// Получение кэшированного ответа
  Future<dynamic> getCachedResponse(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString('$_cachePrefix$key');

      if (cacheJson == null) {
        print('📭 Кэш не найден: $key');
        return null;
      }

      final cached = json.decode(cacheJson) as Map<String, dynamic>;
      final timestamp = cached['timestamp'] as int;
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(timestamp),
      );

      // Проверяем возраст кэша (по умолчанию 1 час)
      if (age.inHours >= 1) {
        print('⏰ Кэш устарел: $key (возраст: ${age.inHours}ч)');
        await prefs.remove('$_cachePrefix$key');
        return null;
      }

      print('✅ Кэш найден: $key');
      return cached['data'];
    } catch (e) {
      print('❌ Ошибка получения кэша: $e');
      return null;
    }
  }

  /// Очистка всего кэша
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

      for (final key in keys) {
        await prefs.remove(key);
      }

      print('🗑️ Весь кэш очищен');
    } catch (e) {
      print('❌ Ошибка очистки кэша: $e');
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Сохранение настроек AI
  Future<void> saveAISetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingJson = json.encode(value);
      await prefs.setString('$_settingsPrefix$key', settingJson);
      print('⚙️ Настройка AI сохранена: $key');
    } catch (e) {
      print('❌ Ошибка сохранения настройки: $e');
      throw Exception('Failed to save AI setting: $e');
    }
  }

  /// Получение настройки AI
  Future<dynamic> getAISetting(String key, {dynamic defaultValue}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingJson = prefs.getString('$_settingsPrefix$key');

      if (settingJson == null) {
        return defaultValue;
      }

      return json.decode(settingJson);
    } catch (e) {
      print('❌ Ошибка получения настройки: $e');
      return defaultValue;
    }
  }

  /// Удаление настройки AI
  Future<void> removeAISetting(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_settingsPrefix$key');
      print('🗑️ Настройка AI удалена: $key');
    } catch (e) {
      print('❌ Ошибка удаления настройки: $e');
    }
  }
}
