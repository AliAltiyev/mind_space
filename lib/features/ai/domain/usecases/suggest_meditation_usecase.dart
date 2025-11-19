import 'package:easy_localization/easy_localization.dart';

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
          title: 'ai.meditation.morning'.tr(),
          description: 'ai.meditation.morning_desc'.tr(),
        );
      } else if (hour >= 12 && hour < 18) {
        // День
        return meditation.copyWith(
          title: 'ai.meditation.day_break'.tr(),
          description: 'ai.meditation.day_break_desc'.tr(),
        );
      } else if (hour >= 18 && hour < 22) {
        // Вечер
        return meditation.copyWith(
          title: 'ai.meditation.evening'.tr(),
          description: 'ai.meditation.evening_desc'.tr(),
        );
      } else {
        // Ночь
        return meditation.copyWith(
          title: 'ai.meditation.bedtime'.tr(),
          description: 'ai.meditation.bedtime_desc'.tr(),
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
          title: 'ai.meditation.healing'.tr(),
          description: 'ai.meditation.healing_desc'.tr(),
        );
      } else if (currentMood >= 4) {
        return meditation.copyWith(
          type: MeditationType.mindfulness,
          duration: 10,
          title: 'ai.meditation.gratitude'.tr(),
          description: 'ai.meditation.gratitude_desc'.tr(),
        );
      } else {
        return meditation.copyWith(
          type: MeditationType.breathing,
          duration: 12,
          title: 'ai.meditation.balance'.tr(),
          description: 'ai.meditation.balance_desc'.tr(),
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
        title: 'ai.meditation.quick'.tr(),
        description: 'ai.meditation.quick_desc'.tr(),
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
        title: 'ai.meditation.deep'.tr(),
        description: 'ai.meditation.deep_desc'.tr(),
      );
    } catch (e) {
      throw Exception('Failed to suggest long meditation session: $e');
    }
  }
}
