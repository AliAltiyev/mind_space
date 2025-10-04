import 'dart:math';

/// Сервис для ИИ анализа настроения и генерации рекомендаций
class AIAnalysisService {
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  /// Анализ паттернов настроения
  Future<MoodPatternAnalysis> analyzeMoodPatterns(List<MoodEntry> entries) async {
    if (entries.isEmpty) {
      return MoodPatternAnalysis(
        averageMood: 3.0,
        trend: MoodTrend.stable,
        insights: ['Start tracking your mood to get insights!'],
        recommendations: ['Begin by logging your mood daily'],
      );
    }

    // Вычисляем среднее настроение
    final averageMood = entries.map((e) => e.mood).reduce((a, b) => a + b) / entries.length;

    // Определяем тренд
    final recentEntries = entries.take(7).toList();
    final olderEntries = entries.skip(7).take(7).toList();
    
    MoodTrend trend = MoodTrend.stable;
    if (recentEntries.length >= 2 && olderEntries.length >= 2) {
      final recentAvg = recentEntries.map((e) => e.mood).reduce((a, b) => a + b) / recentEntries.length;
      final olderAvg = olderEntries.map((e) => e.mood).reduce((a, b) => a + b) / olderEntries.length;
      
      if (recentAvg > olderAvg + 0.5) {
        trend = MoodTrend.improving;
      } else if (recentAvg < olderAvg - 0.5) {
        trend = MoodTrend.declining;
      }
    }

    // Генерируем инсайты
    final insights = _generateInsights(entries, averageMood, trend);
    
    // Генерируем рекомендации
    final recommendations = _generateRecommendations(entries, averageMood, trend);

    return MoodPatternAnalysis(
      averageMood: averageMood,
      trend: trend,
      insights: insights,
      recommendations: recommendations,
    );
  }

  /// Анализ корреляций между настроением и активностями
  Future<ActivityCorrelationAnalysis> analyzeActivityCorrelations(
    List<MoodEntry> entries,
  ) async {
    final activityMoodMap = <String, List<int>>{};
    
    for (final entry in entries) {
      for (final activity in entry.activities) {
        activityMoodMap.putIfAbsent(activity, () => []).add(entry.mood);
      }
    }

    final correlations = <ActivityCorrelation>[];
    
    for (final entry in activityMoodMap.entries) {
      final activity = entry.key;
      final moods = entry.value;
      
      if (moods.length >= 3) { // Минимум 3 записи для анализа
        final avgMood = moods.reduce((a, b) => a + b) / moods.length;
        final frequency = moods.length / entries.length;
        
        correlations.add(ActivityCorrelation(
          activity: activity,
          averageMood: avgMood,
          frequency: frequency,
          impact: _calculateImpact(avgMood, frequency),
        ));
      }
    }

    correlations.sort((a, b) => b.impact.compareTo(a.impact));

    return ActivityCorrelationAnalysis(
      correlations: correlations,
      topPositiveActivities: correlations
          .where((c) => c.averageMood > 3.5)
          .take(3)
          .map((c) => c.activity)
          .toList(),
      topNegativeActivities: correlations
          .where((c) => c.averageMood < 2.5)
          .take(3)
          .map((c) => c.activity)
          .toList(),
    );
  }

  /// Генерация персональных рекомендаций
  Future<List<String>> generatePersonalRecommendations(
    List<MoodEntry> entries,
    MoodPatternAnalysis patternAnalysis,
    ActivityCorrelationAnalysis activityAnalysis,
  ) async {
    final recommendations = <String>[];

    // Рекомендации на основе тренда
    switch (patternAnalysis.trend) {
      case MoodTrend.improving:
        recommendations.add('Great job! Your mood is trending upward. Keep up the positive momentum!');
        recommendations.add('Consider documenting what\'s helping you feel better.');
        break;
      case MoodTrend.declining:
        recommendations.add('I notice your mood has been lower lately. Consider reaching out to friends or family.');
        recommendations.add('Try some of your favorite positive activities to boost your mood.');
        break;
      case MoodTrend.stable:
        recommendations.add('Your mood has been stable. Consider trying new activities to add variety.');
        break;
    }

    // Рекомендации на основе активностей
    if (activityAnalysis.topPositiveActivities.isNotEmpty) {
      final topActivity = activityAnalysis.topPositiveActivities.first;
      recommendations.add('You feel great when doing $topActivity. Try to include it more often!');
    }

    if (activityAnalysis.topNegativeActivities.isNotEmpty) {
      final negativeActivity = activityAnalysis.topNegativeActivities.first;
      recommendations.add('Consider reducing or changing your approach to $negativeActivity.');
    }

    // Рекомендации на основе времени дня
    final timeRecommendations = _getTimeBasedRecommendations(entries);
    recommendations.addAll(timeRecommendations);

    // Рекомендации на основе дня недели
    final weekdayRecommendations = _getWeekdayRecommendations(entries);
    recommendations.addAll(weekdayRecommendations);

    return recommendations.take(5).toList(); // Максимум 5 рекомендаций
  }

  /// Генерация инсайтов
  List<String> _generateInsights(List<MoodEntry> entries, double averageMood, MoodTrend trend) {
    final insights = <String>[];

    // Инсайт о среднем настроении
    if (averageMood >= 4.0) {
      insights.add('You generally maintain a positive outlook!');
    } else if (averageMood <= 2.0) {
      insights.add('You might benefit from additional support or self-care activities.');
    } else {
      insights.add('Your mood varies, which is completely normal.');
    }

    // Инсайт о тренде
    switch (trend) {
      case MoodTrend.improving:
        insights.add('Your mood has been improving recently - keep it up!');
        break;
      case MoodTrend.declining:
        insights.add('Your mood has been declining - consider reaching out for support.');
        break;
      case MoodTrend.stable:
        insights.add('Your mood has been quite stable recently.');
        break;
    }

    // Инсайт о консистентности
    final moodVariance = _calculateMoodVariance(entries);
    if (moodVariance < 0.5) {
      insights.add('Your mood is very consistent - you have good emotional regulation.');
    } else if (moodVariance > 1.5) {
      insights.add('Your mood varies significantly - this might indicate stress or life changes.');
    }

    // Инсайт о записях
    if (entries.length >= 30) {
      insights.add('You\'ve been tracking your mood for a while - great consistency!');
    } else if (entries.length >= 7) {
      insights.add('You\'re building a good habit of mood tracking.');
    }

    return insights;
  }

  /// Генерация рекомендаций
  List<String> _generateRecommendations(List<MoodEntry> entries, double averageMood, MoodTrend trend) {
    final recommendations = <String>[];

    // Базовые рекомендации
    if (averageMood < 3.0) {
      recommendations.add('Consider practicing gratitude - write down 3 good things each day.');
      recommendations.add('Try mindfulness or meditation to help manage stress.');
      recommendations.add('Ensure you\'re getting enough sleep and exercise.');
    } else if (averageMood >= 4.0) {
      recommendations.add('Share your positive energy with others!');
      recommendations.add('Consider helping someone else to maintain your good mood.');
    }

    // Рекомендации на основе тренда
    switch (trend) {
      case MoodTrend.declining:
        recommendations.add('Consider talking to a trusted friend or professional.');
        recommendations.add('Try some gentle physical activity like walking.');
        break;
      case MoodTrend.improving:
        recommendations.add('Document what\'s working well for you.');
        recommendations.add('Continue with your current positive habits.');
        break;
      case MoodTrend.stable:
        recommendations.add('Your mood is stable - great emotional regulation!');
        recommendations.add('Consider exploring new activities to add variety.');
        break;
    }

    // Случайные дополнительные рекомендации
    final randomRecommendations = [
      'Try spending time in nature to boost your mood.',
      'Connect with friends or family members.',
      'Engage in a hobby you enjoy.',
      'Practice deep breathing exercises.',
      'Listen to your favorite music.',
      'Read something inspiring or uplifting.',
      'Try cooking a new recipe.',
      'Take a break from social media.',
    ];

    final random = Random();
    if (recommendations.length < 3) {
      final additional = randomRecommendations[random.nextInt(randomRecommendations.length)];
      if (!recommendations.contains(additional)) {
        recommendations.add(additional);
      }
    }

    return recommendations.take(4).toList();
  }

  /// Получение рекомендаций на основе времени дня
  List<String> _getTimeBasedRecommendations(List<MoodEntry> entries) {
    final recommendations = <String>[];
    final morningEntries = entries.where((e) => e.timeOfDay == TimeOfDay.morning).toList();
    final eveningEntries = entries.where((e) => e.timeOfDay == TimeOfDay.evening).toList();

    if (morningEntries.isNotEmpty && eveningEntries.isNotEmpty) {
      final morningAvg = morningEntries.map((e) => e.mood).reduce((a, b) => a + b) / morningEntries.length;
      final eveningAvg = eveningEntries.map((e) => e.mood).reduce((a, b) => a + b) / eveningEntries.length;

      if (morningAvg < eveningAvg - 0.5) {
        recommendations.add('You tend to feel better in the evening. Consider starting your day with a positive routine.');
      } else if (morningAvg > eveningAvg + 0.5) {
        recommendations.add('You start your days well but mood declines. Consider evening relaxation activities.');
      }
    }

    return recommendations;
  }

  /// Получение рекомендаций на основе дня недели
  List<String> _getWeekdayRecommendations(List<MoodEntry> entries) {
    final recommendations = <String>[];
    final weekdayEntries = entries.where((e) => e.isWeekday).toList();
    final weekendEntries = entries.where((e) => !e.isWeekday).toList();

    if (weekdayEntries.isNotEmpty && weekendEntries.isNotEmpty) {
      final weekdayAvg = weekdayEntries.map((e) => e.mood).reduce((a, b) => a + b) / weekdayEntries.length;
      final weekendAvg = weekendEntries.map((e) => e.mood).reduce((a, b) => a + b) / weekendEntries.length;

      if (weekdayAvg < weekendAvg - 0.5) {
        recommendations.add('You feel better on weekends. Consider finding ways to bring weekend joy to weekdays.');
      }
    }

    return recommendations;
  }

  /// Вычисление дисперсии настроения
  double _calculateMoodVariance(List<MoodEntry> entries) {
    if (entries.length < 2) return 0.0;
    
    final average = entries.map((e) => e.mood).reduce((a, b) => a + b) / entries.length;
    final variance = entries.map((e) => pow(e.mood - average, 2)).reduce((a, b) => a + b) / entries.length;
    
    return sqrt(variance);
  }

  /// Вычисление влияния активности
  double _calculateImpact(double averageMood, double frequency) {
    // Простая формула: чем выше настроение и чаще активность, тем больше влияние
    return averageMood * frequency;
  }
}

/// Модель записи настроения
class MoodEntry {
  final int mood; // 1-5
  final DateTime dateTime;
  final String? note;
  final List<String> activities;
  final TimeOfDay timeOfDay;
  final bool isWeekday;

  MoodEntry({
    required this.mood,
    required this.dateTime,
    this.note,
    this.activities = const [],
  }) : timeOfDay = _getTimeOfDay(dateTime.hour),
       isWeekday = dateTime.weekday <= 5;

  static TimeOfDay _getTimeOfDay(int hour) {
    if (hour < 12) return TimeOfDay.morning;
    if (hour < 18) return TimeOfDay.afternoon;
    return TimeOfDay.evening;
  }
}

/// Время дня
enum TimeOfDay {
  morning,
  afternoon,
  evening,
}

/// Тренд настроения
enum MoodTrend {
  improving,
  stable,
  declining,
}

/// Анализ паттернов настроения
class MoodPatternAnalysis {
  final double averageMood;
  final MoodTrend trend;
  final List<String> insights;
  final List<String> recommendations;

  MoodPatternAnalysis({
    required this.averageMood,
    required this.trend,
    required this.insights,
    required this.recommendations,
  });
}

/// Корреляция активности
class ActivityCorrelation {
  final String activity;
  final double averageMood;
  final double frequency;
  final double impact;

  ActivityCorrelation({
    required this.activity,
    required this.averageMood,
    required this.frequency,
    required this.impact,
  });
}

/// Анализ корреляций активностей
class ActivityCorrelationAnalysis {
  final List<ActivityCorrelation> correlations;
  final List<String> topPositiveActivities;
  final List<String> topNegativeActivities;

  ActivityCorrelationAnalysis({
    required this.correlations,
    required this.topPositiveActivities,
    required this.topNegativeActivities,
  });
}
