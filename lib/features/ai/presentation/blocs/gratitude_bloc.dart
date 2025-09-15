import 'package:bloc/bloc.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/gratitude_entity.dart';
import '../../domain/usecases/generate_gratitude_prompts_usecase.dart';

/// События для Gratitude Bloc
abstract class GratitudeEvent {}

class LoadGratitudePrompts extends GratitudeEvent {
  final List<MoodEntry> recentMoods;
  final GratitudeCategory? category;

  LoadGratitudePrompts(this.recentMoods, {this.category});
}

class RefreshGratitudePrompts extends GratitudeEvent {
  final List<MoodEntry> recentMoods;
  final GratitudeCategory? category;

  RefreshGratitudePrompts(this.recentMoods, {this.category});
}

class LoadGratitudeForCurrentMood extends GratitudeEvent {
  final List<MoodEntry> recentMoods;

  LoadGratitudeForCurrentMood(this.recentMoods);
}

class LoadRandomGratitude extends GratitudeEvent {
  final List<MoodEntry> recentMoods;

  LoadRandomGratitude(this.recentMoods);
}

class ClearGratitudeCache extends GratitudeEvent {}

/// Состояния для Gratitude Bloc
abstract class GratitudeState {}

class GratitudeInitial extends GratitudeState {}

class GratitudeLoading extends GratitudeState {}

class GratitudeLoaded extends GratitudeState {
  final GratitudeEntity gratitude;
  final DateTime loadedAt;

  GratitudeLoaded(this.gratitude, this.loadedAt);
}

class GratitudeError extends GratitudeState {
  final String message;
  final String? suggestion;

  GratitudeError(this.message, {this.suggestion});
}

class GratitudeCached extends GratitudeState {
  final GratitudeEntity gratitude;
  final DateTime cachedAt;

  GratitudeCached(this.gratitude, this.cachedAt);
}

/// Bloc для управления состоянием благодарственных предложений
class GratitudeBloc extends Bloc<GratitudeEvent, GratitudeState> {
  final GenerateGratitudePromptsUseCase _generateGratitudePromptsUseCase;

  GratitudeBloc(this._generateGratitudePromptsUseCase)
    : super(GratitudeInitial()) {
    on<LoadGratitudePrompts>(_onLoadGratitudePrompts);
    on<RefreshGratitudePrompts>(_onRefreshGratitudePrompts);
    on<LoadGratitudeForCurrentMood>(_onLoadGratitudeForCurrentMood);
    on<LoadRandomGratitude>(_onLoadRandomGratitude);
    on<ClearGratitudeCache>(_onClearCache);
  }

  /// Загрузка благодарственных предложений
  Future<void> _onLoadGratitudePrompts(
    LoadGratitudePrompts event,
    Emitter<GratitudeState> emit,
  ) async {
    try {
      emit(GratitudeLoading());

      GratitudeEntity gratitude;

      if (event.category != null) {
        gratitude = await _generateGratitudePromptsUseCase.callForCategory(
          event.recentMoods,
          event.category!,
        );
      } else {
        gratitude = await _generateGratitudePromptsUseCase.call(
          event.recentMoods,
        );
      }

      emit(GratitudeLoaded(gratitude, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки благодарственных предложений: $e');

      String suggestion;
      if (e.toString().contains('No mood data')) {
        suggestion =
            'Добавьте записи настроения для персонализированных предложений';
      } else {
        suggestion = 'Попробуйте обновить данные или обратитесь в поддержку';
      }

      emit(
        GratitudeError(
          'Не удалось загрузить благодарственные предложения: ${e.toString()}',
          suggestion: suggestion,
        ),
      );
    }
  }

  /// Обновление благодарственных предложений
  Future<void> _onRefreshGratitudePrompts(
    RefreshGratitudePrompts event,
    Emitter<GratitudeState> emit,
  ) async {
    try {
      emit(GratitudeLoading());

      GratitudeEntity gratitude;

      if (event.category != null) {
        gratitude = await _generateGratitudePromptsUseCase.callForCategory(
          event.recentMoods,
          event.category!,
        );
      } else {
        gratitude = await _generateGratitudePromptsUseCase.call(
          event.recentMoods,
        );
      }

      emit(GratitudeLoaded(gratitude, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка обновления предложений: $e');

      emit(
        GratitudeError(
          'Не удалось обновить благодарственные предложения: ${e.toString()}',
          suggestion: 'Попробуйте позже',
        ),
      );
    }
  }

  /// Загрузка благодарности для текущего настроения
  Future<void> _onLoadGratitudeForCurrentMood(
    LoadGratitudeForCurrentMood event,
    Emitter<GratitudeState> emit,
  ) async {
    try {
      emit(GratitudeLoading());

      final gratitude = await _generateGratitudePromptsUseCase
          .callForCurrentMood(event.recentMoods);

      emit(GratitudeLoaded(gratitude, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки для текущего настроения: $e');

      emit(
        GratitudeError(
          'Не удалось загрузить благодарственные предложения: ${e.toString()}',
          suggestion: 'Проверьте подключение к интернету',
        ),
      );
    }
  }

  /// Загрузка случайных благодарственных предложений
  Future<void> _onLoadRandomGratitude(
    LoadRandomGratitude event,
    Emitter<GratitudeState> emit,
  ) async {
    try {
      emit(GratitudeLoading());

      final gratitude = await _generateGratitudePromptsUseCase.callRandom(
        event.recentMoods,
      );

      emit(GratitudeLoaded(gratitude, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки случайных предложений: $e');

      emit(
        GratitudeError(
          'Не удалось загрузить случайные предложения: ${e.toString()}',
          suggestion: 'Попробуйте позже',
        ),
      );
    }
  }

  /// Очистка кэша
  Future<void> _onClearCache(
    ClearGratitudeCache event,
    Emitter<GratitudeState> emit,
  ) async {
    try {
      print('🗑️ Кэш благодарственных предложений очищен');
      emit(GratitudeInitial());
    } catch (e) {
      print('❌ Ошибка очистки кэша: $e');
      emit(GratitudeError('Не удалось очистить кэш'));
    }
  }

  /// Загрузка предложений с кэшированием
  Future<void> loadPromptsWithCache(List<MoodEntry> recentMoods) async {
    try {
      emit(GratitudeLoading());

      final gratitude = await _generateGratitudePromptsUseCase.callWithCache(
        recentMoods,
      );
      emit(GratitudeLoaded(gratitude, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки с кэшем: $e');
      emit(
        GratitudeError(
          'Не удалось загрузить предложения с кэшем: ${e.toString()}',
        ),
      );
    }
  }

  /// Загрузка предложений для категории
  Future<void> loadPromptsForCategory(
    List<MoodEntry> recentMoods,
    GratitudeCategory category,
  ) async {
    try {
      emit(GratitudeLoading());

      final gratitude = await _generateGratitudePromptsUseCase.callForCategory(
        recentMoods,
        category,
      );

      emit(GratitudeLoaded(gratitude, DateTime.now()));
    } catch (e) {
      print('❌ Ошибка загрузки для категории: $e');
      emit(GratitudeError('Не удалось загрузить предложения для категории'));
    }
  }

  /// Проверка, является ли текущее состояние загруженным
  bool get isLoaded => state is GratitudeLoaded;

  /// Получение текущих благодарственных предложений
  GratitudeEntity? get currentGratitude {
    if (state is GratitudeLoaded) {
      return (state as GratitudeLoaded).gratitude;
    }
    return null;
  }

  /// Проверка, является ли текущее состояние ошибочным
  bool get hasError => state is GratitudeError;

  /// Получение сообщения об ошибке
  String? get errorMessage {
    if (state is GratitudeError) {
      return (state as GratitudeError).message;
    }
    return null;
  }

  /// Получение случайного предложения
  String getRandomPrompt() {
    final gratitude = currentGratitude;
    if (gratitude != null && gratitude.prompts.isNotEmpty) {
      return gratitude.getRandomPrompt();
    }
    return 'За что вы благодарны сегодня?';
  }

  /// Проверка, есть ли предложения
  bool get hasPrompts {
    final gratitude = currentGratitude;
    return gratitude?.prompts.isNotEmpty == true;
  }

  /// Получение количества предложений
  int get promptCount {
    final gratitude = currentGratitude;
    return gratitude?.promptCount ?? 0;
  }
}

