import '../../../../core/database/database.dart';
import '../entities/ai_insight_entity.dart';
import '../repositories/ai_repository.dart';

/// Use case для получения AI инсайтов
class GetAIInsightsUseCase {
  final AIRepository repository;

  const GetAIInsightsUseCase(this.repository);

  /// Получение инсайтов на основе записей настроения
  Future<AIInsightEntity> call(List<MoodEntry> entries) async {
    if (entries.isEmpty) {
      throw Exception('No mood entries provided for analysis');
    }

    try {
      return await repository.getMoodInsights(entries);
    } catch (e) {
      throw Exception('Failed to get AI insights: $e');
    }
  }

  /// Получение инсайтов для последних N дней
  Future<AIInsightEntity> callForRecentDays(
    List<MoodEntry> allEntries,
    int days,
  ) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentEntries = allEntries
        .where((entry) => entry.createdAt.isAfter(cutoffDate))
        .toList();

    return call(recentEntries);
  }

  /// Получение инсайтов для конкретного периода
  Future<AIInsightEntity> callForPeriod(
    List<MoodEntry> allEntries,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final periodEntries = allEntries
        .where(
          (entry) =>
              entry.createdAt.isAfter(startDate) &&
              entry.createdAt.isBefore(endDate),
        )
        .toList();

    return call(periodEntries);
  }

  /// Получение инсайтов с кэшированием
  Future<AIInsightEntity> callWithCache(List<MoodEntry> entries) async {
    final cacheKey = 'insights_${entries.length}_${entries.hashCode}';

    try {
      // Проверяем кэш
      final cached = await repository.getCachedResponse(cacheKey);
      if (cached != null) {
        return AIInsightEntity.fromMap(cached);
      }

      // Получаем новые данные
      final insight = await call(entries);

      // Кэшируем результат
      await repository.cacheAIResponse(cacheKey, insight.toMap());

      return insight;
    } catch (e) {
      throw Exception('Failed to get AI insights with cache: $e');
    }
  }
}
