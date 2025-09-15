import 'package:bloc/bloc.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/ai_insight_entity.dart';
import '../../domain/usecases/get_ai_insights_usecase.dart';

/// События для AI Insights Bloc
abstract class AIInsightsEvent {}

class LoadAIInsights extends AIInsightsEvent {
  final List<MoodEntry> recentMoods;
  final int? days;

  LoadAIInsights(this.recentMoods, {this.days});
}

class RefreshAIInsights extends AIInsightsEvent {
  final List<MoodEntry> recentMoods;
  final int? days;

  RefreshAIInsights(this.recentMoods, {this.days});
}

class ClearAIInsightsCache extends AIInsightsEvent {}

/// Состояния для AI Insights Bloc
abstract class AIInsightsState {}

class AIInsightsInitial extends AIInsightsState {}

class AIInsightsLoading extends AIInsightsState {}

class AIInsightsLoaded extends AIInsightsState {
  final AIInsightEntity insight;
  final DateTime loadedAt;

  AIInsightsLoaded(this.insight, this.loadedAt);
}

class AIInsightsError extends AIInsightsState {
  final String message;
  final String? suggestion;

  AIInsightsError(this.message, {this.suggestion});
}

class AIInsightsCached extends AIInsightsState {
  final AIInsightEntity insight;
  final DateTime cachedAt;

  AIInsightsCached(this.insight, this.cachedAt);
}

/// Bloc для управления состоянием AI инсайтов
class AIInsightsBloc extends Bloc<AIInsightsEvent, AIInsightsState> {
  final GetAIInsightsUseCase _getAIInsightsUseCase;

  AIInsightsBloc(this._getAIInsightsUseCase) : super(AIInsightsInitial()) {
    on<LoadAIInsights>(_onLoadAIInsights);
    on<RefreshAIInsights>(_onRefreshAIInsights);
    on<ClearAIInsightsCache>(_onClearCache);
  }

  /// Загрузка AI инсайтов
  Future<void> _onLoadAIInsights(
    LoadAIInsights event,
    Emitter<AIInsightsState> emit,
  ) async {
    try {
      emit(AIInsightsLoading());

      AIInsightEntity insight;

      if (event.days != null) {
        // Загрузка для конкретного периода
        insight = await _getAIInsightsUseCase.callForRecentDays(
          event.recentMoods,
          event.days!,
        );
      } else {
        // Загрузка всех данных
        insight = await _getAIInsightsUseCase.call(event.recentMoods);
      }

      emit(AIInsightsLoaded(insight, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки AI инсайтов: $e');

      String suggestion;
      if (e.toString().contains('No mood entries')) {
        suggestion =
            'Добавьте несколько записей настроения для получения инсайтов';
      } else if (e.toString().contains('Failed to get AI insights')) {
        suggestion = 'Проверьте подключение к интернету и попробуйте позже';
      } else {
        suggestion = 'Попробуйте обновить данные';
      }

      emit(
        AIInsightsError(
          'Не удалось загрузить AI инсайты: ${e.toString()}',
          suggestion: suggestion,
        ),
      );
    }
  }

  /// Обновление AI инсайтов
  Future<void> _onRefreshAIInsights(
    RefreshAIInsights event,
    Emitter<AIInsightsState> emit,
  ) async {
    try {
      // Сначала показываем загрузку
      emit(AIInsightsLoading());

      AIInsightEntity insight;

      if (event.days != null) {
        insight = await _getAIInsightsUseCase.callForRecentDays(
          event.recentMoods,
          event.days!,
        );
      } else {
        insight = await _getAIInsightsUseCase.call(event.recentMoods);
      }

      emit(AIInsightsLoaded(insight, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка обновления AI инсайтов: $e');

      emit(
        AIInsightsError(
          'Не удалось обновить AI инсайты: ${e.toString()}',
          suggestion: 'Попробуйте позже или обратитесь в поддержку',
        ),
      );
    }
  }

  /// Очистка кэша
  Future<void> _onClearCache(
    ClearAIInsightsCache event,
    Emitter<AIInsightsState> emit,
  ) async {
    try {
      // Здесь можно добавить логику очистки кэша
      print('🗑️ Кэш AI инсайтов очищен');

      // Возвращаемся к начальному состоянию
      emit(AIInsightsInitial());
    } catch (e) {
      print('❌ Ошибка очистки кэша: $e');
      emit(AIInsightsError('Не удалось очистить кэш'));
    }
  }

  /// Загрузка инсайтов с кэшированием
  Future<void> loadInsightsWithCache(List<MoodEntry> recentMoods) async {
    try {
      emit(AIInsightsLoading());

      final insight = await _getAIInsightsUseCase.callWithCache(recentMoods);
      emit(AIInsightsLoaded(insight, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки с кэшем: $e');
      emit(AIInsightsError('Не удалось загрузить инсайты: ${e.toString()}'));
    }
  }

  /// Загрузка инсайтов для периода
  Future<void> loadInsightsForPeriod(
    List<MoodEntry> allMoods,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      emit(AIInsightsLoading());

      final insight = await _getAIInsightsUseCase.callForPeriod(
        allMoods,
        startDate,
        endDate,
      );

      emit(AIInsightsLoaded(insight, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки для периода: $e');
      emit(AIInsightsError('Не удалось загрузить инсайты для периода'));
    }
  }

  /// Проверка, является ли текущее состояние загруженным
  bool get isLoaded => state is AIInsightsLoaded;

  /// Получение текущего инсайта
  AIInsightEntity? get currentInsight {
    if (state is AIInsightsLoaded) {
      return (state as AIInsightsLoaded).insight;
    }
    return null;
  }

  /// Проверка, является ли текущее состояние ошибочным
  bool get hasError => state is AIInsightsError;

  /// Получение сообщения об ошибке
  String? get errorMessage {
    if (state is AIInsightsError) {
      return (state as AIInsightsError).message;
    }
    return null;
  }
}

