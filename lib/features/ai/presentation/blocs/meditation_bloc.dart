import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/meditation_entity.dart';
import '../../domain/usecases/suggest_meditation_usecase.dart';

/// События для Meditation Bloc
abstract class MeditationEvent {}

class LoadMeditationSession extends MeditationEvent {
  final List<MoodEntry> recentMoods;
  final MeditationType? type;

  LoadMeditationSession(this.recentMoods, {this.type});
}

class RefreshMeditationSession extends MeditationEvent {
  final List<MoodEntry> recentMoods;
  final MeditationType? type;

  RefreshMeditationSession(this.recentMoods, {this.type});
}

class LoadMeditationForTimeOfDay extends MeditationEvent {
  final List<MoodEntry> recentMoods;

  LoadMeditationForTimeOfDay(this.recentMoods);
}

class LoadMeditationForCurrentMood extends MeditationEvent {
  final List<MoodEntry> recentMoods;

  LoadMeditationForCurrentMood(this.recentMoods);
}

class LoadShortMeditationSession extends MeditationEvent {
  final List<MoodEntry> recentMoods;

  LoadShortMeditationSession(this.recentMoods);
}

class LoadLongMeditationSession extends MeditationEvent {
  final List<MoodEntry> recentMoods;

  LoadLongMeditationSession(this.recentMoods);
}

class ClearMeditationCache extends MeditationEvent {}

/// Состояния для Meditation Bloc
abstract class MeditationState {}

class MeditationInitial extends MeditationState {}

class MeditationLoading extends MeditationState {}

class MeditationLoaded extends MeditationState {
  final MeditationEntity meditation;
  final DateTime loadedAt;

  MeditationLoaded(this.meditation, this.loadedAt);
}

class MeditationError extends MeditationState {
  final String message;
  final String? suggestion;

  MeditationError(this.message, {this.suggestion});
}

class MeditationCached extends MeditationState {
  final MeditationEntity meditation;
  final DateTime cachedAt;

  MeditationCached(this.meditation, this.cachedAt);
}

/// Bloc для управления состоянием медитационных сессий
class MeditationBloc extends Bloc<MeditationEvent, MeditationState> {
  final SuggestMeditationUseCase _suggestMeditationUseCase;

  MeditationBloc(this._suggestMeditationUseCase) : super(MeditationInitial()) {
    on<LoadMeditationSession>(_onLoadMeditationSession);
    on<RefreshMeditationSession>(_onRefreshMeditationSession);
    on<LoadMeditationForTimeOfDay>(_onLoadMeditationForTimeOfDay);
    on<LoadMeditationForCurrentMood>(_onLoadMeditationForCurrentMood);
    on<LoadShortMeditationSession>(_onLoadShortMeditationSession);
    on<LoadLongMeditationSession>(_onLoadLongMeditationSession);
    on<ClearMeditationCache>(_onClearCache);
  }

  /// Загрузка медитационной сессии
  Future<void> _onLoadMeditationSession(
    LoadMeditationSession event,
    Emitter<MeditationState> emit,
  ) async {
    try {
      emit(MeditationLoading());

      MeditationEntity meditation;

      if (event.type != null) {
        meditation = await _suggestMeditationUseCase.callForType(
          event.recentMoods,
          event.type!,
        );
      } else {
        meditation = await _suggestMeditationUseCase.call(event.recentMoods);
      }

      emit(MeditationLoaded(meditation, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки медитационной сессии: $e');
      // Use case должен вернуть fallback медитацию, но если этого не произошло,
      // пытаемся создать базовую медитацию напрямую
      try {
        final fallbackMeditation = await _suggestMeditationUseCase.call(
          event.recentMoods,
        );
        print('✅ Используем fallback медитацию');
        emit(MeditationLoaded(fallbackMeditation, DateTime.now()));
      } catch (fallbackError) {
        print('❌ Fallback медитация также не сработала: $fallbackError');
        // Даже если все не сработало, создаем базовую медитацию синхронно
        // чтобы пользователь всегда видел медитацию
        final basicMeditation = _createBasicMeditation(event.recentMoods);
        emit(MeditationLoaded(basicMeditation, DateTime.now()));
      }
    }
  }

  /// Создание базовой медитации при полном сбое
  MeditationEntity _createBasicMeditation(List<MoodEntry> recentMoods) {
    final hour = DateTime.now().hour;
    final averageMood = recentMoods.isNotEmpty
        ? recentMoods.map((e) => e.moodValue).reduce((a, b) => a + b) /
              recentMoods.length
        : 3.0;

    String title;
    String description;
    MeditationType type;
    int duration;

    if (hour >= 6 && hour < 12) {
      title = 'Утренняя медитация';
      description = 'Начните день с осознанности и намерений';
      type = MeditationType.mindfulness;
      duration = 10;
    } else if (hour >= 12 && hour < 18) {
      title = 'Дневная пауза';
      description = 'Восстановите энергию в середине дня';
      type = MeditationType.breathing;
      duration = 8;
    } else if (hour >= 18 && hour < 22) {
      title = 'Вечерняя релаксация';
      description = 'Расслабьтесь после активного дня';
      type = MeditationType.progressiveRelaxation;
      duration = 15;
    } else {
      title = 'Медитация перед сном';
      description = 'Подготовьтесь к спокойному сну';
      type = MeditationType.bodyScan;
      duration = 12;
    }

    // Адаптируем под настроение
    if (averageMood <= 2) {
      title = 'Исцеляющая медитация';
      description = 'Поможет справиться с трудными эмоциями';
      type = MeditationType.lovingKindness;
      duration = 15;
    } else if (averageMood >= 4) {
      title = 'Медитация благодарности';
      description = 'Углубите чувство радости и благодарности';
      type = MeditationType.mindfulness;
      duration = 10;
    }

    return MeditationEntity(
      title: title,
      description: description,
      emoji: '🧘',
      accentColor: const Color(0xFF6366F1),
      type: type,
      duration: duration,
      instructions: [
        'Сядьте удобно и закройте глаза',
        'Сосредоточьтесь на дыхании',
        'Наблюдайте за мыслями без суждения',
        'Верните внимание к дыханию, если отвлеклись',
        'Медленно откройте глаза и вернитесь в настоящий момент',
      ],
      tips: [
        'Начните с 5 минут и постепенно увеличивайте время',
        'Не расстраивайтесь, если мысли отвлекают - это нормально',
        'Практикуйте регулярно для лучших результатов',
      ],
      createdAt: DateTime.now(),
      difficulty: MeditationDifficulty.beginner,
    );
  }

  /// Обновление медитационной сессии
  Future<void> _onRefreshMeditationSession(
    RefreshMeditationSession event,
    Emitter<MeditationState> emit,
  ) async {
    try {
      emit(MeditationLoading());

      MeditationEntity meditation;

      if (event.type != null) {
        meditation = await _suggestMeditationUseCase.callForType(
          event.recentMoods,
          event.type!,
        );
      } else {
        meditation = await _suggestMeditationUseCase.call(event.recentMoods);
      }

      emit(MeditationLoaded(meditation, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка обновления медитации: $e');

      emit(
        MeditationError(
          'Не удалось обновить медитационную сессию: ${e.toString()}',
          suggestion: 'Попробуйте позже',
        ),
      );
    }
  }

  /// Загрузка медитации для времени дня
  Future<void> _onLoadMeditationForTimeOfDay(
    LoadMeditationForTimeOfDay event,
    Emitter<MeditationState> emit,
  ) async {
    try {
      emit(MeditationLoading());

      final meditation = await _suggestMeditationUseCase.callForTimeOfDay(
        event.recentMoods,
      );

      emit(MeditationLoaded(meditation, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки медитации для времени дня: $e');

      emit(
        MeditationError(
          'Не удалось загрузить медитацию: ${e.toString()}',
          suggestion: 'Попробуйте позже',
        ),
      );
    }
  }

  /// Загрузка медитации для текущего настроения
  Future<void> _onLoadMeditationForCurrentMood(
    LoadMeditationForCurrentMood event,
    Emitter<MeditationState> emit,
  ) async {
    try {
      emit(MeditationLoading());

      final meditation = await _suggestMeditationUseCase.callForCurrentMood(
        event.recentMoods,
      );

      emit(MeditationLoaded(meditation, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки медитации для настроения: $e');

      emit(
        MeditationError(
          'Не удалось загрузить медитацию для настроения: ${e.toString()}',
          suggestion: 'Попробуйте позже',
        ),
      );
    }
  }

  /// Загрузка короткой медитационной сессии
  Future<void> _onLoadShortMeditationSession(
    LoadShortMeditationSession event,
    Emitter<MeditationState> emit,
  ) async {
    try {
      emit(MeditationLoading());

      final meditation = await _suggestMeditationUseCase.callShortSession(
        event.recentMoods,
      );

      emit(MeditationLoaded(meditation, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки короткой медитации: $e');

      emit(
        MeditationError(
          'Не удалось загрузить короткую медитацию: ${e.toString()}',
          suggestion: 'Попробуйте позже',
        ),
      );
    }
  }

  /// Загрузка длинной медитационной сессии
  Future<void> _onLoadLongMeditationSession(
    LoadLongMeditationSession event,
    Emitter<MeditationState> emit,
  ) async {
    try {
      emit(MeditationLoading());

      final meditation = await _suggestMeditationUseCase.callLongSession(
        event.recentMoods,
      );

      emit(MeditationLoaded(meditation, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки длинной медитации: $e');

      emit(
        MeditationError(
          'Не удалось загрузить длинную медитацию: ${e.toString()}',
          suggestion: 'Попробуйте позже',
        ),
      );
    }
  }

  /// Очистка кэша
  Future<void> _onClearCache(
    ClearMeditationCache event,
    Emitter<MeditationState> emit,
  ) async {
    try {
      print('🗑️ Кэш медитаций очищен');
      emit(MeditationInitial());
    } catch (e) {
      print('❌ Ошибка очистки кэша: $e');
      emit(MeditationError('Не удалось очистить кэш'));
    }
  }

  /// Загрузка медитации с кэшированием (используйте событие LoadMeditationSession)
  @Deprecated('Используйте событие LoadMeditationSession')
  Future<void> loadSessionWithCache(List<MoodEntry> recentMoods) async {
    add(LoadMeditationSession(recentMoods));
  }

  /// Загрузка медитации для типа (используйте событие LoadMeditationSession с type)
  @Deprecated('Используйте событие LoadMeditationSession с type')
  Future<void> loadSessionForType(
    List<MoodEntry> recentMoods,
    MeditationType type,
  ) async {
    add(LoadMeditationSession(recentMoods, type: type));
  }

  /// Проверка, является ли текущее состояние загруженным
  bool get isLoaded => state is MeditationLoaded;

  /// Получение текущей медитации
  MeditationEntity? get currentMeditation {
    if (state is MeditationLoaded) {
      return (state as MeditationLoaded).meditation;
    }
    return null;
  }

  /// Проверка, является ли текущее состояние ошибочным
  bool get hasError => state is MeditationError;

  /// Получение сообщения об ошибке
  String? get errorMessage {
    if (state is MeditationError) {
      return (state as MeditationError).message;
    }
    return null;
  }

  /// Проверка, подходит ли медитация для новичков
  bool get isBeginnerFriendly {
    final meditation = currentMeditation;
    return meditation?.isBeginnerFriendly == true;
  }

  /// Получение длительности медитации
  String get durationFormatted {
    final meditation = currentMeditation;
    return meditation?.durationFormatted ?? '10 мин';
  }

  /// Проверка, является ли медитация короткой
  bool get isShortSession {
    final meditation = currentMeditation;
    return meditation?.isShortSession == true;
  }

  /// Проверка, является ли медитация длинной
  bool get isLongSession {
    final meditation = currentMeditation;
    return meditation?.isLongSession == true;
  }
}
