import 'package:hive_flutter/hive_flutter.dart';
import '../models/ai_insight_model.dart';

abstract class AIInsightsLocalDataSource {
  Future<List<AIInsightModel>> getAllInsights();
  Future<AIInsightModel?> getInsightById(String id);
  Future<List<AIInsightModel>> getInsightsByType(int typeValue);
  Future<void> saveInsight(AIInsightModel insight);
  Future<void> deleteInsight(String id);
  Future<void> clearOldInsights(int daysOld);
}

class AIInsightsLocalDataSourceImpl implements AIInsightsLocalDataSource {
  static const String _boxName = 'ai_insights';
  late Box<AIInsightModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<AIInsightModel>(_boxName);
  }

  @override
  Future<List<AIInsightModel>> getAllInsights() async {
    return _box.values.toList()
      ..sort((a, b) => b.priority.compareTo(a.priority))
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<AIInsightModel?> getInsightById(String id) async {
    try {
      return _box.values.firstWhere((insight) => insight.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AIInsightModel>> getInsightsByType(int typeValue) async {
    return _box.values
        .where((insight) => insight.typeValue == typeValue)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveInsight(AIInsightModel insight) async {
    await _box.put(insight.id, insight);
  }

  @override
  Future<void> deleteInsight(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearOldInsights(int daysOld) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final keysToDelete = <String>[];
    
    for (final entry in _box.toMap().entries) {
      if (entry.value.createdAt.isBefore(cutoffDate)) {
        keysToDelete.add(entry.key);
      }
    }
    
    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }
}

