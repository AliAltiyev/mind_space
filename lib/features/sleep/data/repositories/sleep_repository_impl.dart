import '../../../../core/database/database.dart';
import '../../../../core/api/groq_client.dart';
import '../../domain/entities/sleep_entry.dart';
import '../../domain/entities/sleep_insight.dart';
import '../repositories/sleep_repository.dart';
import 'dart:convert';

/// Реализация репозитория для работы с данными о сне
class SleepRepositoryImpl implements SleepRepository {
  final AppDatabase _database;
  final GroqClient _groqClient;

  SleepRepositoryImpl({
    required AppDatabase database,
    required GroqClient groqClient,
  }) : _database = database,
       _groqClient = groqClient;

  @override
  Future<List<SleepEntry>> getSleepEntries(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final entries = await _database.getSleepEntriesForPeriod(
        startDate,
        endDate,
      );
      return entries.map((e) => SleepEntry.fromMap(e)).toList();
    } catch (e) {
      print('❌ Ошибка получения записей сна: $e');
      return [];
    }
  }

  @override
  Future<SleepEntry?> getLastSleepEntry() async {
    try {
      final entry = await _database.getLastSleepEntry();
      return entry != null ? SleepEntry.fromMap(entry) : null;
    } catch (e) {
      print('❌ Ошибка получения последней записи сна: $e');
      return null;
    }
  }

  @override
  Future<void> saveSleepEntry(SleepEntry entry) async {
    try {
      await _database.addSleepEntry(entry.toMap());
    } catch (e) {
      print('❌ Ошибка сохранения записи сна: $e');
      rethrow;
    }
  }

  @override
  Future<SleepInsight> analyzeSleepPatterns(List<SleepEntry> entries) async {
    if (entries.isEmpty) {
      return SleepInsight(
        title: 'Недостаточно данных',
        description: 'Добавьте больше записей сна для анализа',
        type: 'pattern',
        confidence: 0.0,
        createdAt: DateTime.now(),
      );
    }

    try {
      final prompt = _generateSleepAnalysisPrompt(entries);
      final response = await _groqClient.generateContentWithRetry(
        model: GroqApiConstants.defaultModel,
        messages: [
          {'role': 'user', 'content': prompt},
        ],
        temperature: 0.7,
        maxTokens: 500,
      );

      if (!response.isValid) {
        return _createFallbackInsight(entries);
      }

      final insight = _parseSleepInsight(response.content, entries);
      return insight;
    } catch (e) {
      print('❌ Ошибка AI анализа сна: $e');
      return _createFallbackInsight(entries);
    }
  }

  @override
  Future<List<SleepInsight>> getSleepRecommendations(
    List<SleepEntry> entries,
    List<dynamic> moodEntries,
  ) async {
    if (entries.isEmpty) {
      return [
        SleepInsight(
          title: 'Начните отслеживать сон',
          description:
              'Добавьте записи сна для получения персональных рекомендаций',
          type: 'recommendation',
          confidence: 0.0,
          createdAt: DateTime.now(),
        ),
      ];
    }

    try {
      final prompt = _generateSleepRecommendationsPrompt(entries, moodEntries);
      final response = await _groqClient.generateContentWithRetry(
        model: GroqApiConstants.defaultModel,
        messages: [
          {'role': 'user', 'content': prompt},
        ],
        temperature: 0.7,
        maxTokens: 600,
      );

      if (!response.isValid) {
        return _createFallbackRecommendations(entries);
      }

      final recommendations = _parseSleepRecommendations(
        response.content,
        entries,
      );
      return recommendations;
    } catch (e) {
      print('❌ Ошибка получения рекомендаций по сну: $e');
      return _createFallbackRecommendations(entries);
    }
  }

  String _generateSleepAnalysisPrompt(List<SleepEntry> entries) {
    final avgDuration = SleepEntry.getAverageDuration(entries);
    final avgQuality = SleepEntry.getAverageQuality(entries);
    final hours = avgDuration ~/ 60;
    final minutes = avgDuration.toInt() % 60;

    final factorsCount = <String, int>{};
    for (final entry in entries) {
      for (final factor in entry.factors) {
        factorsCount[factor] = (factorsCount[factor] ?? 0) + 1;
      }
    }

    final topFactors = factorsCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return '''
Ты — эксперт по анализу сна и здоровому сну в приложении MindSpace.

Проанализируй следующие данные о сне пользователя:

Средняя продолжительность сна: $hoursч $minutesм
Среднее качество сна: ${avgQuality.toStringAsFixed(1)}/5
Количество записей: ${entries.length}

${topFactors.isNotEmpty ? 'Часто встречающиеся факторы:\n${topFactors.take(3).map((e) => '- ${e.key}: ${e.value} раз').join('\n')}' : ''}

Верни JSON с анализом в следующем формате:
{
  "title": "Краткий заголовок инсайта",
  "description": "Подробное описание паттерна или наблюдения",
  "type": "pattern",
  "confidence": 0.8,
  "data": {
    "trend": "improving|stable|declining",
    "keyFindings": ["находка 1", "находка 2"]
  }
}

Анализируй на русском языке, будь конкретным и полезным.
''';
  }

  String _generateSleepRecommendationsPrompt(
    List<SleepEntry> entries,
    List<dynamic> moodEntries,
  ) {
    final avgDuration = SleepEntry.getAverageDuration(entries);
    final avgQuality = SleepEntry.getAverageQuality(entries);
    final hours = avgDuration ~/ 60;

    final recentEntries = entries.take(7).toList();
    final lowQualityDays = recentEntries.where((e) => e.quality <= 2).length;
    final shortSleepDays = recentEntries
        .where((e) => e.durationMinutes < 420)
        .length;

    return '''
Ты — эксперт по здоровому сну в приложении MindSpace.

Данные пользователя:
- Средняя продолжительность: $hoursч
- Среднее качество: ${avgQuality.toStringAsFixed(1)}/5
- Дней с плохим сном: $lowQualityDays из ${recentEntries.length}
- Дней с недостаточным сном: $shortSleepDays из ${recentEntries.length}
- Записей настроения: ${moodEntries.length}

Верни JSON массив с рекомендациями в формате:
[
  {
    "title": "Заголовок рекомендации",
    "description": "Подробное описание рекомендации",
    "type": "recommendation",
    "confidence": 0.9
  }
]

Дай 3-5 конкретных, практичных рекомендаций на русском языке для улучшения сна.
Учитывай связь между сном и настроением, если есть данные.
''';
  }

  SleepInsight _parseSleepInsight(String content, List<SleepEntry> entries) {
    try {
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        return _createFallbackInsight(entries);
      }

      final jsonString = content.substring(jsonStart, jsonEnd);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return SleepInsight(
        title: json['title'] ?? 'Анализ сна',
        description: json['description'] ?? 'Паттерны сна проанализированы',
        type: json['type'] ?? 'pattern',
        confidence: (json['confidence'] ?? 0.7).toDouble(),
        data: json['data'],
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('❌ Ошибка парсинга инсайта: $e');
      return _createFallbackInsight(entries);
    }
  }

  List<SleepInsight> _parseSleepRecommendations(
    String content,
    List<SleepEntry> entries,
  ) {
    try {
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        return _createFallbackRecommendations(entries);
      }

      final jsonString = content.substring(jsonStart, jsonEnd);
      final jsonList = jsonDecode(jsonString) as List<dynamic>;

      return jsonList.map((item) {
        final map = item as Map<String, dynamic>;
        return SleepInsight(
          title: map['title'] ?? 'Рекомендация',
          description: map['description'] ?? 'Рекомендация по улучшению сна',
          type: map['type'] ?? 'recommendation',
          confidence: (map['confidence'] ?? 0.7).toDouble(),
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('❌ Ошибка парсинга рекомендаций: $e');
      return _createFallbackRecommendations(entries);
    }
  }

  SleepInsight _createFallbackInsight(List<SleepEntry> entries) {
    final avgDuration = SleepEntry.getAverageDuration(entries);
    final avgQuality = SleepEntry.getAverageQuality(entries);
    final hours = avgDuration ~/ 60;

    String title;
    String description;

    if (avgQuality >= 4 && hours >= 7) {
      title = 'Отличный сон';
      description =
          'Ваш сон в хорошем состоянии. Продолжайте поддерживать здоровые привычки.';
    } else if (avgQuality <= 2 || hours < 6) {
      title = 'Требуется внимание';
      description =
          'Качество или продолжительность сна ниже нормы. Рекомендуем обратить внимание на режим сна.';
    } else {
      title = 'Стабильный сон';
      description =
          'Ваш сон относительно стабилен. Есть возможности для улучшения.';
    }

    return SleepInsight(
      title: title,
      description: description,
      type: 'pattern',
      confidence: 0.6,
      createdAt: DateTime.now(),
    );
  }

  List<SleepInsight> _createFallbackRecommendations(List<SleepEntry> entries) {
    final avgDuration = SleepEntry.getAverageDuration(entries);
    final avgQuality = SleepEntry.getAverageQuality(entries);
    final hours = avgDuration ~/ 60;

    final recommendations = <SleepInsight>[];

    if (hours < 7) {
      recommendations.add(
        SleepInsight(
          title: 'Увеличьте продолжительность сна',
          description:
              'Рекомендуется спать 7-9 часов для оптимального восстановления',
          type: 'recommendation',
          confidence: 0.9,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (avgQuality <= 3) {
      recommendations.add(
        SleepInsight(
          title: 'Улучшите качество сна',
          description:
              'Создайте комфортные условия для сна: темнота, тишина, прохладная температура',
          type: 'recommendation',
          confidence: 0.8,
          createdAt: DateTime.now(),
        ),
      );
    }

    recommendations.add(
      SleepInsight(
        title: 'Соблюдайте режим',
        description: 'Ложитесь и вставайте в одно и то же время каждый день',
        type: 'recommendation',
        confidence: 0.9,
        createdAt: DateTime.now(),
      ),
    );

    return recommendations;
  }
}
