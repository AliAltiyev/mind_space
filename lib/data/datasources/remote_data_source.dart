import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api/groq_client.dart';
import '../../core/database/database.dart';
import '../../domain/entities/ai_insight.dart';

/// Удаленный источник данных для AI инсайтов
class RemoteDataSource {
  final Dio _dio;

  RemoteDataSource(this._dio);

  /// Получение AI инсайтов на основе записей настроения
  Future<AIInsight> getMoodInsights(List<MoodEntry> entries) async {
    try {
      // Подготавливаем данные для AI
      final moodData = _prepareMoodDataForAI(entries);

      // Формируем промпт для AI
      final prompt = _createMoodAnalysisPrompt(moodData);

      print('🔍 Отправляем запрос к AI с данными: ${entries.length} записей');

      // Отправляем запрос к Groq API
      // Импортируем GroqApiConstants для использования API ключа
      final apiKey = GroqApiConstants.apiKey;
      if (apiKey.isEmpty) {
        throw Exception(
          'Groq API ключ не настроен. Получите бесплатный ключ на https://console.groq.com/keys',
        );
      }

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''Ты - эксперт по анализу настроения и психологическому благополучию. 
              Анализируй данные о настроении пользователя и предоставляй полезные, поддерживающие инсайты.
              
              Отвечай ТОЛЬКО в формате JSON:
              {
                "title": "Краткий заголовок инсайта (максимум 30 символов)",
                "description": "Подробное описание инсайта с практическими советами (максимум 150 символов)",
                "emoji": "Подходящий emoji для инсайта",
                "accentColor": "hex код цвета (например, #FF6B6B)"
              }
              
              Цвета для разных типов инсайтов:
              - Позитивные: #4ECDC4, #45B7D1, #96CEB4
              - Нейтральные: #FFEAA7, #DDA0DD, #98D8C8
              - Предупреждающие: #FD79A8, #FDCB6E, #E17055
              - Мотивирующие: #A8E6CF, #FFD93D, #6BCF7F''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        },
      );

      print('✅ Получен ответ от AI: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];

        print('📝 AI ответ: $content');

        // Парсим JSON ответ
        final jsonResponse = json.decode(content);

        return AIInsight(
          title: jsonResponse['title'] ?? 'Инсайт',
          description:
              jsonResponse['description'] ??
              'Интересное наблюдение о вашем настроении.',
          emoji: jsonResponse['emoji'] ?? '💭',
          accentColor: Color(
            int.parse(jsonResponse['accentColor'].replaceFirst('#', '0xFF')),
          ),
        );
      } else {
        print('❌ Ошибка API: ${response.statusCode}');
        throw Exception('Failed to get AI insights: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка при получении AI инсайтов: $e');
      // Возвращаем fallback инсайт в случае ошибки
      return _createFallbackInsight(entries);
    }
  }

  /// Подготовка данных о настроении для AI
  Map<String, dynamic> _prepareMoodDataForAI(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'averageMood': 0,
        'moodTrend': 'no_data',
        'recentEntries': [],
        'notes': [],
      };
    }

    // Вычисляем среднее настроение
    final averageMood =
        entries.map((e) => e.moodValue).reduce((a, b) => a + b) /
        entries.length;

    // Определяем тренд настроения
    String moodTrend = 'stable';
    if (entries.length >= 2) {
      final recent = entries.take(3).map((e) => e.moodValue).toList();
      final older = entries
          .skip(entries.length - 3)
          .map((e) => e.moodValue)
          .toList();

      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      final olderAvg = older.reduce((a, b) => a + b) / older.length;

      if (recentAvg > olderAvg + 0.5) {
        moodTrend = 'improving';
      } else if (recentAvg < olderAvg - 0.5) {
        moodTrend = 'declining';
      }
    }

    // Собираем заметки
    final notes = entries
        .where((e) => e.note != null && e.note!.isNotEmpty)
        .map((e) => e.note!)
        .toList();

    return {
      'totalEntries': entries.length,
      'averageMood': averageMood,
      'moodTrend': moodTrend,
      'recentEntries': entries
          .take(5)
          .map(
            (e) => {
              'mood': e.moodValue,
              'date': e.createdAt.toIso8601String(),
              'note': e.note,
            },
          )
          .toList(),
      'notes': notes,
    };
  }

  /// Создание промпта для AI анализа
  String _createMoodAnalysisPrompt(Map<String, dynamic> moodData) {
    final buffer = StringBuffer();

    buffer.writeln('Проанализируй данные о настроении пользователя:');
    buffer.writeln();
    buffer.writeln('Общая информация:');
    buffer.writeln('- Всего записей: ${moodData['totalEntries']}');
    buffer.writeln(
      '- Среднее настроение: ${moodData['averageMood'].toStringAsFixed(1)}/5',
    );
    buffer.writeln('- Тренд: ${_getMoodTrendText(moodData['moodTrend'])}');
    buffer.writeln();

    if (moodData['recentEntries'].isNotEmpty) {
      buffer.writeln('Последние записи:');
      for (final entry in moodData['recentEntries']) {
        buffer.writeln(
          '- ${entry['mood']}/5 - ${entry['note'] ?? 'без заметки'}',
        );
      }
      buffer.writeln();
    }

    if (moodData['notes'].isNotEmpty) {
      buffer.writeln('Заметки пользователя:');
      for (final note in moodData['notes']) {
        buffer.writeln('- $note');
      }
    }

    buffer.writeln();
    buffer.writeln(
      'Предоставь полезный, поддерживающий инсайт или совет на основе этих данных.',
    );

    return buffer.toString();
  }

  /// Получение текстового описания тренда
  String _getMoodTrendText(String trend) {
    switch (trend) {
      case 'improving':
        return 'улучшается';
      case 'declining':
        return 'ухудшается';
      case 'stable':
        return 'стабильное';
      default:
        return 'неопределенный';
    }
  }

  /// Создание fallback инсайта в случае ошибки
  AIInsight _createFallbackInsight(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return AIInsight(
        title: 'Начните отслеживать настроение',
        description:
            'Добавьте первую запись о своем настроении, чтобы получить персональные инсайты.',
        emoji: '🌟',
        accentColor: const Color(0xFF4ECDC4),
      );
    }

    final averageMood =
        entries.map((e) => e.moodValue).reduce((a, b) => a + b) /
        entries.length;

    if (averageMood >= 4) {
      return AIInsight(
        title: 'Отличное настроение!',
        description:
            'Вы поддерживаете позитивный настрой. Продолжайте в том же духе!',
        emoji: '😊',
        accentColor: const Color(0xFF96CEB4),
      );
    } else if (averageMood >= 3) {
      return AIInsight(
        title: 'Стабильное состояние',
        description:
            'Ваше настроение находится в хорошем балансе. Это отличная основа!',
        emoji: '😌',
        accentColor: const Color(0xFFE17055),
      );
    } else {
      return AIInsight(
        title: 'Забота о себе',
        description:
            'Важно заботиться о своем эмоциональном благополучии. Маленькие шаги каждый день.',
        emoji: '🤗',
        accentColor: const Color(0xFFFD79A8),
      );
    }
  }
}
