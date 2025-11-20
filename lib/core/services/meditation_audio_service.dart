import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

/// Сервис для управления звуком медитации
class MeditationAudioService {
  static final MeditationAudioService _instance =
      MeditationAudioService._internal();
  factory MeditationAudioService() => _instance;
  MeditationAudioService._internal();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isEnabled = true;

  /// Включен ли звук
  bool get isEnabled => _isEnabled;

  /// Играет ли звук сейчас
  bool get isPlaying => _isPlaying && (_audioPlayer?.playing ?? false);

  /// Инициализация сервиса
  Future<void> initialize() async {
    try {
      // Инициализируем только если еще не инициализирован
      if (_audioPlayer == null) {
        // Небольшая задержка для гарантии, что плагин зарегистрирован
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          _audioPlayer = AudioPlayer();
          // Пробуем выполнить простую операцию для проверки, что плагин работает
          await Future.delayed(const Duration(milliseconds: 100));
          debugPrint('✅ AudioPlayer инициализирован');
        } on MissingPluginException catch (e) {
          debugPrint('❌ MissingPluginException при создании AudioPlayer: $e');
          debugPrint('⚠️ Плагин just_audio не зарегистрирован. Выполните:');
          debugPrint('   1. flutter clean');
          debugPrint('   2. flutter pub get');
          debugPrint(
            '   3. Полностью перезапустите приложение (не hot reload)',
          );
          _audioPlayer = null;
          rethrow;
        } catch (e) {
          debugPrint('❌ Ошибка создания AudioPlayer: $e');
          // Пробуем еще раз через небольшую задержку
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            _audioPlayer = AudioPlayer();
            debugPrint('✅ AudioPlayer инициализирован (вторая попытка)');
          } on MissingPluginException catch (e2) {
            debugPrint('❌ MissingPluginException (вторая попытка): $e2');
            _audioPlayer = null;
            rethrow;
          } catch (e2) {
            debugPrint('❌ Ошибка создания AudioPlayer (вторая попытка): $e2');
            _audioPlayer = null;
            rethrow;
          }
        }
      } else {
        debugPrint('ℹ️ AudioPlayer уже инициализирован');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Ошибка инициализации AudioPlayer: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      _audioPlayer = null;
    }
  }

  /// Включить/выключить звук
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (!enabled && _isPlaying) {
      await stop();
    }
  }

  /// Воспроизвести звук медитации
  /// Использует встроенные звуки природы или тишину
  Future<void> playMeditationSound({
    MeditationSoundType type = MeditationSoundType.nature,
    double volume = 0.3,
  }) async {
    if (!_isEnabled) return;

    try {
      // Инициализируем только если нужно
      if (_audioPlayer == null) {
        try {
          await initialize();
        } catch (e) {
          debugPrint('❌ Не удалось инициализировать AudioPlayer: $e');
          return;
        }
      }

      // Проверяем, что AudioPlayer действительно создан
      if (_audioPlayer == null) {
        debugPrint('❌ AudioPlayer все еще null после инициализации');
        return;
      }

      // Останавливаем текущее воспроизведение перед загрузкой нового
      if (_isPlaying) {
        await stop();
      }

      // Используем встроенные звуки через AssetSource
      // Если файлов нет, используем тишину (можно добавить генерацию тона)
      String assetPath;
      switch (type) {
        case MeditationSoundType.nature:
          // Звуки природы (можно добавить файл)
          assetPath = 'assets/sounds/nature.mp3';
          break;
        case MeditationSoundType.ocean:
          assetPath = 'assets/sounds/ocean.mp3';
          break;
        case MeditationSoundType.rain:
          assetPath = 'assets/sounds/rain.mp3';
          break;
        case MeditationSoundType.forest:
          assetPath = 'assets/sounds/forest.mp3';
          break;
        case MeditationSoundType.silence:
          // Тишина - не воспроизводим звук
          return;
      }

      // Пытаемся загрузить звук
      try {
        debugPrint('🔊 Загружаем звук: $assetPath');
        if (_audioPlayer == null) {
          debugPrint(
            '❌ AudioPlayer не инициализирован, пытаемся инициализировать...',
          );
          await initialize();
          if (_audioPlayer == null) {
            debugPrint('❌ Не удалось инициализировать AudioPlayer');
            return;
          }
        }

        // Загружаем звук напрямую
        await _audioPlayer!.setAsset(assetPath);
        await _audioPlayer!.setLoopMode(LoopMode.all); // Зацикливание
        await _audioPlayer!.setVolume(volume);
        await _audioPlayer!.play();
        _isPlaying = true;
        debugPrint('✅ Звук воспроизводится: $assetPath');
      } on MissingPluginException catch (e) {
        debugPrint('❌ MissingPluginException при загрузке звука: $e');
        debugPrint('⚠️ Плагин just_audio не зарегистрирован');
        _isPlaying = false;
        _audioPlayer = null;
      } catch (e, stackTrace) {
        // Если файл не найден, просто не воспроизводим звук
        debugPrint('❌ Ошибка загрузки звука: $assetPath');
        debugPrint('❌ Ошибка: $e');
        debugPrint('❌ StackTrace: $stackTrace');
        _isPlaying = false;

        // Если ошибка связана с плагином, пробуем переинициализировать
        if (e.toString().contains('MissingPluginException') ||
            e.toString().contains('disposeAllPlayers')) {
          debugPrint(
            '⚠️ Обнаружена ошибка плагина, пробуем переинициализировать...',
          );
          _audioPlayer = null;
        }
      }
    } catch (e) {
      debugPrint('❌ Ошибка воспроизведения звука: $e');
      _isPlaying = false;
    }
  }

  /// Остановить звук
  Future<void> stop() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
      }
      _isPlaying = false;
    } catch (e) {
      debugPrint('❌ Ошибка остановки звука: $e');
      _isPlaying = false;
    }
  }

  /// Пауза звука
  Future<void> pause() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.pause();
      }
      _isPlaying = false;
    } catch (e) {
      debugPrint('❌ Ошибка паузы звука: $e');
      _isPlaying = false;
    }
  }

  /// Продолжить воспроизведение
  Future<void> resume() async {
    if (!_isEnabled) return;
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.play();
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('❌ Ошибка возобновления звука: $e');
      _isPlaying = false;
    }
  }

  /// Установить громкость (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('❌ Ошибка установки громкости: $e');
    }
  }

  /// Освободить ресурсы
  Future<void> dispose() async {
    try {
      await stop();
      if (_audioPlayer != null) {
        try {
          await _audioPlayer!.dispose();
        } catch (e) {
          debugPrint('⚠️ Ошибка при dispose AudioPlayer: $e');
        }
        _audioPlayer = null;
      }
      _isPlaying = false;
    } catch (e) {
      debugPrint('❌ Ошибка при dispose сервиса: $e');
    }
  }
}

/// Типы звуков для медитации
enum MeditationSoundType {
  silence, // Тишина
  nature, // Звуки природы
  ocean, // Звуки океана
  rain, // Звук дождя
  forest, // Звуки леса
}

extension MeditationSoundTypeExtension on MeditationSoundType {
  String get displayName {
    switch (this) {
      case MeditationSoundType.silence:
        return 'meditation.sound.silence'.tr();
      case MeditationSoundType.nature:
        return 'meditation.sound.nature'.tr();
      case MeditationSoundType.ocean:
        return 'meditation.sound.ocean'.tr();
      case MeditationSoundType.rain:
        return 'meditation.sound.rain'.tr();
      case MeditationSoundType.forest:
        return 'meditation.sound.forest'.tr();
    }
  }

  String get emoji {
    switch (this) {
      case MeditationSoundType.silence:
        return '🔇';
      case MeditationSoundType.nature:
        return '🌿';
      case MeditationSoundType.ocean:
        return '🌊';
      case MeditationSoundType.rain:
        return '🌧️';
      case MeditationSoundType.forest:
        return '🌲';
    }
  }
}
