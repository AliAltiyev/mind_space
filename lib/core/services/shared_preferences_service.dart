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
    return _prefs?.getBool('is_first_launch') ?? true;
  }

  /// Отметить, что приложение уже запускалось
  Future<void> setFirstLaunchCompleted() async {
    await init();
    await _prefs?.setBool('is_first_launch', false);
  }

  /// Проверка, показывался ли уже splash screen
  Future<bool> hasShownSplash() async {
    await init();
    return _prefs?.getBool('has_shown_splash') ?? false;
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
    return _prefs?.getBool(key);
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
}
