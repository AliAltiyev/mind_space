import 'package:dio/dio.dart';

import '../constants/openrouter_constants.dart';
import '../models/openrouter_request.dart';
import '../models/openrouter_response.dart';

/// Клиент для работы с OpenRouter API
class OpenRouterClient {
  final Dio _dio;

  OpenRouterClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: OpenRouterConstants.baseUrl,
          headers: OpenRouterConstants.headers,
          connectTimeout: OpenRouterConstants.connectTimeout,
          receiveTimeout: OpenRouterConstants.receiveTimeout,
        ),
      );

  /// Генерация контента через OpenRouter API
  Future<OpenRouterResponse> generateContent({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = OpenRouterConstants.defaultTemperature,
    int maxTokens = OpenRouterConstants.defaultMaxTokens,
  }) async {
    try {
      final request = OpenRouterRequest(
        model: model,
        messages: messages,
        temperature: temperature,
        maxTokens: maxTokens,
      );

      print('🔍 Отправляем запрос к OpenRouter: ${request.model}');

      final response = await _dio.post(
        OpenRouterConstants.chatEndpoint,
        data: request.toJson(),
      );

      print('✅ Получен ответ от OpenRouter: ${response.statusCode}');

      return OpenRouterResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Ошибка OpenRouter API: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания ответа от AI');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Неверный API ключ');
      } else if (e.response?.statusCode == 402) {
        throw Exception(
          'Недостаточно средств на балансе OpenRouter. Пополните баланс на openrouter.ai',
        );
      } else if (e.response?.statusCode == 403) {
        throw Exception('Доступ запрещен. Проверьте API ключ');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Превышен лимит запросов. Попробуйте позже');
      } else if (e.response?.statusCode != null &&
          e.response!.statusCode! >= 500) {
        throw Exception('Ошибка сервера. Попробуйте позже');
      } else {
        throw Exception('Ошибка подключения к AI сервису');
      }
    } catch (e) {
      print('❌ Неожиданная ошибка: $e');
      throw Exception('Неожиданная ошибка: $e');
    }
  }

  /// Генерация контента с повторными попытками
  Future<OpenRouterResponse> generateContentWithRetry({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = OpenRouterConstants.defaultTemperature,
    int maxTokens = OpenRouterConstants.defaultMaxTokens,
    int maxRetries = OpenRouterConstants.maxRetries,
  }) async {
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await generateContent(
          model: model,
          messages: messages,
          temperature: temperature,
          maxTokens: maxTokens,
        );
      } catch (e) {
        final errorMessage = e.toString();

        // Не делаем повторные попытки для клиентских ошибок (401, 402, 403)
        // Эти ошибки не исправятся повторными попытками
        if (errorMessage.contains('401') ||
            errorMessage.contains('402') ||
            errorMessage.contains('403') ||
            errorMessage.contains('Неверный API ключ') ||
            errorMessage.contains('Недостаточно средств') ||
            errorMessage.contains('Доступ запрещен')) {
          print('❌ Клиентская ошибка, повторные попытки не помогут: $e');
          rethrow;
        }

        print('🔄 Попытка $attempt/$maxRetries неудачна: $e');

        if (attempt == maxRetries) {
          rethrow;
        }

        // Экспоненциальная задержка между попытками
        final delay = Duration(
          seconds: attempt * OpenRouterConstants.retryDelay.inSeconds,
        );
        await Future.delayed(delay);
      }
    }

    throw Exception('Превышено максимальное количество попыток');
  }

  /// Генерация инсайтов настроения
  Future<OpenRouterResponse> generateMoodInsights({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
  }) async {
    return generateContentWithRetry(
      model: OpenRouterConstants.claudeModel,
      messages: messages,
      temperature: temperature,
      maxTokens: 800,
    );
  }

  /// Генерация анализа паттернов
  Future<OpenRouterResponse> generatePatternAnalysis({
    required List<Map<String, String>> messages,
    double temperature = 0.6,
  }) async {
    return generateContentWithRetry(
      model: OpenRouterConstants.claudeModel,
      messages: messages,
      temperature: temperature,
      maxTokens: 1000,
    );
  }

  /// Генерация благодарственных промптов
  Future<OpenRouterResponse> generateGratitudePrompts({
    required List<Map<String, String>> messages,
    double temperature = 0.8,
  }) async {
    return generateContentWithRetry(
      model: OpenRouterConstants.gpt4Model,
      messages: messages,
      temperature: temperature,
      maxTokens: 600,
    );
  }

  /// Генерация медитационных сессий
  Future<OpenRouterResponse> generateMeditationSessions({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
  }) async {
    return generateContentWithRetry(
      model: OpenRouterConstants.claudeModel,
      messages: messages,
      temperature: temperature,
      maxTokens: 700,
    );
  }
}
