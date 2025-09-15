import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';

/// Провайдер для локализации
class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier() : super(const Locale('en'));

  /// Изменение локали
  Future<void> changeLocale(Locale locale) async {
    if (!AppConstants.supportedLocales.contains(locale.languageCode)) {
      return;
    }

    state = locale;
  }

  /// Получение текущей локали
  Locale get currentLocale => state;

  /// Проверка, является ли текущая локаль русской
  bool get isRussian => state.languageCode == 'ru';

  /// Проверка, является ли текущая локаль английской
  bool get isEnglish => state.languageCode == 'en';
}

final localizationProvider =
    StateNotifierProvider<LocalizationNotifier, Locale>((ref) {
      return LocalizationNotifier();
    });

/// Провайдер для строк локализации
class LocalizationStringsNotifier extends StateNotifier<Map<String, dynamic>> {
  LocalizationStringsNotifier() : super({});

  /// Получение строки по ключу
  String getString(String key, {Map<String, String>? args}) {
    final keys = key.split('.');
    dynamic value = state;

    for (final key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return key; // Возвращаем ключ, если значение не найдено
      }
    }

    if (value is String) {
      if (args != null) {
        return value.replaceAllMapped(
          RegExp(r'\{(\w+)\}'),
          (match) => args[match.group(1)] ?? match.group(0)!,
        );
      }
      return value;
    }

    return key;
  }

  /// Обновление строк локализации
  void updateStrings(Map<String, dynamic> strings) {
    state = strings;
  }
}

final localizationStringsProvider =
    StateNotifierProvider<LocalizationStringsNotifier, Map<String, dynamic>>((
      ref,
    ) {
      return LocalizationStringsNotifier();
    });
