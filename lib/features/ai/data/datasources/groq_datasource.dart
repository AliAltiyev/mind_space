import 'dart:convert';

import '../../../../core/api/groq_client.dart';
import '../../../../core/database/database.dart';
import '../../../../core/utils/prompt_generator.dart';

/// DataSource для работы с Groq API
class GroqDataSource {
  final GroqClient _client;

  GroqDataSource(this._client);

  /// Получение AI инсайтов
  Future<Map<String, dynamic>> getMoodInsights(List<MoodEntry> entries) async {
    try {
      final prompt = PromptGenerator.generateInsightPrompt(entries);

      final messages = [
        {'role': 'user', 'content': prompt},
      ];

      final response = await _client.generateContentWithRetry(
        model: GroqApiConstants.defaultModel,
        messages: messages,
        temperature: 0.7,
        maxTokens: 800,
      );

      if (!response.isValid) {
        throw Exception('Invalid response from AI');
      }

      return _parseJsonResponse(response.content);
    } catch (e) {
      print('❌ Ошибка в GroqDataSource.getMoodInsights: $e');
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

      final response = await _client.generateContentWithRetry(
        model: GroqApiConstants.defaultModel,
        messages: messages,
        temperature: 0.6,
        maxTokens: 1000,
      );

      if (!response.isValid) {
        throw Exception('Invalid response from AI');
      }

      return _parseJsonResponse(response.content);
    } catch (e) {
      print('❌ Ошибка в GroqDataSource.analyzeMoodPatterns: $e');
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

      final response = await _client.generateContentWithRetry(
        model: GroqApiConstants.defaultModel,
        messages: messages,
        temperature: 0.8,
        maxTokens: 600,
      );

      if (!response.isValid) {
        throw Exception('Invalid response from AI');
      }

      return _parseJsonResponse(response.content);
    } catch (e) {
      print('❌ Ошибка в GroqDataSource.generateGratitudePrompts: $e');
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

      final response = await _client.generateContentWithRetry(
        model: GroqApiConstants.defaultModel,
        messages: messages,
        temperature: 0.7,
        maxTokens: 700,
      );

      if (!response.isValid) {
        throw Exception('Invalid response from AI');
      }

      return _parseJsonResponse(response.content);
    } catch (e) {
      print('❌ Ошибка в GroqDataSource.suggestMeditationSession: $e');
      // Пробрасываем ошибку дальше, чтобы repository мог создать правильный fallback
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
      final parsed = json.decode(jsonString) as Map<String, dynamic>;

      // Проверяем, что это валидная структура медитации
      if (parsed['title'] == null || parsed['instructions'] == null) {
        throw Exception('Invalid meditation structure in response');
      }

      return parsed;
    } catch (e) {
      print('❌ Ошибка парсинга JSON: $e');
      print('📝 Содержимое ответа: $content');
      // Пробрасываем ошибку, чтобы repository мог создать правильный fallback
      rethrow;
    }
  }

  /// Проверка доступности сервиса
  Future<bool> isServiceAvailable() async {
    try {
      final testMessages = [
        {'role': 'user', 'content': 'Тест'},
      ];

      await _client.generateContent(
        model: GroqApiConstants.defaultModel,
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
