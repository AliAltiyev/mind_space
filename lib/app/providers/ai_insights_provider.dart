import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/ai_insights_repository_impl.dart';
import '../../domain/entities/ai_insight.dart';
import '../../domain/repositories/ai_insights_repository.dart';
import 'app_providers.dart';

/// Провайдер для RemoteDataSource
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  final dio = createDioClient();
  return RemoteDataSource(dio);
});

/// Провайдер для AIInsightsRepository
final aiInsightsRepositoryProvider = Provider<AIInsightsRepository>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  final database = ref.watch(appDatabaseProvider);
  
  return AIInsightsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    database: database,
  );
});

/// Провайдер для получения AI инсайтов
class AIInsightsNotifier extends StateNotifier<AsyncValue<AIInsight>> {
  AIInsightsNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  /// Получение инсайтов на основе записей настроения
  Future<void> getMoodInsights(List<MoodEntry> entries) async {
    try {
      state = const AsyncValue.loading();
      
      final repository = ref.read(aiInsightsRepositoryProvider);
      final insight = await repository.getMoodInsights(entries);
      
      state = AsyncValue.data(insight);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Обновление инсайтов
  Future<void> refreshInsights(List<MoodEntry> entries) async {
    await getMoodInsights(entries);
  }

  /// Очистка состояния
  void clearInsights() {
    state = const AsyncValue.loading();
  }
}

final aiInsightsProvider = StateNotifierProvider<AIInsightsNotifier, AsyncValue<AIInsight>>((ref) {
  return AIInsightsNotifier(ref);
});

/// Провайдер для получения списка AI инсайтов (для карусели)
class AIInsightsListNotifier extends StateNotifier<AsyncValue<List<AIInsight>>> {
  AIInsightsListNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  /// Получение списка инсайтов на основе записей настроения
  Future<void> getMoodInsightsList(List<MoodEntry> entries) async {
    try {
      state = const AsyncValue.loading();
      
      final repository = ref.read(aiInsightsRepositoryProvider);
      final insight = await repository.getMoodInsights(entries);
      
      // Создаем список с основным инсайтом и дополнительными
      final insightsList = await _generateInsightsList(insight, entries);
      
      state = AsyncValue.data(insightsList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Генерация списка инсайтов
  Future<List<AIInsight>> _generateInsightsList(AIInsight mainInsight, List<MoodEntry> entries) async {
    final insights = <AIInsight>[mainInsight];
    
    // Добавляем дополнительные инсайты на основе данных
    final additionalInsights = _generateAdditionalInsights(entries);
    insights.addAll(additionalInsights);
    
    return insights;
  }

  /// Генерация дополнительных инсайтов
  List<AIInsight> _generateAdditionalInsights(List<MoodEntry> entries) {
    final insights = <AIInsight>[];
    
    if (entries.isEmpty) return insights;

    final averageMood = entries
        .map((e) => e.moodValue)
        .reduce((a, b) => a + b) / entries.length;

    final recentEntries = entries.take(7).toList();
    final hasNotes = entries.any((e) => e.note != null && e.note!.isNotEmpty);

    // Инсайт о тренде
    if (recentEntries.length >= 3) {
      final trend = _calculateTrend(recentEntries);
      insights.add(_createTrendInsight(trend));
    }

    // Инсайт о заметках
    if (hasNotes) {
      insights.add(_createNotesInsight());
    }

    // Инсайт о стабильности
    final stability = _calculateStability(entries);
    insights.add(_createStabilityInsight(stability));

    // Мотивационный инсайт
    insights.add(_createMotivationalInsight(averageMood));

    return insights;
  }

  /// Расчет тренда настроения
  String _calculateTrend(List<MoodEntry> recentEntries) {
    if (recentEntries.length < 3) return 'stable';
    
    final firstHalf = recentEntries.take(recentEntries.length ~/ 2).toList();
    final secondHalf = recentEntries.skip(recentEntries.length ~/ 2).toList();
    
    final firstAvg = firstHalf.map((e) => e.moodValue).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((e) => e.moodValue).reduce((a, b) => a + b) / secondHalf.length;
    
    if (secondAvg > firstAvg + 0.3) return 'improving';
    if (secondAvg < firstAvg - 0.3) return 'declining';
    return 'stable';
  }

  /// Расчет стабильности настроения
  double _calculateStability(List<MoodEntry> entries) {
    if (entries.length < 2) return 1.0;
    
    final values = entries.map((e) => e.moodValue).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    
    final variance = values
        .map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    
    return math.max(0.0, 1.0 - variance);
  }

  /// Создание инсайта о тренде
  AIInsight _createTrendInsight(String trend) {
    switch (trend) {
      case 'improving':
        return const AIInsight(
          title: 'Настроение улучшается!',
          description: 'Вы на правильном пути. Продолжайте практики, которые помогают вам чувствовать себя лучше.',
          emoji: '📈',
          accentColor: Color(0xFF4ECDC4),
        );
      case 'declining':
        return const AIInsight(
          title: 'Время для заботы',
          description: 'Заметили снижение настроения? Это нормально. Попробуйте новые способы заботы о себе.',
          emoji: '🤗',
          accentColor: Color(0xFFFD79A8),
        );
      default:
        return const AIInsight(
          title: 'Стабильный ритм',
          description: 'Ваше настроение остается стабильным. Это хорошая основа для дальнейшего развития.',
          emoji: '⚖️',
          accentColor: Color(0xFFE17055),
        );
    }
  }

  /// Создание инсайта о заметках
  AIInsight _createNotesInsight() {
    return const AIInsight(
      title: 'Рефлексия помогает',
      description: 'Отлично, что вы записываете свои мысли! Это помогает лучше понимать свои эмоции.',
      emoji: '📝',
      accentColor: Color(0xFF96CEB4),
    );
  }

  /// Создание инсайта о стабильности
  AIInsight _createStabilityInsight(double stability) {
    if (stability > 0.8) {
      return const AIInsight(
        title: 'Высокая стабильность',
        description: 'Ваше настроение очень стабильно. Это показатель эмоциональной зрелости.',
        emoji: '🎯',
        accentColor: Color(0xFF45B7D1),
      );
    } else if (stability > 0.5) {
      return const AIInsight(
        title: 'Умеренная стабильность',
        description: 'Ваше настроение имеет естественные колебания. Это нормально и здорово.',
        emoji: '🌊',
        accentColor: Color(0xFFDDA0DD),
      );
    } else {
      return const AIInsight(
        title: 'Эмоциональная чувствительность',
        description: 'Вы очень чутко реагируете на события. Это может быть силой при правильном управлении.',
        emoji: '🎭',
        accentColor: Color(0xFFFDCB6E),
      );
    }
  }

  /// Создание мотивационного инсайта
  AIInsight _createMotivationalInsight(double averageMood) {
    if (averageMood >= 4) {
      return const AIInsight(
        title: 'Отличная работа!',
        description: 'Вы поддерживаете высокий уровень благополучия. Поделитесь своими секретами!',
        emoji: '🌟',
        accentColor: Color(0xFF6BCF7F),
      );
    } else if (averageMood >= 3) {
      return const AIInsight(
        title: 'Хороший баланс',
        description: 'Вы находите золотую середину. Продолжайте развивать навыки эмоционального благополучия.',
        emoji: '⚖️',
        accentColor: Color(0xFFA8E6CF),
      );
    } else {
      return const AIInsight(
        title: 'Время для роста',
        description: 'Каждый день - это возможность для улучшения. Маленькие шаги ведут к большим изменениям.',
        emoji: '🌱',
        accentColor: Color(0xFFFFD93D),
      );
    }
  }

  /// Обновление списка инсайтов
  Future<void> refreshInsightsList(List<MoodEntry> entries) async {
    await getMoodInsightsList(entries);
  }

  /// Очистка состояния
  void clearInsightsList() {
    state = const AsyncValue.loading();
  }
}

final aiInsightsListProvider = StateNotifierProvider<AIInsightsListNotifier, AsyncValue<List<AIInsight>>>((ref) {
  return AIInsightsListNotifier(ref);
});

/// Провайдер для получения записей настроения
final moodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  
  // Получаем записи за последние 30 дней
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  
  return await database.getMoodsForPeriod(startDate, endDate);
});

/// Комбинированный провайдер для AI инсайтов с записями настроения
final aiInsightsWithMoodsProvider = FutureProvider<AsyncValue<AIInsight>>((ref) async {
  final moodEntries = await ref.watch(moodEntriesProvider.future);
  final insightsNotifier = ref.read(aiInsightsProvider.notifier);
  
  await insightsNotifier.getMoodInsights(moodEntries);
  
  return ref.watch(aiInsightsProvider);
});

/// Комбинированный провайдер для списка AI инсайтов с записями настроения
final aiInsightsListWithMoodsProvider = FutureProvider<AsyncValue<List<AIInsight>>>((ref) async {
  final moodEntries = await ref.watch(moodEntriesProvider.future);
  final insightsListNotifier = ref.read(aiInsightsListProvider.notifier);
  
  await insightsListNotifier.getMoodInsightsList(moodEntries);
  
  return ref.watch(aiInsightsListProvider);
});

/// Простой тестовый провайдер для демо
final testAIInsightsProvider = FutureProvider<List<AIInsight>>((ref) async {
  // Возвращаем тестовые данные для демонстрации
  await Future.delayed(const Duration(seconds: 2)); // Имитация загрузки
  
  return [
    const AIInsight(
      title: 'Отличное настроение!',
      description: 'Вы поддерживаете высокий уровень благополучия. Продолжайте в том же духе!',
      emoji: '🌟',
      accentColor: Color(0xFF6BCF7F),
    ),
    const AIInsight(
      title: 'Стабильное состояние',
      description: 'Ваше настроение находится в хорошем балансе. Это отличная основа для дальнейшего развития.',
      emoji: '⚖️',
      accentColor: Color(0xFFA8E6CF),
    ),
    const AIInsight(
      title: 'Время для роста',
      description: 'Каждый день - это возможность для улучшения. Маленькие шаги ведут к большим изменениям.',
      emoji: '🌱',
      accentColor: Color(0xFFFFD93D),
    ),
  ];
});
