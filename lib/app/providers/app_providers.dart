import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/network/api_client.dart';
import '../../core/services/shared_preferences_service.dart';

/// Провайдер для базы данных
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  // Инициализируем базу данных при создании
  database.initialize();
  return database;
});

/// Провайдер для API клиента
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = createDioClient();
  return ApiClient(dio);
});

/// Провайдер для SharedPreferences сервиса
final sharedPreferencesProvider = Provider<SharedPreferencesService>((ref) {
  return SharedPreferencesService.instance;
});

/// Провайдер для настроек приложения
class AppSettingsNotifier
    extends StateNotifier<AsyncValue<Map<String, String>>> {
  AppSettingsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  final Ref ref;

  Future<void> _loadSettings() async {
    try {
      final sharedPrefs = ref.read(sharedPreferencesProvider);
      await sharedPrefs.init();

      // Загрузка настроек из SharedPreferences
      final settings = <String, String>{};
      
      // Загружаем основные настройки
      final theme = await sharedPrefs.getSetting('theme');
      if (theme != null) settings['theme'] = theme;
      
      final locale = await sharedPrefs.getSetting('locale');
      if (locale != null) settings['locale'] = locale;

      state = AsyncValue.data(settings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Обновление настройки
  Future<void> updateSetting(String key, String value) async {
    try {
      final sharedPrefs = ref.read(sharedPreferencesProvider);
      await sharedPrefs.setSetting(key, value);

      // Обновляем состояние
      if (state.hasValue) {
        state = AsyncValue.data({...state.value!, key: value});
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Получение настройки
  String? getSetting(String key) {
    return state.value?[key];
  }

  /// Проверка первого запуска
  Future<bool> isFirstLaunch() async {
    final sharedPrefs = ref.read(sharedPreferencesProvider);
    return await sharedPrefs.isFirstLaunch();
  }

  /// Отметить первый запуск как завершенный
  Future<void> setFirstLaunchCompleted() async {
    final sharedPrefs = ref.read(sharedPreferencesProvider);
    await sharedPrefs.setFirstLaunchCompleted();
  }

  /// Проверка, показывался ли splash
  Future<bool> hasShownSplash() async {
    final sharedPrefs = ref.read(sharedPreferencesProvider);
    return await sharedPrefs.hasShownSplash();
  }

  /// Отметить, что splash был показан
  Future<void> setSplashShown() async {
    final sharedPrefs = ref.read(sharedPreferencesProvider);
    await sharedPrefs.setSplashShown();
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AsyncValue<Map<String, String>>>(
      (ref) {
        return AppSettingsNotifier(ref);
      },
    );

/// Провайдер для темы приложения
class AppThemeNotifier extends StateNotifier<String> {
  AppThemeNotifier(this.ref) : super('light');

  final Ref ref;

  /// Переключение темы
  Future<void> toggleTheme() async {
    final currentTheme = state;
    final newTheme = currentTheme == 'light' ? 'dark' : 'light';

    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    await settingsNotifier.updateSetting('theme', newTheme);

    state = newTheme;
  }
}

final appThemeProvider = StateNotifierProvider<AppThemeNotifier, String>((ref) {
  return AppThemeNotifier(ref);
});

/// Провайдер для локализации
class AppLocaleNotifier extends StateNotifier<String> {
  AppLocaleNotifier(this.ref) : super('en');

  final Ref ref;

  /// Изменение локали
  Future<void> changeLocale(String locale) async {
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    await settingsNotifier.updateSetting('locale', locale);

    state = locale;
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, String>((
  ref,
) {
  return AppLocaleNotifier(ref);
});

/// Провайдер для состояния загрузки
class AppLoadingNotifier extends StateNotifier<bool> {
  AppLoadingNotifier() : super(false);

  /// Показать загрузку
  void show() {
    state = true;
  }

  /// Скрыть загрузку
  void hide() {
    state = false;
  }
}

final appLoadingProvider = StateNotifierProvider<AppLoadingNotifier, bool>((
  ref,
) {
  return AppLoadingNotifier();
});

/// Провайдер для состояния ошибки
class AppErrorNotifier extends StateNotifier<String?> {
  AppErrorNotifier() : super(null);

  /// Установить ошибку
  void setError(String error) {
    state = error;
  }

  /// Очистить ошибку
  void clearError() {
    state = null;
  }
}

final appErrorProvider = StateNotifierProvider<AppErrorNotifier, String?>((
  ref,
) {
  return AppErrorNotifier();
});
