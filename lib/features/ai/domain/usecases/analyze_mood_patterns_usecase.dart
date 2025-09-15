import '../../../../core/database/database.dart';
import '../entities/mood_pattern_entity.dart';
import '../repositories/ai_repository.dart';

/// Use case для анализа паттернов настроения
class AnalyzeMoodPatternsUseCase {
  final AIRepository repository;

  const AnalyzeMoodPatternsUseCase(this.repository);

  /// Анализ паттернов настроения
  Future<MoodPatternEntity> call(List<MoodEntry> moodHistory) async {
    if (moodHistory.isEmpty) {
      throw Exception('No mood history provided for pattern analysis');
    }

    if (moodHistory.length < 7) {
      throw Exception(
        'Insufficient data for pattern analysis. Need at least 7 entries.',
      );
    }

    try {
      return await repository.analyzeMoodPatterns(moodHistory);
    } catch (e) {
      throw Exception('Failed to analyze mood patterns: $e');
    }
  }

  /// Анализ паттернов для последних N дней
  Future<MoodPatternEntity> callForRecentDays(
    List<MoodEntry> allEntries,
    int days,
  ) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentEntries = allEntries
        .where((entry) => entry.createdAt.isAfter(cutoffDate))
        .toList();

    return call(recentEntries);
  }

  /// Анализ паттернов для конкретного периода
  Future<MoodPatternEntity> callForPeriod(
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

  /// Анализ паттернов с кэшированием
  Future<MoodPatternEntity> callWithCache(List<MoodEntry> moodHistory) async {
    final cacheKey = 'patterns_${moodHistory.length}_${moodHistory.hashCode}';

    try {
      // Проверяем кэш
      final cached = await repository.getCachedResponse(cacheKey);
      if (cached != null) {
        return MoodPatternEntity.fromMap(cached);
      }

      // Получаем новые данные
      final patterns = await call(moodHistory);

      // Кэшируем результат
      await repository.cacheAIResponse(cacheKey, patterns.toMap());

      return patterns;
    } catch (e) {
      throw Exception('Failed to analyze mood patterns with cache: $e');
    }
  }

  /// Быстрый анализ для предварительного просмотра
  Future<MoodPatternEntity> quickAnalysis(List<MoodEntry> moodHistory) async {
    if (moodHistory.length < 3) {
      throw Exception('Need at least 3 entries for quick analysis');
    }

    // Для быстрого анализа берем только последние 14 дней
    final recentEntries = moodHistory.take(14).toList();
    return call(recentEntries);
  }
}
