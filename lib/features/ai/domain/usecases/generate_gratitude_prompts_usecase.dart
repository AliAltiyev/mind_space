import '../../../../core/database/database.dart';
import '../entities/gratitude_entity.dart';
import '../repositories/ai_repository.dart';

/// Use case для генерации благодарственных предложений
class GenerateGratitudePromptsUseCase {
  final AIRepository repository;

  const GenerateGratitudePromptsUseCase(this.repository);

  /// Генерация благодарственных предложений
  Future<GratitudeEntity> call(List<MoodEntry> recentMoods) async {
    try {
      return await repository.generateGratitudePrompts(recentMoods);
    } catch (e) {
      throw Exception('Failed to generate gratitude prompts: $e');
    }
  }

  /// Генерация предложений для конкретной категории
  Future<GratitudeEntity> callForCategory(
    List<MoodEntry> recentMoods,
    GratitudeCategory category,
  ) async {
    try {
      final prompts = await call(recentMoods);

      // Фильтруем предложения по категории (если нужно)
      return prompts.copyWith(category: category);
    } catch (e) {
      throw Exception('Failed to generate gratitude prompts for category: $e');
    }
  }

  /// Генерация предложений с кэшированием
  Future<GratitudeEntity> callWithCache(List<MoodEntry> recentMoods) async {
    final cacheKey = 'gratitude_${recentMoods.length}_${DateTime.now().day}';

    try {
      // Проверяем кэш (обновляем ежедневно)
      final cached = await repository.getCachedResponse(cacheKey);
      if (cached != null) {
        return GratitudeEntity.fromMap(cached);
      }

      // Получаем новые данные
      final prompts = await call(recentMoods);

      // Кэшируем результат
      await repository.cacheAIResponse(cacheKey, prompts.toMap());

      return prompts;
    } catch (e) {
      throw Exception('Failed to generate gratitude prompts with cache: $e');
    }
  }

  /// Генерация предложений для текущего настроения
  Future<GratitudeEntity> callForCurrentMood(
    List<MoodEntry> recentMoods,
  ) async {
    if (recentMoods.isEmpty) {
      throw Exception('No mood data available for gratitude prompts');
    }

    final currentMood = recentMoods.first.moodValue;

    try {
      final prompts = await call(recentMoods);

      // Адаптируем предложения под текущее настроение
      if (currentMood <= 2) {
        return prompts.copyWith(
          title: 'Найдите свет в темноте',
          description: 'Даже в трудные времена есть за что быть благодарным',
        );
      } else if (currentMood >= 4) {
        return prompts.copyWith(
          title: 'Поделитесь радостью',
          description: 'Прекрасное время для благодарности и радости',
        );
      }

      return prompts;
    } catch (e) {
      throw Exception(
        'Failed to generate gratitude prompts for current mood: $e',
      );
    }
  }

  /// Генерация случайных предложений
  Future<GratitudeEntity> callRandom(List<MoodEntry> recentMoods) async {
    try {
      final prompts = await call(recentMoods);

      // Перемешиваем предложения
      final shuffledPrompts = List<String>.from(prompts.prompts)..shuffle();

      return prompts.copyWith(prompts: shuffledPrompts);
    } catch (e) {
      throw Exception('Failed to generate random gratitude prompts: $e');
    }
  }
}
