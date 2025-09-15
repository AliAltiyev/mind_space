import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/network/api_client.dart';

/// Провайдер для базы данных
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Провайдер для API клиента
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = createDioClient();
  return ApiClient(dio);
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
      // Загрузка настроек из базы данных
      final settings = <String, String>{};

      // Здесь можно загрузить настройки из базы данных
      // Например: settings['theme'] = await database.getSetting('theme') ?? 'light';

      state = AsyncValue.data(settings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Обновление настройки
  Future<void> updateSetting(String key, String value) async {
    final database = ref.read(appDatabaseProvider);
    await database.setSetting(key, value);

    // Обновляем состояние
    state = AsyncValue.data({...state.value!, key: value});
  }

  /// Получение настройки
  String? getSetting(String key) {
    return state.value?[key];
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
