import '../services/app_settings_service.dart';

/// Константы для работы с OpenRouter API
class OpenRouterConstants {
  OpenRouterConstants._();

  /// Базовый URL для OpenRouter API
  static const String baseUrl = 'https://openrouter.ai/api/v1';

  /// Эндпоинт для чат-запросов
  static const String chatEndpoint = '/chat/completions';

  /// API ключ (получается из безопасного хранилища)
  /// ВАЖНО: Ключ должен быть получен из настроек приложения через AppSettingsService
  /// БЕЗОПАСНОСТЬ: API ключи НИКОГДА не должны быть захардкожены в коде!
  static Future<String> get apiKey async {
    final settingsService = AppSettingsService();
    final apiKey = await settingsService.getOpenRouterApiKey();
    return apiKey ?? '';
  }

  /// Модель по умолчанию
  static const String defaultModel = 'anthropic/claude-3.5-sonnet';

  /// Альтернативные модели
  static const String gpt4Model = 'openai/gpt-4o';
  static const String claudeModel = 'anthropic/claude-3.5-sonnet';
  static const String geminiModel = 'google/gemini-pro';

  /// Заголовки по умолчанию
  /// ВАЖНО: Используйте getHeaders() вместо headers для получения актуального API ключа
  static Future<Map<String, String>> getHeaders() async {
    final key = await apiKey;
    return {
      'Content-Type': 'application/json',
      if (key.isNotEmpty) 'Authorization': 'Bearer $key',
      'HTTP-Referer': 'https://mindspace.app',
      'X-Title': 'MindSpace - Mental Wellness App',
    };
  }

  /// Устаревший метод - используйте getHeaders() вместо этого
  @Deprecated('Use getHeaders() instead to get the API key from secure storage')
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://mindspace.app',
        'X-Title': 'MindSpace - Mental Wellness App',
        // API ключ больше не доступен синхронно
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

  /// Настройки кэширования
  static const Duration cacheMaxAge = Duration(hours: 1);
  static const String cacheBoxName = 'ai_cache';
}
