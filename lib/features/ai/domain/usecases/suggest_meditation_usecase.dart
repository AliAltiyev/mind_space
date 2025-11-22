import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
      print('⚠️ AI недоступен, используем fallback медитацию: $e');
      // Repository уже должен вернуть fallback, но на всякий случай
      // возвращаем базовую медитацию
      return _createBasicMeditation(recentMoods);
    }
  }

  /// Создание базовой медитации при недоступности AI
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
      print(
        '⚠️ Ошибка при получении медитации для типа, используем fallback: $e',
      );
      return _createBasicMeditation(recentMoods).copyWith(type: type);
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
      print(
        '⚠️ Ошибка при получении медитации с кэшем, используем fallback: $e',
      );
      return _createBasicMeditation(recentMoods);
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
      print(
        '⚠️ Ошибка при получении медитации для времени дня, используем fallback: $e',
      );
      return _createBasicMeditation(recentMoods);
    }
  }

  /// Предложение медитации для текущего настроения
  Future<MeditationEntity> callForCurrentMood(
    List<MoodEntry> recentMoods,
  ) async {
    final currentMood = recentMoods.isNotEmpty
        ? recentMoods.first.moodValue
        : 3;

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
      print(
        '⚠️ Ошибка при получении медитации для настроения, используем fallback: $e',
      );
      return _createBasicMeditation(recentMoods);
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
      print(
        '⚠️ Ошибка при получении короткой медитации, используем fallback: $e',
      );
      return _createBasicMeditation(recentMoods).copyWith(
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
      print(
        '⚠️ Ошибка при получении длинной медитации, используем fallback: $e',
      );
      return _createBasicMeditation(recentMoods).copyWith(
        duration: 30,
        title: 'ai.meditation.deep'.tr(),
        description: 'ai.meditation.deep_desc'.tr(),
      );
    } catch (e) {
      throw Exception('Failed to suggest long meditation session: $e');
    }
  }
}
