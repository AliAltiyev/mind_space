import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Главный класс для управления темами приложения
class AppTheme {
  /// Получение светлой темы с Color Hunt палитрой
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary, // Vibrant Orange
      brightness: Brightness.light,
    ),
  );

  /// Получение темной темы с Color Hunt палитрой
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary, // Vibrant Orange
      brightness: Brightness.dark,
    ),
  );

  /// Получение темы по типу
  static ThemeData getTheme(Brightness brightness) {
    switch (brightness) {
      case Brightness.light:
        return lightTheme;
      case Brightness.dark:
        return darkTheme;
    }
  }

  /// Получение темы по строке
  static ThemeData getThemeByName(String themeName) {
    switch (themeName) {
      case 'light':
        return lightTheme;
      case 'dark':
        return darkTheme;
      default:
        return lightTheme;
    }
  }
}
