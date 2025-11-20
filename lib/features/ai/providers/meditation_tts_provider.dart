import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sleep/domain/entities/sleep_entry.dart';
import '../../sleep/data/repositories/sleep_repository.dart';
import '../../sleep/data/repositories/sleep_repository_impl.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/api/groq_client.dart';
import '../services/tts_service.dart';
import '../models/meditation_phase.dart';
import '../domain/entities/meditation_entity.dart';

/// Состояние медитации с TTS
class MeditationTTSState {
  final bool isInitialized;
  final bool isPlaying;
  final bool isPaused;
  final MeditationPhase? currentPhase;
  final int currentPhaseIndex;
  final int remainingSeconds;
  final VoiceStyle currentVoiceStyle;
  final double musicVolume;
  final double voiceVolume;
  final String? currentInstruction;

  const MeditationTTSState({
    this.isInitialized = false,
    this.isPlaying = false,
    this.isPaused = false,
    this.currentPhase,
    this.currentPhaseIndex = 0,
    this.remainingSeconds = 0,
    this.currentVoiceStyle = VoiceStyle.calm,
    this.musicVolume = 0.3,
    this.voiceVolume = 0.8,
    this.currentInstruction,
  });

  MeditationTTSState copyWith({
    bool? isInitialized,
    bool? isPlaying,
    bool? isPaused,
    MeditationPhase? currentPhase,
    int? currentPhaseIndex,
    int? remainingSeconds,
    VoiceStyle? currentVoiceStyle,
    double? musicVolume,
    double? voiceVolume,
    String? currentInstruction,
  }) {
    return MeditationTTSState(
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      currentPhase: currentPhase ?? this.currentPhase,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentVoiceStyle: currentVoiceStyle ?? this.currentVoiceStyle,
      musicVolume: musicVolume ?? this.musicVolume,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      currentInstruction: currentInstruction ?? this.currentInstruction,
    );
  }
}

/// Провайдер для управления медитацией с TTS
class MeditationTTSNotifier extends StateNotifier<MeditationTTSState> {
  final TTSService _ttsService;
  final SleepRepository? _sleepRepository;
  final MeditationEntity _meditation;
  Timer? _phaseTimer;
  Timer? _instructionTimer;
  Timer? _countdownTimer;
  List<MeditationPhaseModel> _phases = [];
  int _currentInstructionIndex = 0;
  bool _isDisposed = false;

  MeditationTTSNotifier({
    required TTSService ttsService,
    SleepRepository? sleepRepository,
    required MeditationEntity meditation,
  }) : _ttsService = ttsService,
       _sleepRepository = sleepRepository,
       _meditation = meditation,
       super(const MeditationTTSState());

  /// Инициализация медитации
  Future<void> initialize() async {
    debugPrint('🚀 Начинаю инициализацию медитации с TTS...');

    // Инициализируем TTS
    final ttsAvailable = await _ttsService.initialize();
    if (!ttsAvailable) {
      debugPrint('⚠️ TTS недоступен, медитация будет без голоса');
    } else {
      debugPrint('✅ TTS успешно инициализирован');
    }

    // Анализируем качество сна для выбора стиля голоса
    final voiceStyle = await _analyzeSleepAndSelectVoiceStyle();
    await _ttsService.setVoiceStyle(voiceStyle);

    // Создаем фазы медитации
    _phases = MeditationPhaseModel.createPhases(_meditation.duration);

    // Устанавливаем начальное состояние
    _safeUpdateState(
      (currentState) => currentState.copyWith(
        isInitialized: true,
        currentVoiceStyle: voiceStyle,
        remainingSeconds: _meditation.duration * 60,
      ),
    );
  }

  /// Анализ качества сна и выбор стиля голоса
  Future<VoiceStyle> _analyzeSleepAndSelectVoiceStyle() async {
    if (_sleepRepository == null) {
      debugPrint(
        '⚠️ SleepRepository недоступен, используем стиль по умолчанию',
      );
      return VoiceStyle.calm; // По умолчанию
    }

    try {
      // Получаем последние записи сна (за последние 7 дней)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      final sleepEntries = await _sleepRepository.getSleepEntries(
        startDate,
        endDate,
      );

      if (sleepEntries.isEmpty) {
        return VoiceStyle.calm; // По умолчанию
      }

      // Вычисляем среднее качество сна
      final avgQuality = SleepEntry.getAverageQuality(sleepEntries);
      final avgDuration = SleepEntry.getAverageDuration(sleepEntries);

      // Логика выбора стиля на основе качества сна
      if (avgQuality <= 2.0) {
        // Плохой сон → мягкий успокаивающий голос
        return VoiceStyle.soothing;
      } else if (avgQuality >= 4.0 && avgDuration >= 420) {
        // Хороший сон и достаточная длительность → энергичный направляющий
        return VoiceStyle.energetic;
      } else if (avgQuality >= 3.5) {
        // Хороший сон → направляющий
        return VoiceStyle.guiding;
      } else {
        // Средний сон → спокойный
        return VoiceStyle.calm;
      }
    } catch (e) {
      debugPrint('❌ Ошибка анализа сна: $e');
      return VoiceStyle.calm; // Fallback
    }
  }

  /// Начать медитацию
  Future<void> start() async {
    if (!state.isInitialized) {
      await initialize();
    }

    final totalSeconds = _meditation.duration * 60;
    _safeUpdateState(
      (currentState) => currentState.copyWith(
        isPlaying: true,
        isPaused: false,
        currentPhaseIndex: 0,
        remainingSeconds: totalSeconds,
      ),
    );

    // Запускаем таймер обратного отсчета
    _startCountdownTimer(totalSeconds);

    // Начинаем первую фазу
    await _startPhase(0);
  }

  /// Безопасное обновление состояния
  void _safeUpdateState(
    MeditationTTSState Function(MeditationTTSState) updater,
  ) {
    if (_isDisposed) return;

    // Используем Future.microtask для отложенного обновления,
    // чтобы избежать обновления состояния во время обработки dispose
    Future.microtask(() {
      // Двойная проверка после отложенного выполнения
      if (_isDisposed) return;

      try {
        final newState = updater(state);
        // Еще одна проверка перед фактическим присваиванием
        if (!_isDisposed) {
          state = newState;
        }
      } catch (e) {
        // Виджет уже удален, игнорируем ошибку
        // Не логируем, если провайдер уже удален
      }
    });
  }

  /// Запустить таймер обратного отсчета
  void _startCountdownTimer(int initialSeconds) {
    _countdownTimer?.cancel();
    int remaining = initialSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Проверяем, что провайдер не удален
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      // Проверяем, что состояние все еще активно
      if (!state.isPlaying && !state.isPaused) {
        timer.cancel();
        return;
      }

      if (state.isPaused) {
        return; // Не уменьшаем время на паузе
      }

      remaining--;

      // Безопасное обновление состояния
      if (remaining >= 0) {
        _safeUpdateState(
          (currentState) => currentState.copyWith(remainingSeconds: remaining),
        );
      }

      if (remaining <= 0) {
        timer.cancel();
        // Медитация завершена
        if (!_isDisposed) {
          Future.microtask(() {
            if (!_isDisposed) {
              stop();
            }
          });
        }
      }
    });
  }

  /// Начать фазу
  Future<void> _startPhase(int phaseIndex) async {
    if (phaseIndex >= _phases.length) {
      // Медитация завершена
      await stop();
      return;
    }

    final phase = _phases[phaseIndex];
    _safeUpdateState(
      (currentState) => currentState.copyWith(
        currentPhase: phase.phase,
        currentPhaseIndex: phaseIndex,
      ),
    );

    // Получаем инструкции для фазы (уже локализованные)
    final instructions = phase.getInstructions();
    _currentInstructionIndex = 0;

    // Произносим первую инструкцию
    if (instructions.isNotEmpty) {
      final firstInstruction = instructions[0];
      debugPrint('📝 Инструкции для фазы ${phase.phase}: $instructions');
      debugPrint('📝 Первая инструкция (текст): "$firstInstruction"');

      // Проверяем, что инструкция переведена (не является ключом локализации)
      String instructionToSpeak = firstInstruction;
      if (firstInstruction.startsWith('meditation.phase.')) {
        debugPrint(
          '⚠️ Инструкция не переведена (ключ локализации), используем fallback',
        );
        final fallbackInstructions = phase.getFallbackInstructions();
        if (fallbackInstructions.isNotEmpty) {
          instructionToSpeak = fallbackInstructions[0];
          debugPrint(
            '📝 Используем fallback инструкцию: "$instructionToSpeak"',
          );
        } else {
          debugPrint('❌ Fallback инструкции недоступны');
          return;
        }
      }

      // Обновляем состояние с правильной инструкцией
      _safeUpdateState(
        (currentState) =>
            currentState.copyWith(currentInstruction: instructionToSpeak),
      );

      // Пробуем произнести инструкцию
      debugPrint('✅ Пробуем произнести инструкцию: "$instructionToSpeak"');
      try {
        await _ttsService.speak(instructionToSpeak);
      } catch (e) {
        debugPrint(
          '⚠️ Ошибка произнесения (MissingPluginException - нужна пересборка): $e',
        );
        debugPrint(
          '⚠️ Выполните: flutter clean && flutter pub get && полная пересборка приложения',
        );
        // Продолжаем работу даже если TTS не работает - показываем только текст
      }
    } else {
      debugPrint('⚠️ Нет инструкций для фазы ${phase.phase}');
    }

    // Запускаем таймер для смены инструкций
    _instructionTimer?.cancel();
    _instructionTimer = Timer.periodic(const Duration(seconds: 15), (
      timer,
    ) async {
      // Проверяем, что провайдер не удален
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      // Проверяем, что медитация все еще активна
      if (!state.isPlaying && !state.isPaused) {
        timer.cancel();
        return;
      }

      if (_currentInstructionIndex < instructions.length - 1) {
        _currentInstructionIndex++;

        if (_isDisposed) {
          timer.cancel();
          return;
        }

        try {
          String instruction = instructions[_currentInstructionIndex];

          // Проверяем, что инструкция переведена
          if (instruction.startsWith('meditation.phase.')) {
            debugPrint('⚠️ Инструкция не переведена, используем fallback');
            final fallbackInstructions = phase.getFallbackInstructions();
            if (_currentInstructionIndex < fallbackInstructions.length) {
              instruction = fallbackInstructions[_currentInstructionIndex];
            }
          }

          _safeUpdateState(
            (currentState) =>
                currentState.copyWith(currentInstruction: instruction),
          );

          // Пробуем произнести инструкцию
          try {
            debugPrint('🗣️ Произношу следующую инструкцию: "$instruction"');
            await _ttsService.speak(instruction);
          } catch (e) {
            debugPrint('⚠️ Ошибка произнесения инструкции: $e');
            // Продолжаем работу даже если TTS не работает
          }
        } catch (e) {
          debugPrint('⚠️ Ошибка обновления инструкции (виджет удален): $e');
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });

    // Запускаем таймер для перехода к следующей фазе
    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: phase.durationSeconds), () async {
      // Проверяем, что провайдер не удален
      if (_isDisposed) {
        return;
      }

      // Проверяем, что медитация все еще активна
      if (state.isPlaying || state.isPaused) {
        try {
          if (!_isDisposed) {
            await _startPhase(phaseIndex + 1);
          }
        } catch (e) {
          debugPrint('⚠️ Ошибка перехода к следующей фазе (виджет удален): $e');
        }
      }
    });
  }

  /// Пауза медитации
  Future<void> pause() async {
    _phaseTimer?.cancel();
    _instructionTimer?.cancel();
    await _ttsService.pause();
    // Таймер обратного отсчета продолжит работать, но не будет уменьшать время

    _safeUpdateState(
      (currentState) => currentState.copyWith(isPlaying: false, isPaused: true),
    );
  }

  /// Возобновить медитацию
  Future<void> resume() async {
    await _ttsService.speak(state.currentInstruction ?? '');
    await _startPhase(state.currentPhaseIndex);

    _safeUpdateState(
      (currentState) => currentState.copyWith(isPlaying: true, isPaused: false),
    );
  }

  /// Остановить медитацию
  Future<void> stop() async {
    _phaseTimer?.cancel();
    _instructionTimer?.cancel();
    _countdownTimer?.cancel();
    await _ttsService.stop();

    _safeUpdateState(
      (currentState) => currentState.copyWith(
        isPlaying: false,
        isPaused: false,
        currentPhase: null,
        currentPhaseIndex: 0,
        remainingSeconds: _meditation.duration * 60,
        currentInstruction: null,
      ),
    );
  }

  /// Установить громкость музыки
  Future<void> setMusicVolume(double volume) async {
    _safeUpdateState(
      (currentState) =>
          currentState.copyWith(musicVolume: volume.clamp(0.0, 1.0)),
    );
  }

  /// Установить громкость голоса
  Future<void> setVoiceVolume(double volume) async {
    _safeUpdateState(
      (currentState) =>
          currentState.copyWith(voiceVolume: volume.clamp(0.0, 1.0)),
    );
    await _ttsService.setVolume(volume);
  }

  /// Установить стиль голоса
  Future<void> setVoiceStyle(VoiceStyle style) async {
    await _ttsService.setVoiceStyle(style);
    _safeUpdateState(
      (currentState) => currentState.copyWith(currentVoiceStyle: style),
    );
  }

  @override
  void dispose() {
    // Сначала отменяем все таймеры
    _phaseTimer?.cancel();
    _instructionTimer?.cancel();
    _countdownTimer?.cancel();

    // Останавливаем TTS
    try {
      _ttsService.stop();
    } catch (e) {
      // Игнорируем ошибки при остановке TTS
    }

    // Устанавливаем флаг disposed только после отмены таймеров
    _isDisposed = true;

    super.dispose();
  }
}

/// Провайдер для создания MeditationTTSNotifier
final meditationTTSProvider =
    StateNotifierProvider.family<
      MeditationTTSNotifier,
      MeditationTTSState,
      MeditationEntity
    >((ref, meditation) {
      final ttsService = TTSService();
      final sleepRepository = SleepRepositoryImpl(
        database: ref.read(appDatabaseProvider),
        groqClient: GroqClient(),
      );

      return MeditationTTSNotifier(
        ttsService: ttsService,
        sleepRepository: sleepRepository,
        meditation: meditation,
      );
    });
