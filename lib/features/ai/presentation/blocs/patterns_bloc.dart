import 'package:bloc/bloc.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/mood_pattern_entity.dart';
import '../../domain/usecases/analyze_mood_patterns_usecase.dart';

/// События для Patterns Bloc
abstract class PatternsEvent {}

class LoadPatternAnalysis extends PatternsEvent {
  final List<MoodEntry> moodHistory;
  final int? days;

  LoadPatternAnalysis(this.moodHistory, {this.days});
}

class RefreshPatternAnalysis extends PatternsEvent {
  final List<MoodEntry> moodHistory;
  final int? days;

  RefreshPatternAnalysis(this.moodHistory, {this.days});
}

class QuickPatternAnalysis extends PatternsEvent {
  final List<MoodEntry> moodHistory;

  QuickPatternAnalysis(this.moodHistory);
}

class ClearPatternsCache extends PatternsEvent {}

/// Состояния для Patterns Bloc
abstract class PatternsState {}

class PatternsInitial extends PatternsState {}

class PatternsLoading extends PatternsState {}

class PatternsLoaded extends PatternsState {
  final MoodPatternEntity patterns;
  final DateTime analyzedAt;

  PatternsLoaded(this.patterns, this.analyzedAt);
}

class PatternsError extends PatternsState {
  final String message;
  final String? suggestion;

  PatternsError(this.message, {this.suggestion});
}

class PatternsCached extends PatternsState {
  final MoodPatternEntity patterns;
  final DateTime cachedAt;

  PatternsCached(this.patterns, this.cachedAt);
}

/// Bloc для управления состоянием анализа паттернов
class PatternsBloc extends Bloc<PatternsEvent, PatternsState> {
  final AnalyzeMoodPatternsUseCase _analyzeMoodPatternsUseCase;

  PatternsBloc(this._analyzeMoodPatternsUseCase) : super(PatternsInitial()) {
    on<LoadPatternAnalysis>(_onLoadPatternAnalysis);
    on<RefreshPatternAnalysis>(_onRefreshPatternAnalysis);
    on<QuickPatternAnalysis>(_onQuickPatternAnalysis);
    on<ClearPatternsCache>(_onClearCache);
  }

  /// Загрузка анализа паттернов
  Future<void> _onLoadPatternAnalysis(
    LoadPatternAnalysis event,
    Emitter<PatternsState> emit,
  ) async {
    try {
      emit(PatternsLoading());

      MoodPatternEntity patterns;

      if (event.days != null) {
        patterns = await _analyzeMoodPatternsUseCase.callForRecentDays(
          event.moodHistory,
          event.days!,
        );
      } else {
        patterns = await _analyzeMoodPatternsUseCase.call(event.moodHistory);
      }

      emit(PatternsLoaded(patterns, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка анализа паттернов: $e');

      String suggestion;
      if (e.toString().contains('No mood history')) {
        suggestion = 'Добавьте больше записей настроения для анализа паттернов';
      } else if (e.toString().contains('Insufficient data')) {
        suggestion = 'Нужно минимум 7 записей для анализа паттернов';
      } else {
        suggestion = 'Попробуйте обновить данные или обратитесь в поддержку';
      }

      emit(
        PatternsError(
          'Не удалось проанализировать паттерны: ${e.toString()}',
          suggestion: suggestion,
        ),
      );
    }
  }

  /// Обновление анализа паттернов
  Future<void> _onRefreshPatternAnalysis(
    RefreshPatternAnalysis event,
    Emitter<PatternsState> emit,
  ) async {
    try {
      emit(PatternsLoading());

      MoodPatternEntity patterns;

      if (event.days != null) {
        patterns = await _analyzeMoodPatternsUseCase.callForRecentDays(
          event.moodHistory,
          event.days!,
        );
      } else {
        patterns = await _analyzeMoodPatternsUseCase.call(event.moodHistory);
      }

      emit(PatternsLoaded(patterns, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка обновления анализа: $e');

      emit(
        PatternsError(
          'Не удалось обновить анализ паттернов: ${e.toString()}',
          suggestion: 'Попробуйте позже',
        ),
      );
    }
  }

  /// Быстрый анализ паттернов
  Future<void> _onQuickPatternAnalysis(
    QuickPatternAnalysis event,
    Emitter<PatternsState> emit,
  ) async {
    try {
      emit(PatternsLoading());

      final patterns = await _analyzeMoodPatternsUseCase.quickAnalysis(
        event.moodHistory,
      );

      emit(PatternsLoaded(patterns, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка быстрого анализа: $e');

      emit(
        PatternsError(
          'Не удалось выполнить быстрый анализ: ${e.toString()}',
          suggestion: 'Нужно минимум 3 записи для быстрого анализа',
        ),
      );
    }
  }

  /// Очистка кэша
  Future<void> _onClearCache(
    ClearPatternsCache event,
    Emitter<PatternsState> emit,
  ) async {
    try {
      print('🗑️ Кэш паттернов очищен');
      emit(PatternsInitial());
    } catch (e) {
      print('❌ Ошибка очистки кэша: $e');
      emit(PatternsError('Не удалось очистить кэш'));
    }
  }

  /// Загрузка анализа с кэшированием
  Future<void> loadAnalysisWithCache(List<MoodEntry> moodHistory) async {
    try {
      emit(PatternsLoading());

      final patterns = await _analyzeMoodPatternsUseCase.callWithCache(
        moodHistory,
      );
      emit(PatternsLoaded(patterns, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки с кэшем: $e');
      emit(
        PatternsError('Не удалось загрузить анализ с кэшем: ${e.toString()}'),
      );
    }
  }

  /// Анализ для конкретного периода
  Future<void> analyzeForPeriod(
    List<MoodEntry> allMoods,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      emit(PatternsLoading());

      final patterns = await _analyzeMoodPatternsUseCase.callForPeriod(
        allMoods,
        startDate,
        endDate,
      );

      emit(PatternsLoaded(patterns, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка анализа для периода: $e');
      emit(PatternsError('Не удалось проанализировать паттерны для периода'));
    }
  }

  /// Проверка, является ли текущее состояние загруженным
  bool get isLoaded => state is PatternsLoaded;

  /// Получение текущих паттернов
  MoodPatternEntity? get currentPatterns {
    if (state is PatternsLoaded) {
      return (state as PatternsLoaded).patterns;
    }
    return null;
  }

  /// Проверка, является ли текущее состояние ошибочным
  bool get hasError => state is PatternsError;

  /// Получение сообщения об ошибке
  String? get errorMessage {
    if (state is PatternsError) {
      return (state as PatternsError).message;
    }
    return null;
  }

  /// Проверка, достаточно ли данных для анализа
  bool canAnalyze(List<MoodEntry> moodHistory) {
    return moodHistory.length >= 3;
  }

  /// Проверка, можно ли выполнить полный анализ
  bool canPerformFullAnalysis(List<MoodEntry> moodHistory) {
    return moodHistory.length >= 7;
  }
}

