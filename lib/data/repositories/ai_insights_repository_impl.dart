import 'package:flutter/material.dart';

import '../../core/database/database.dart';
import '../../domain/entities/ai_insight.dart';
import '../../domain/repositories/ai_insights_repository.dart';
import '../datasources/remote_data_source.dart';

/// Реализация репозитория для AI инсайтов
class AIInsightsRepositoryImpl implements AIInsightsRepository {
  final RemoteDataSource _remoteDataSource;
  final AppDatabase _database;

  AIInsightsRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required AppDatabase database,
  }) : _remoteDataSource = remoteDataSource,
       _database = database;

  @override
  Future<AIInsight> getMoodInsights(List<MoodEntry> entries) async {
    try {
      // Получаем инсайт от AI
      final insight = await _remoteDataSource.getMoodInsights(entries);
      
      // Кэшируем результат
      await cacheInsight(insight);
      
      return insight;
    } catch (e) {
      // В случае ошибки пытаемся получить кэшированный инсайт
      final cachedInsight = await getCachedInsight();
      if (cachedInsight != null) {
        return cachedInsight;
      }
      
      // Если кэша нет, возвращаем fallback инсайт
      return _createFallbackInsight(entries);
    }
  }

  @override
  Future<void> cacheInsight(AIInsight insight) async {
    try {
      await _database.setSetting('cached_insight', insight.toJson());
      await _database.setSetting(
        'cached_insight_timestamp',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Логируем ошибку, но не прерываем выполнение
      print('Failed to cache insight: $e');
    }
  }

  @override
  Future<AIInsight?> getCachedInsight() async {
    try {
      final cachedJson = await _database.getSetting('cached_insight');
      final timestampStr = await _database.getSetting('cached_insight_timestamp');
      
      if (cachedJson == null || timestampStr == null) {
        return null;
      }

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      
      // Кэш действителен в течение 24 часов
      if (now.difference(timestamp).inHours > 24) {
        await clearCache();
        return null;
      }

      return AIInsight.fromJson(cachedJson);
    } catch (e) {
      print('Failed to get cached insight: $e');
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _database.setSetting('cached_insight', '');
      await _database.setSetting('cached_insight_timestamp', '');
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  /// Создание fallback инсайта
  AIInsight _createFallbackInsight(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return const AIInsight(
        title: 'Начните отслеживать настроение',
        description: 'Добавьте первую запись о своем настроении, чтобы получить персональные инсайты.',
        emoji: '🌟',
        accentColor: Color(0xFF4ECDC4),
      );
    }

    final averageMood = entries
        .map((e) => e.moodValue)
        .reduce((a, b) => a + b) / entries.length;

    if (averageMood >= 4) {
      return const AIInsight(
        title: 'Отличное настроение!',
        description: 'Вы поддерживаете позитивный настрой. Продолжайте в том же духе!',
        emoji: '😊',
        accentColor: Color(0xFF96CEB4),
      );
    } else if (averageMood >= 3) {
      return const AIInsight(
        title: 'Стабильное состояние',
        description: 'Ваше настроение находится в хорошем балансе. Это отличная основа!',
        emoji: '😌',
        accentColor: Color(0xFFE17055),
      );
    } else {
      return const AIInsight(
        title: 'Забота о себе',
        description: 'Важно заботиться о своем эмоциональном благополучии. Маленькие шаги каждый день.',
        emoji: '🤗',
        accentColor: Color(0xFFFD79A8),
      );
    }
  }
}
