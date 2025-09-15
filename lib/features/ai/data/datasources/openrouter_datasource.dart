import 'dart:convert';

import '../../../../core/api/openrouter_client.dart';
import '../../../../core/database/database.dart';
import '../../../../core/utils/prompt_generator.dart';

/// DataSource для работы с OpenRouter API
class OpenRouterDataSource {
  final OpenRouterClient _client;

  OpenRouterDataSource(this._client);

  /// Получение AI инсайтов
  Future<Map<String, dynamic>> getMoodInsights(List<MoodEntry> entries) async {
    try {
      final prompt = PromptGenerator.generateInsightPrompt(entries);

      final messages = [
        {'role': 'user', 'content': prompt},
      ];

      final response = await _client.generateMoodInsights(messages: messages);

      if (!response.isValid) {
        throw Exception('Invalid response from AI');
      }

      return _parseJsonResponse(response.content);
    } catch (e) {
      print('❌ Ошибка в OpenRouterDataSource.getMoodInsights: $e');
      rethrow;
    }
  }

  /// Анализ паттернов настроения
  Future<Map<String, dynamic>> analyzeMoodPatterns(
    List<MoodEntry> moodHistory,
  ) async {
    try {
      final prompt = PromptGenerator.generatePatternPrompt(moodHistory);

      final messages = [
        {'role': 'user', 'content': prompt},
      ];

      final response = await _client.generatePatternAnalysis(
        messages: messages,
      );

      if (!response.isValid) {
        throw Exception('Invalid response from AI');
      }

      return _parseJsonResponse(response.content);
    } catch (e) {
      print('❌ Ошибка в OpenRouterDataSource.analyzeMoodPatterns: $e');
      rethrow;
    }
  }

  /// Генерация благодарственных предложений
  Future<Map<String, dynamic>> generateGratitudePrompts(
    List<MoodEntry> recentMoods,
  ) async {
    try {
      final prompt = PromptGenerator.generateGratitudePrompt(recentMoods);

      final messages = [
        {'role': 'user', 'content': prompt},
      ];

      final response = await _client.generateGratitudePrompts(
        messages: messages,
      );

      if (!response.isValid) {
        throw Exception('Invalid response from AI');
      }

      return _parseJsonResponse(response.content);
    } catch (e) {
      print('❌ Ошибка в OpenRouterDataSource.generateGratitudePrompts: $e');
      rethrow;
    }
  }

  /// Предложение медитационных сессий
  Future<Map<String, dynamic>> suggestMeditationSession(
    List<MoodEntry> recentMoods,
  ) async {
    try {
      final prompt = PromptGenerator.generateMeditationPrompt(recentMoods);

      final messages = [
        {'role': 'user', 'content': prompt},
      ];

      final response = await _client.generateMeditationSessions(
        messages: messages,
      );

      if (!response.isValid) {
        throw Exception('Invalid response from AI');
      }

      return _parseJsonResponse(response.content);
    } catch (e) {
      print('❌ Ошибка в OpenRouterDataSource.suggestMeditationSession: $e');
      rethrow;
    }
  }

  /// Парсинг JSON ответа от AI
  Map<String, dynamic> _parseJsonResponse(String content) {
    try {
      // Пытаемся найти JSON в ответе
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No JSON found in response');
      }

      final jsonString = content.substring(jsonStart, jsonEnd);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Ошибка парсинга JSON: $e');
      print('📝 Содержимое ответа: $content');

      // Возвращаем fallback ответ
      return _createFallbackResponse();
    }
  }

  /// Создание fallback ответа при ошибке
  Map<String, dynamic> _createFallbackResponse() {
    return {
      'title': 'AI временно недоступен',
      'description': 'Попробуйте позже или обратитесь к специалисту',
      'emoji': '🤖',
      'accentColor': '#FF6B6B',
      'suggestions': ['Попробуйте позже', 'Обратитесь к специалисту'],
    };
  }

  /// Проверка доступности сервиса
  Future<bool> isServiceAvailable() async {
    try {
      final testMessages = [
        {'role': 'user', 'content': 'Тест'},
      ];

      await _client.generateContent(
        model: 'anthropic/claude-3.5-sonnet',
        messages: testMessages,
        maxTokens: 10,
      );

      return true;
    } catch (e) {
      print('❌ AI сервис недоступен: $e');
      return false;
    }
  }
}
