import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/navigation.dart';

/// Стили голоса для медитации
enum VoiceStyle {
  calm, // Спокойный
  soothing, // Успокаивающий
  guiding, // Направляющий
  energetic, // Энергичный
}

/// Сервис для синтеза речи (TTS)
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isAvailable = false;
  VoiceStyle _currentStyle = VoiceStyle.calm;
  double _speed = 0.38; // Приятная скорость по умолчанию
  double _pitch = 0.78; // Приятный тон по умолчанию
  double _volume = 0.82; // Комфортная громкость
  String _currentLanguage = 'en';

  /// Инициализация TTS
  Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('ℹ️ TTS уже инициализирован, доступность: $_isAvailable');
      return _isAvailable;
    }

    try {
      _flutterTts = FlutterTts();
      debugPrint('🔧 Создан FlutterTts экземпляр');

      // Проверка доступности TTS - пробуем несколько способов
      _isAvailable = false;

      // Способ 1: Получаем список языков
      try {
        final languages = await _flutterTts!.getLanguages;
        debugPrint('🌐 Способ 1 - Доступные языки TTS: $languages');
        debugPrint(
          '🌐 Способ 1 - Количество языков: ${languages?.length ?? 0}',
        );

        if (languages != null && languages.isNotEmpty) {
          _isAvailable = true;
          debugPrint('✅ TTS доступен через способ 1 (getLanguages)');
        }
      } catch (e) {
        debugPrint('⚠️ Способ 1 не удался: $e');
      }

      // Способ 2: Пробуем установить язык напрямую
      if (!_isAvailable) {
        try {
          debugPrint('🔧 Способ 2 - Пробуем установить язык напрямую...');
          await _flutterTts!.setLanguage('en-US');
          _isAvailable = true;
          debugPrint('✅ TTS доступен через способ 2 (setLanguage)');
        } catch (e) {
          debugPrint('⚠️ Способ 2 не удался: $e');
        }
      }

      // Способ 3: Пробуем произнести тестовый текст
      if (!_isAvailable) {
        try {
          debugPrint('🔧 Способ 3 - Пробуем произнести тестовый текст...');
          await _flutterTts!.speak('test');
          await Future.delayed(const Duration(milliseconds: 100));
          await _flutterTts!.stop();
          _isAvailable = true;
          debugPrint('✅ TTS доступен через способ 3 (speak test)');
        } catch (e) {
          debugPrint('⚠️ Способ 3 не удался: $e');
        }
      }

      // Способ 4: Просто считаем, что TTS доступен (для некоторых устройств getLanguages может не работать)
      if (!_isAvailable) {
        debugPrint(
          '⚠️ Все способы проверки не удались, но пробуем использовать TTS',
        );
        debugPrint(
          '⚠️ На некоторых устройствах getLanguages может не работать, но TTS работает',
        );
        // На некоторых Android устройствах getLanguages может возвращать null,
        // но TTS все равно работает
        _isAvailable = true;
      }

      debugPrint('✅ Финальная проверка: TTS доступен = $_isAvailable');

      // Не останавливаем инициализацию даже если проверка не удалась
      // На некоторых устройствах getLanguages может не работать, но TTS работает
      if (!_isAvailable) {
        debugPrint(
          '⚠️ Проверка доступности не удалась, но продолжаем инициализацию',
        );
        debugPrint('⚠️ TTS может работать даже если getLanguages не работает');
        _isAvailable = true; // Пробуем использовать TTS в любом случае
      }

      // Настройка обработчиков
      _flutterTts!.setStartHandler(() {
        debugPrint('🎤 TTS начал говорить');
      });

      _flutterTts!.setCompletionHandler(() {
        debugPrint('✅ TTS завершил речь');
      });

      _flutterTts!.setErrorHandler((msg) {
        debugPrint('❌ Ошибка TTS: $msg');
      });

      // Настройка языка
      await _setLanguage();

      // Применяем настройки стиля
      await _applyStyleSettings(_currentStyle);

      // Тестовое произнесение для проверки
      try {
        debugPrint('🧪 Тестовое произнесение...');
        await _flutterTts!.speak('Test');
        await Future.delayed(const Duration(milliseconds: 500));
        await _flutterTts!.stop();
        debugPrint('✅ Тестовое произнесение успешно');
      } catch (e) {
        debugPrint('⚠️ Тестовое произнесение не удалось: $e');
      }

      _isInitialized = true;
      debugPrint('✅ TTS инициализирован и готов к работе');
      return true;
    } catch (e) {
      debugPrint('❌ Ошибка инициализации TTS: $e');
      _isAvailable = false;
      return false;
    }
  }

  /// Установка языка
  Future<void> _setLanguage() async {
    try {
      // Получаем текущий язык из easy_localization
      final context = navigatorKey.currentContext;
      if (context == null) {
        debugPrint('⚠️ Контекст недоступен, используем английский язык');
        _currentLanguage = 'en-US';
        await _flutterTts!.setLanguage('en-US');
        return;
      }

      final easyLocalization = EasyLocalization.of(context);
      final currentLocale = easyLocalization?.locale;
      final languageCode = currentLocale?.languageCode ?? 'en';

      debugPrint('🌐 Текущая локаль приложения: $languageCode');

      // Определяем язык TTS на основе локали приложения
      String targetLanguage;
      if (languageCode == 'ru') {
        targetLanguage = 'ru-RU';
      } else {
        // По умолчанию английский
        targetLanguage = 'en-US';
      }

      debugPrint('🎯 Целевой язык TTS: $targetLanguage');

      final languages = await _flutterTts!.getLanguages;
      if (languages == null || languages.isEmpty) {
        debugPrint('⚠️ Список языков недоступен, пробуем установить напрямую');
        try {
          await _flutterTts!.setLanguage(targetLanguage);
          _currentLanguage = targetLanguage;
          debugPrint('✅ Язык TTS установлен напрямую: $_currentLanguage');
          return;
        } catch (e) {
          debugPrint('❌ Не удалось установить язык напрямую: $e');
          // Fallback на английский
          await _flutterTts!.setLanguage('en-US');
          _currentLanguage = 'en-US';
          return;
        }
      }

      // Пробуем установить точный язык
      if (languages.contains(targetLanguage)) {
        await _flutterTts!.setLanguage(targetLanguage);
        _currentLanguage = targetLanguage;
        debugPrint('✅ Язык TTS установлен: $_currentLanguage');
        return;
      }

      // Пробуем найти похожий язык (например, ru-RU или ru)
      // Важно: ищем точное совпадение с languageCode, чтобы не выбрать неправильный язык
      String? matchingLanguage;

      // Сначала пробуем найти точное совпадение с кодом языка
      for (final lang in languages) {
        final langLower = lang.toLowerCase();
        // Проверяем, что язык начинается с нужного кода (например, 'en' для 'en-US', 'en-GB')
        if (langLower.startsWith('${languageCode.toLowerCase()}-') ||
            langLower == languageCode.toLowerCase()) {
          matchingLanguage = lang;
          break;
        }
      }

      if (matchingLanguage != null && matchingLanguage.isNotEmpty) {
        await _flutterTts!.setLanguage(matchingLanguage);
        _currentLanguage = matchingLanguage;
        debugPrint('✅ Используется найденный язык: $_currentLanguage');
        return;
      }

      // Fallback на английский или первый доступный
      // Важно: если приложение на английском, всегда используем английский язык
      String defaultLang;
      if (languageCode == 'en') {
        // Для английского языка приоритет: en-US > en-GB > en > первый доступный английский
        if (languages.contains('en-US')) {
          defaultLang = 'en-US';
        } else if (languages.contains('en-GB')) {
          defaultLang = 'en-GB';
        } else {
          final enLang = languages.firstWhere(
            (l) => l.toLowerCase().startsWith('en'),
            orElse: () => languages.first,
          );
          defaultLang = enLang;
        }
      } else {
        // Для других языков используем английский как fallback
        defaultLang = languages.contains('en-US')
            ? 'en-US'
            : languages.contains('en')
            ? 'en'
            : languages.first;
      }

      await _flutterTts!.setLanguage(defaultLang);
      _currentLanguage = defaultLang;
      debugPrint('⚠️ Используется язык по умолчанию: $_currentLanguage');
    } catch (e) {
      debugPrint('❌ Ошибка установки языка TTS: $e');
      // Fallback на английский
      try {
        await _flutterTts!.setLanguage('en-US');
        _currentLanguage = 'en-US';
        debugPrint('⚠️ Используется язык по умолчанию: en-US');
      } catch (e2) {
        debugPrint('❌ Критическая ошибка установки языка: $e2');
      }
    }
  }

  /// Применение настроек стиля
  Future<void> _applyStyleSettings(VoiceStyle style) async {
    if (_flutterTts == null || !_isAvailable) {
      debugPrint('⚠️ TTS не доступен для применения настроек стиля');
      return;
    }

    switch (style) {
      case VoiceStyle.calm:
        _speed = 0.38; // Приятная, комфортная скорость
        _pitch = 0.78; // Нежный, приятный тон
        _volume = 0.82; // Комфортная громкость
        break;
      case VoiceStyle.soothing:
        _speed = 0.35; // Медленная, успокаивающая скорость
        _pitch = 0.75; // Очень нежный, успокаивающий тон
        _volume = 0.78; // Мягкая громкость
        break;
      case VoiceStyle.guiding:
        _speed = 0.4; // Умеренная, направляющая скорость
        _pitch = 0.8; // Приятный, направляющий тон
        _volume = 0.85; // Четкая громкость
        break;
      case VoiceStyle.energetic:
        _speed = 0.42; // Живая, но не быстрая скорость
        _pitch = 0.85; // Приятный, энергичный тон
        _volume = 0.88; // Яркая громкость
        break;
    }

    try {
      await _flutterTts!.setSpeechRate(_speed);
      await _flutterTts!.setPitch(_pitch);
      await _flutterTts!.setVolume(_volume);
      debugPrint(
        '🎚️ Настройки TTS применены: скорость=$_speed, высота=$_pitch, громкость=$_volume',
      );
    } catch (e) {
      debugPrint('❌ Ошибка применения настроек TTS: $e');
    }
  }

  /// Установка стиля голоса
  Future<void> setVoiceStyle(VoiceStyle style) async {
    _currentStyle = style;
    await _applyStyleSettings(style);
  }

  /// Установка скорости речи (0.0-1.0)
  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.0, 1.0);
    if (_flutterTts != null && _isAvailable) {
      await _flutterTts!.setSpeechRate(_speed);
    }
  }

  /// Установка высоты тона (0.5-2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    if (_flutterTts != null && _isAvailable) {
      await _flutterTts!.setPitch(_pitch);
    }
  }

  /// Установка громкости (0.0-1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_flutterTts != null && _isAvailable) {
      await _flutterTts!.setVolume(_volume);
    }
  }

  /// Обновить язык TTS на основе текущей локали приложения
  Future<void> updateLanguage() async {
    if (_flutterTts == null) {
      debugPrint('⚠️ TTS не инициализирован, не могу обновить язык');
      return;
    }
    await _setLanguage();
  }

  /// Произнести текст
  Future<void> speak(String text) async {
    if (text.isEmpty) {
      debugPrint('⚠️ Пустой текст для произнесения');
      return;
    }

    if (_flutterTts == null) {
      debugPrint(
        '⚠️ FlutterTts не инициализирован, пытаемся инициализировать...',
      );
      final initialized = await initialize();
      if (!initialized || _flutterTts == null) {
        debugPrint(
          '⚠️ Не удалось инициализировать TTS, текст не произнесен: $text',
        );
        return;
      }
    }

    // Проверяем и обновляем язык перед каждым произнесением
    // чтобы убедиться, что язык соответствует текущей локали приложения
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final easyLocalization = EasyLocalization.of(context);
        final currentLocale = easyLocalization?.locale;
        final languageCode = currentLocale?.languageCode ?? 'en';

        // Определяем ожидаемый язык TTS
        String expectedLanguage;
        if (languageCode == 'ru') {
          expectedLanguage = 'ru-RU';
        } else {
          // По умолчанию английский
          expectedLanguage = 'en-US';
        }

        // Проверяем, соответствует ли текущий язык ожидаемому
        // Если нет - обновляем язык
        final currentLangLower = _currentLanguage.toLowerCase();
        final expectedLangLower = expectedLanguage.toLowerCase();
        final languageCodeLower = languageCode.toLowerCase();

        // Проверяем, что текущий язык начинается с нужного кода языка
        // Например, для 'en' должны быть 'en-US', 'en-GB', но не 'ru-RU'
        final languageMatches =
            currentLangLower.startsWith('$languageCodeLower-') ||
            currentLangLower == languageCodeLower ||
            currentLangLower == expectedLangLower;

        if (!languageMatches) {
          debugPrint(
            '🔄 Язык TTS ($_currentLanguage) не соответствует локали приложения ($languageCode, ожидается $expectedLanguage), обновляю...',
          );
          await _setLanguage();
        } else {
          debugPrint(
            '✅ Язык TTS соответствует локали: $_currentLanguage (локаль: $languageCode)',
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Ошибка проверки языка перед speak: $e');
      // Продолжаем произнесение даже если проверка не удалась
    }

    // Не проверяем _isAvailable здесь - пробуем произнести в любом случае
    try {
      debugPrint('🗣️ Произношу текст: "$text"');
      debugPrint(
        '📊 Текущие настройки: скорость=$_speed, высота=$_pitch, громкость=$_volume, язык=$_currentLanguage',
      );

      final result = await _flutterTts!.speak(text);
      debugPrint('✅ TTS speak вызван, результат: $result');

      // Если произнесение успешно, считаем TTS доступным
      if (!_isAvailable) {
        _isAvailable = true;
        debugPrint('✅ TTS теперь доступен (произнесение успешно)');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка произнесения текста: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      // Не устанавливаем _isAvailable = false здесь, так как ошибка может быть временной
    }
  }

  /// Остановить речь
  Future<void> stop() async {
    if (_flutterTts != null && _isAvailable) {
      try {
        await _flutterTts!.stop();
      } catch (e) {
        debugPrint('❌ Ошибка остановки TTS: $e');
      }
    }
  }

  /// Пауза речи
  Future<void> pause() async {
    if (_flutterTts != null && _isAvailable) {
      try {
        await _flutterTts!.pause();
      } catch (e) {
        debugPrint('❌ Ошибка паузы TTS: $e');
      }
    }
  }

  /// Проверка доступности TTS
  bool get isAvailable => _isAvailable;

  /// Текущий стиль голоса
  VoiceStyle get currentStyle => _currentStyle;

  /// Текущая скорость
  double get speed => _speed;

  /// Текущая высота тона
  double get pitch => _pitch;

  /// Текущая громкость
  double get volume => _volume;

  /// Освобождение ресурсов
  Future<void> dispose() async {
    if (_flutterTts != null) {
      await stop();
      _flutterTts = null;
      _isInitialized = false;
      _isAvailable = false;
    }
  }
}
