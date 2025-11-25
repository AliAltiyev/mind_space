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
          connectTimeout: OpenRouterConstants.connectTimeout,
          receiveTimeout: OpenRouterConstants.receiveTimeout,
          responseType: ResponseType.json, // Явно указываем тип ответа
          validateStatus: (status) =>
              status != null && status < 500, // Принимаем статусы < 500
        ),
      );

  /// Обновление заголовков Dio клиента с актуальным API ключом
  Future<void> _updateHeaders() async {
    final headers = await OpenRouterConstants.getHeaders();
    _dio.options.headers = headers;
  }

  /// Генерация контента через OpenRouter API
  Future<OpenRouterResponse> generateContent({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = OpenRouterConstants.defaultTemperature,
    int maxTokens = OpenRouterConstants.defaultMaxTokens,
  }) async {
    // Обновляем заголовки с актуальным API ключом перед каждым запросом
    await _updateHeaders();

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

      // Проверяем статус ответа
      if (response.statusCode != 200) {
        throw Exception(
          'OpenRouter API вернул ошибку: ${response.statusCode} - ${response.statusMessage}',
        );
      }

      // Обрабатываем ответ
      Map<String, dynamic> jsonData;

      if (response.data is Map<String, dynamic>) {
        jsonData = response.data as Map<String, dynamic>;
      } else {
        print('❌ Неожиданный тип ответа: ${response.data.runtimeType}');
        // Пытаемся получить строковое представление для отладки
        final dataString = response.data.toString();
        final preview = dataString.length > 1000
            ? '${dataString.substring(0, 1000)}... (обрезано)'
            : dataString;
        print('📄 Содержимое ответа (первые 1000 символов): $preview');
        throw FormatException(
          'Invalid response format: expected JSON object, got ${response.data.runtimeType}',
        );
      }

      return OpenRouterResponse.fromJson(jsonData);
    } on FormatException catch (e) {
      print('❌ Ошибка парсинга JSON: $e');
      // Если это ошибка на конкретной строке, выводим больше информации
      if (e.message.contains('line')) {
        print(
          '⚠️ Возможно, ответ от API был обрезан или содержит невалидный JSON',
        );
        print('💡 Проверьте: размер ответа, таймауты, лимиты токенов');
      }
      throw Exception('Ошибка обработки ответа от AI: ${e.message}');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      // Проверяем, не является ли это ошибкой парсинга JSON
      if (e.error is FormatException) {
        final formatError = e.error as FormatException;
        print('❌ Ошибка парсинга JSON в Dio: ${formatError.message}');
        print(
          '⚠️ Возможно, ответ от API был обрезан или содержит невалидный JSON',
        );
        if (e.response?.data != null) {
          try {
            final dataString = e.response!.data.toString();
            final preview = dataString.length > 500
                ? '${dataString.substring(0, 500)}... (обрезано)'
                : dataString;
            print('📄 Содержимое ответа (первые 500 символов): $preview');
          } catch (_) {
            print('📄 Не удалось получить содержимое ответа');
          }
        }
        throw Exception(
          'Ошибка обработки ответа от AI: JSON ответ содержит ошибку на ${formatError.message.contains('line') ? formatError.message.split('line')[1].split(',')[0] : 'неизвестной строке'}. Возможно, ответ был обрезан.',
        );
      }

      final errorMessage = e.response?.data?['error']?['message'] ?? e.message;

      print('❌ Ошибка OpenRouter API: ${e.message}');
      if (statusCode != null) {
        print('📊 Код статуса: $statusCode');
      }
      if (errorMessage != null && errorMessage != e.message) {
        print('📝 Сообщение об ошибке: $errorMessage');
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Превышено время ожидания ответа от AI. Проверьте подключение к интернету.',
        );
      } else if (statusCode == 401) {
        throw Exception('Неверный API ключ. Проверьте настройки API.');
      } else if (statusCode == 402) {
        throw Exception(
          'Недостаточно средств на балансе OpenRouter. Пополните баланс на openrouter.ai',
        );
      } else if (statusCode == 403) {
        throw Exception('Доступ запрещен. Проверьте права доступа API ключа.');
      } else if (statusCode == 429) {
        throw Exception('Превышен лимит запросов. Попробуйте позже.');
      } else if (statusCode != null && statusCode >= 500) {
        throw Exception('Ошибка сервера OpenRouter. Попробуйте позже.');
      } else {
        throw Exception('Ошибка API: ${errorMessage ?? e.message}');
      }
    } catch (e) {
      print('❌ Неожиданная ошибка: $e');
      if (e is TypeError) {
        throw Exception('Ошибка типа данных в ответе API: $e');
      }
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

        // Не делаем повторные попытки для ошибок, которые не могут быть исправлены
        final isNonRetryableError =
            errorMessage.contains('Неверный API ключ') ||
            errorMessage.contains('Недостаточно средств') ||
            errorMessage.contains('Доступ запрещен') ||
            errorMessage.contains('402') ||
            errorMessage.contains('401') ||
            errorMessage.contains('403');

        if (isNonRetryableError) {
          print('⚠️ Ошибка не может быть исправлена повторной попыткой: $e');
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
