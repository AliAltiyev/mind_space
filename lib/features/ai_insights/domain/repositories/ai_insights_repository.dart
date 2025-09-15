import '../entities/ai_insight.dart';

abstract class AIInsightsRepository {
  Future<List<AIInsight>> getAllInsights();
  Future<AIInsight?> getInsightById(String id);
  Future<List<AIInsight>> getInsightsByType(InsightType type);
  Future<void> saveInsight(AIInsight insight);
  Future<void> deleteInsight(String id);
  Future<void> clearOldInsights(int daysOld);
  Future<List<AIInsight>> generateInsights(List<Map<String, dynamic>> moodData);
}

