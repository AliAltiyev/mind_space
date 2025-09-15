import '../../core/database/database.dart';
import '../entities/ai_insight.dart';

/// Абстрактный репозиторий для AI инсайтов
abstract class AIInsightsRepository {
  /// Получение AI инсайта на основе записей настроения
  Future<AIInsight> getMoodInsights(List<MoodEntry> entries);
  
  /// Кэширование инсайта
  Future<void> cacheInsight(AIInsight insight);
  
  /// Получение кэшированного инсайта
  Future<AIInsight?> getCachedInsight();
  
  /// Очистка кэша
  Future<void> clearCache();
}

