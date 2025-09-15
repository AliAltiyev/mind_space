import '../../../../core/database/database.dart';
import '../entities/meditation_entity.dart';
import '../repositories/ai_repository.dart';

/// Use case для предложения медитационных сессий
class SuggestMeditationUseCase {
  final AIRepository repository;

  const SuggestMeditationUseCase(this.repository);

  /// Предложение медитационной сессии
  Future<MeditationEntity> call(List<MoodEntry> recentMoods) async {
    try {
      return await repository.suggestMeditationSession(recentMoods);
    } catch (e) {
      throw Exception('Failed to suggest meditation session: $e');
    }
  }

  /// Предложение медитации для конкретного типа
  Future<MeditationEntity> callForType(
    List<MoodEntry> recentMoods,
    MeditationType type,
  ) async {
    try {
      final meditation = await call(recentMoods);

      // Адаптируем под выбранный тип
      return meditation.copyWith(type: type);
    } catch (e) {
      throw Exception('Failed to suggest meditation for type: $e');
    }
  }

  /// Предложение медитации с кэшированием
  Future<MeditationEntity> callWithCache(List<MoodEntry> recentMoods) async {
    final cacheKey = 'meditation_${recentMoods.length}_${DateTime.now().hour}';

    try {
      // Проверяем кэш (обновляем каждый час)
      final cached = await repository.getCachedResponse(cacheKey);
      if (cached != null) {
        return MeditationEntity.fromMap(cached);
      }

      // Получаем новые данные
      final meditation = await call(recentMoods);

      // Кэшируем результат
      await repository.cacheAIResponse(cacheKey, meditation.toMap());

      return meditation;
    } catch (e) {
      throw Exception('Failed to suggest meditation with cache: $e');
    }
  }

  /// Предложение медитации для текущего времени дня
  Future<MeditationEntity> callForTimeOfDay(List<MoodEntry> recentMoods) async {
    final hour = DateTime.now().hour;

    try {
      final meditation = await call(recentMoods);

      // Адаптируем под время дня
      if (hour >= 6 && hour < 12) {
        // Утро
        return meditation.copyWith(
          title: 'Утренняя медитация',
          description: 'Начните день с осознанности и намерений',
        );
      } else if (hour >= 12 && hour < 18) {
        // День
        return meditation.copyWith(
          title: 'Дневная пауза',
          description: 'Восстановите энергию в середине дня',
        );
      } else if (hour >= 18 && hour < 22) {
        // Вечер
        return meditation.copyWith(
          title: 'Вечерняя релаксация',
          description: 'Расслабьтесь после активного дня',
        );
      } else {
        // Ночь
        return meditation.copyWith(
          title: 'Медитация перед сном',
          description: 'Подготовьтесь к спокойному сну',
        );
      }
    } catch (e) {
      throw Exception('Failed to suggest meditation for time of day: $e');
    }
  }

  /// Предложение медитации для текущего настроения
  Future<MeditationEntity> callForCurrentMood(
    List<MoodEntry> recentMoods,
  ) async {
    if (recentMoods.isEmpty) {
      throw Exception('No mood data available for meditation suggestion');
    }

    final currentMood = recentMoods.first.moodValue;

    try {
      final meditation = await call(recentMoods);

      // Адаптируем под текущее настроение
      if (currentMood <= 2) {
        return meditation.copyWith(
          type: MeditationType.lovingKindness,
          duration: 15,
          title: 'Исцеляющая медитация',
          description: 'Поможет справиться с трудными эмоциями',
        );
      } else if (currentMood >= 4) {
        return meditation.copyWith(
          type: MeditationType.mindfulness,
          duration: 10,
          title: 'Медитация благодарности',
          description: 'Углубите чувство радости и благодарности',
        );
      } else {
        return meditation.copyWith(
          type: MeditationType.breathing,
          duration: 12,
          title: 'Медитация равновесия',
          description: 'Найдите баланс и спокойствие',
        );
      }
    } catch (e) {
      throw Exception('Failed to suggest meditation for current mood: $e');
    }
  }

  /// Предложение короткой медитации
  Future<MeditationEntity> callShortSession(List<MoodEntry> recentMoods) async {
    try {
      final meditation = await call(recentMoods);

      return meditation.copyWith(
        duration: 5,
        title: 'Быстрая медитация',
        description: 'Короткая практика для восстановления энергии',
      );
    } catch (e) {
      throw Exception('Failed to suggest short meditation session: $e');
    }
  }

  /// Предложение длинной медитации
  Future<MeditationEntity> callLongSession(List<MoodEntry> recentMoods) async {
    try {
      final meditation = await call(recentMoods);

      return meditation.copyWith(
        duration: 30,
        title: 'Глубокая медитация',
        description: 'Погрузитесь в глубокое состояние покоя',
      );
    } catch (e) {
      throw Exception('Failed to suggest long meditation session: $e');
    }
  }
}
