import '../../../../core/database/database.dart';
import '../entities/ai_insight_entity.dart';
import '../entities/gratitude_entity.dart';
import '../entities/meditation_entity.dart';
import '../entities/mood_pattern_entity.dart';

/// Абстрактный репозиторий для AI функций
abstract class AIRepository {
  /// Получение AI инсайтов на основе записей настроения
  Future<AIInsightEntity> getMoodInsights(List<MoodEntry> entries);

  /// Анализ паттернов настроения
  Future<MoodPatternEntity> analyzeMoodPatterns(List<MoodEntry> moodHistory);

  /// Генерация благодарственных предложений
  Future<GratitudeEntity> generateGratitudePrompts(List<MoodEntry> recentMoods);

  /// Предложение медитационных сессий
  Future<MeditationEntity> suggestMeditationSession(
    List<MoodEntry> recentMoods,
  );

  /// Кэширование AI ответа
  Future<void> cacheAIResponse(String key, dynamic response);

  /// Получение кэшированного ответа
  Future<dynamic> getCachedResponse(String key);

  /// Очистка кэша
  Future<void> clearCache();

  /// Проверка доступности AI сервиса
  Future<bool> isAIServiceAvailable();
}
