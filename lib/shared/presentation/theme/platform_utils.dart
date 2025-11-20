import 'dart:io';
import 'package:flutter/material.dart';

/// Утилиты для работы с платформами
class PlatformUtils {
  /// Определение платформы
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isWeb => !isIOS && !isAndroid;

  /// Получение адаптивного отступа
  static double getAdaptivePadding(BuildContext context) {
    return isIOS ? 16.0 : 16.0;
  }

  /// Получение адаптивного радиуса скругления
  static double getAdaptiveRadius(BuildContext context) {
    return isIOS ? 12.0 : 16.0;
  }

  /// Получение адаптивного размера шрифта
  static double getAdaptiveFontSize(BuildContext context, double baseSize) {
    return isIOS ? baseSize * 0.94 : baseSize;
  }

  /// Получение адаптивной высоты
  static double getAdaptiveHeight(BuildContext context, double baseHeight) {
    return isIOS ? baseHeight * 0.9 : baseHeight;
  }

  /// Получение адаптивного elevation
  static double getAdaptiveElevation(
    BuildContext context,
    double baseElevation,
  ) {
    return isIOS ? 0 : baseElevation;
  }

  /// Получение адаптивного letter spacing
  static double getAdaptiveLetterSpacing(
    BuildContext context,
    double baseSpacing,
  ) {
    return isIOS ? -0.41 : baseSpacing;
  }
}

/// Расширения для ThemeData
extension ThemeDataExtensions on ThemeData {
  /// Получение цвета поверхности с учетом платформы
  Color get adaptiveSurface {
    if (Platform.isIOS) {
      return brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface;
    }
    return colorScheme.surface;
  }

  /// Получение цвета границы с учетом платформы
  Color get adaptiveBorder {
    return colorScheme.outline.withOpacity(Platform.isIOS ? 0.1 : 0.12);
  }

  /// Получение радиуса скругления с учетом платформы
  double get adaptiveRadius => Platform.isIOS ? 12.0 : 16.0;

  /// Получение elevation с учетом платформы
  double get adaptiveElevation => Platform.isIOS ? 0 : 2;
}

/// Расширения для BuildContext
extension BuildContextThemeExtensions on BuildContext {
  /// Получение адаптивного цвета поверхности
  Color get adaptiveSurfaceColor {
    final theme = Theme.of(this);
    return theme.adaptiveSurface;
  }

  /// Получение адаптивного цвета границы
  Color get adaptiveBorderColor {
    final theme = Theme.of(this);
    return theme.adaptiveBorder;
  }

  /// Получение адаптивного радиуса
  double get adaptiveRadius {
    return PlatformUtils.getAdaptiveRadius(this);
  }

  /// Получение адаптивного elevation
  double get adaptiveElevation {
    final theme = Theme.of(this);
    return theme.adaptiveElevation;
  }

  /// Проверка на темную тему
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }

  /// Проверка на светлую тему
  bool get isLightMode {
    return Theme.of(this).brightness == Brightness.light;
  }
}
