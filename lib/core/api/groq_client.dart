import 'package:dio/dio.dart';

import '../models/openrouter_request.dart';
import '../models/openrouter_response.dart';

/// Константы для Groq API
class GroqApiConstants {
  GroqApiConstants._();

  /// Базовый URL для Groq API
  static const String baseUrl = 'https://api.groq.com/openai/v1';

  /// Эндпоинт для чат-запросов
  static const String chatEndpoint = '/chat/completions';

  /// API ключ (бесплатный, можно получить на console.groq.com)
  /// ВАЖНО: Ключ должен быть получен из настроек приложения или переменных окружения
  /// Получите бесплатный ключ на: https://console.groq.com/keys
  /// Groq предоставляет щедрый бесплатный tier с хорошими лимитами
  ///
  /// Для получения ключа из настроек используйте AppSettingsService
  static String get apiKey {
    // TODO: Получать ключ из настроек приложения или переменных окружения
    // Пример: return AppSettingsService().getGroqApiKey() ?? '';
    return ''; // Пустой ключ по умолчанию - должен быть настроен пользователем
  }

  /// Заголовки по умолчанию
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
  };

  /// Таймауты
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Настройки по умолчанию для запросов
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 1000;

  /// Лимиты для повторных попыток
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Модель по умолчанию (Llama 3.1 70B - очень быстрая и качественная)
  /// Доступные модели: llama-3.1-70b-versatile, llama-3.1-8b-instant, mixtral-8x7b-32768, gemma-7b-it
  static const String defaultModel =
      'llama-3.1-8b-instant'; // Используем более легкую модель для начала

  /// Альтернативные модели
  static const String llama3Model = 'llama-3.1-70b-versatile';
  static const String mixtralModel = 'mixtral-8x7b-32768';
  static const String gemmaModel = 'gemma-7b-it';
}

/// Клиент для работы с Groq API (бесплатный и быстрый)
class GroqClient {
  final Dio _dio;

  GroqClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: GroqApiConstants.baseUrl,
          headers: GroqApiConstants.headers,
          connectTimeout: GroqApiConstants.connectTimeout,
          receiveTimeout: GroqApiConstants.receiveTimeout,
        ),
      );

  /// Генерация контента через Groq API
  Future<OpenRouterResponse> generateContent({
    required String model,
    required List<Map<String, String>> messages,
    double temperature = GroqApiConstants.defaultTemperature,
    int maxTokens = GroqApiConstants.defaultMaxTokens,
  }) async {
    // Проверяем, что API ключ настроен
    if (GroqApiConstants.apiKey.isEmpty ||
        GroqApiConstants.apiKey.length < 20) {
      throw Exception(
        'API ключ Groq не настроен. Получите бесплатный ключ на https://console.groq.com/keys и добавьте его в lib/core/api/groq_client.dart',
      );
    }

    try {
      final request = OpenRouterRequest(
        model: model,
        messages: messages,
        temperature: temperature,
        maxTokens: maxTokens,
      );

      print('🔍 Отправляем запрос к Groq: ${request.model}');
      print('📤 Тело запроса: ${request.toJson()}');

      final response = await _dio.post(
        GroqApiConstants.chatEndpoint,
        data: request.toJson(),
      );

      print('✅ Получен ответ от Groq: ${response.statusCode}');

      return OpenRouterResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Ошибка Groq API: ${e.message ?? 'Unknown error'}');
      print('📋 Тип ошибки: ${e.type}');
      print('📋 URL: ${e.requestOptions.uri}');

      // Логируем детали ошибки для отладки
      if (e.response != null) {
        print('📋 Статус код: ${e.response!.statusCode}');
        print('📋 Тело ответа: ${e.response!.data}');
      } else {
        print('📋 Нет ответа от сервера');
      }

      // Обработка различных типов ошибок
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Превышено время ожидания подключения к AI сервису');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Превышено время ожидания ответа от AI');
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw Exception('Превышено время отправки запроса к AI');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Ошибка подключения к AI сервису. Проверьте интернет-соединение',
        );
      } else if (e.type == DioExceptionType.badResponse) {
        // Обработка ошибок ответа
        if (e.response?.statusCode == 400) {
          // Пытаемся извлечь детали ошибки из ответа
          String errorDetails = 'Неверный формат запроса';
          if (e.response?.data != null) {
            try {
              final errorData = e.response!.data;
              if (errorData is Map) {
                errorDetails =
                    errorData['error']?['message'] ?? errorData.toString();
              } else {
                errorDetails = errorData.toString();
              }
            } catch (_) {
              errorDetails = e.response!.data.toString();
            }
          }
          throw Exception(
            'Неверный формат запроса к Groq API. Проверьте модель и параметры. Детали: $errorDetails',
          );
        } else if (e.response?.statusCode == 401) {
          throw Exception(
            'Неверный API ключ Groq. Получите бесплатный ключ на https://console.groq.com/keys',
          );
        } else if (e.response?.statusCode == 429) {
          throw Exception('Превышен лимит запросов. Попробуйте позже');
        } else if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 500) {
          throw Exception('Ошибка сервера Groq. Попробуйте позже');
        } else {
          // Для badResponse без статус кода
          throw Exception('Ошибка ответа от AI сервиса');
        }
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Запрос к AI сервису был отменен');
      } else if (e.type == DioExceptionType.unknown) {
        // Неизвестная ошибка - может быть проблема с интернетом
        final errorMsg = e.message ?? 'Неизвестная ошибка';
        if (errorMsg.contains('SocketException') ||
            errorMsg.contains('Network') ||
            errorMsg.contains('Failed host lookup')) {
          throw Exception('Нет подключения к интернету. Проверьте соединение');
        }
        throw Exception('Ошибка подключения к AI сервису: $errorMsg');
      } else {
        throw Exception(
          'Ошибка подключения к AI сервису: ${e.message ?? 'Неизвестная ошибка'}',
        );
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
    double temperature = GroqApiConstants.defaultTemperature,
    int maxTokens = GroqApiConstants.defaultMaxTokens,
    int maxRetries = GroqApiConstants.maxRetries,
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

        // Не делаем повторные попытки для клиентских ошибок (400, 401, 403)
        if (errorMessage.contains('400') ||
            errorMessage.contains('401') ||
            errorMessage.contains('403') ||
            errorMessage.contains('Неверный API ключ') ||
            errorMessage.contains('Неверный формат запроса') ||
            errorMessage.contains('API ключ Groq не настроен') ||
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
          seconds: attempt * GroqApiConstants.retryDelay.inSeconds,
        );
        await Future.delayed(delay);
      }
    }

    throw Exception('Превышено максимальное количество попыток');
  }
}
