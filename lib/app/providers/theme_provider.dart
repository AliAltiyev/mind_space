import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_settings_service.dart';

/// Провайдер для темы приложения
final appThemeProvider = StateNotifierProvider<AppThemeNotifier, ThemeMode>(
  (ref) => AppThemeNotifier(ref),
);

class AppThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;
  final AppSettingsService _settingsService = AppSettingsService();

  AppThemeNotifier(this.ref) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await _settingsService.getTheme();
      state = _themeToThemeMode(savedTheme);
    } catch (e) {
      // Используем системную тему по умолчанию
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    try {
      await _settingsService.setTheme(theme);
      state = _themeToThemeMode(theme);
    } catch (e) {
      // Ошибка сохранения, но обновляем состояние
      state = _themeToThemeMode(theme);
    }
  }

  ThemeMode _themeToThemeMode(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }
}
