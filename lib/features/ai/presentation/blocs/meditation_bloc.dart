import 'package:bloc/bloc.dart';

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

      String suggestion;
      if (e.toString().contains('No mood data')) {
        suggestion =
            'Добавьте записи настроения для персонализированных медитаций';
      } else {
        suggestion = 'Попробуйте обновить данные или обратитесь в поддержку';
      }

      emit(
        MeditationError(
          'Не удалось загрузить медитационную сессию: ${e.toString()}',
          suggestion: suggestion,
        ),
      );
    }
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

  /// Загрузка медитации с кэшированием
  Future<void> loadSessionWithCache(List<MoodEntry> recentMoods) async {
    try {
      emit(MeditationLoading());

      final meditation = await _suggestMeditationUseCase.callWithCache(
        recentMoods,
      );
      emit(MeditationLoaded(meditation, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки с кэшем: $e');
      emit(
        MeditationError(
          'Не удалось загрузить медитацию с кэшем: ${e.toString()}',
        ),
      );
    }
  }

  /// Загрузка медитации для типа
  Future<void> loadSessionForType(
    List<MoodEntry> recentMoods,
    MeditationType type,
  ) async {
    try {
      emit(MeditationLoading());

      final meditation = await _suggestMeditationUseCase.callForType(
        recentMoods,
        type,
      );

      emit(MeditationLoaded(meditation, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки для типа: $e');
      emit(MeditationError('Не удалось загрузить медитацию для типа'));
    }
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

