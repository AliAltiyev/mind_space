import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для работы с SharedPreferences
class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  SharedPreferences? _prefs;

  SharedPreferencesService._();

  static SharedPreferencesService get instance {
    _instance ??= SharedPreferencesService._();
    return _instance!;
  }

  /// Инициализация SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Проверка, является ли это первым запуском приложения
  Future<bool> isFirstLaunch() async {
    await init();
    try {
      // Проверяем, есть ли значение и какого типа
      if (_prefs?.containsKey('is_first_launch') == true) {
        final value = _prefs?.get('is_first_launch');
        if (value is bool) {
          return value;
        } else if (value is String) {
          // Если сохранено как строка, конвертируем
          return value.toLowerCase() == 'true';
        }
      }
      return true; // По умолчанию первый запуск
    } catch (e) {
      print('Error reading is_first_launch: $e');
      return true;
    }
  }

  /// Отметить, что приложение уже запускалось
  Future<void> setFirstLaunchCompleted() async {
    await init();
    await _prefs?.setBool('is_first_launch', false);
  }

  /// Проверка, показывался ли уже splash screen
  Future<bool> hasShownSplash() async {
    await init();
    try {
      // Проверяем, есть ли значение и какого типа
      if (_prefs?.containsKey('has_shown_splash') == true) {
        final value = _prefs?.get('has_shown_splash');
        if (value is bool) {
          return value;
        } else if (value is String) {
          // Если сохранено как строка, конвертируем
          return value.toLowerCase() == 'true';
        }
      }
      return false; // По умолчанию не показывался
    } catch (e) {
      print('Error reading has_shown_splash: $e');
      return false;
    }
  }

  /// Отметить, что splash screen был показан
  Future<void> setSplashShown() async {
    await init();
    await _prefs?.setBool('has_shown_splash', true);
  }

  /// Получить настройку по ключу
  Future<String?> getSetting(String key) async {
    await init();
    return _prefs?.getString(key);
  }

  /// Установить настройку
  Future<void> setSetting(String key, String value) async {
    await init();
    await _prefs?.setString(key, value);
  }

  /// Получить булеву настройку
  Future<bool?> getBoolSetting(String key) async {
    await init();
    try {
      if (_prefs?.containsKey(key) == true) {
        final value = _prefs?.get(key);
        if (value is bool) {
          return value;
        } else if (value is String) {
          // Если сохранено как строка, конвертируем
          return value.toLowerCase() == 'true';
        }
      }
      return null;
    } catch (e) {
      print('Error reading bool setting $key: $e');
      return null;
    }
  }

  /// Установить булеву настройку
  Future<void> setBoolSetting(String key, bool value) async {
    await init();
    await _prefs?.setBool(key, value);
  }

  /// Получить числовую настройку
  Future<int?> getIntSetting(String key) async {
    await init();
    return _prefs?.getInt(key);
  }

  /// Установить числовую настройку
  Future<void> setIntSetting(String key, int value) async {
    await init();
    await _prefs?.setInt(key, value);
  }

  /// Удалить настройку
  Future<void> removeSetting(String key) async {
    await init();
    await _prefs?.remove(key);
  }

  /// Очистить все настройки
  Future<void> clearAll() async {
    await init();
    await _prefs?.clear();
  }

  /// Исправить проблемы с типами данных в настройках
  Future<void> fixDataTypeIssues() async {
    await init();
    
    // Проверяем и исправляем проблемные boolean настройки
    final boolKeys = ['is_first_launch', 'has_shown_splash'];
    
    for (final key in boolKeys) {
      if (_prefs?.containsKey(key) == true) {
        final value = _prefs?.get(key);
        if (value is String) {
          // Удаляем неправильно сохраненную строку
          await _prefs?.remove(key);
          print('Removed incorrectly stored string value for key: $key');
        }
      }
    }
  }
}
