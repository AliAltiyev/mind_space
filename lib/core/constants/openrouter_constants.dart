/// Константы для работы с OpenRouter API
class OpenRouterConstants {
  OpenRouterConstants._();

  /// Базовый URL для OpenRouter API
  static const String baseUrl = 'https://openrouter.ai/api/v1';

  /// Эндпоинт для чат-запросов
  static const String chatEndpoint = '/chat/completions';

  /// API ключ (будет инжектирован через DI)
  static const String apiKey =
      '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';

  /// Модель по умолчанию
  static const String defaultModel = 'anthropic/claude-3.5-sonnet';

  /// Альтернативные модели
  static const String gpt4Model = 'openai/gpt-4o';
  static const String claudeModel = 'anthropic/claude-3.5-sonnet';
  static const String geminiModel = 'google/gemini-pro';

  /// Заголовки по умолчанию
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'HTTP-Referer': 'https://mindspace.app',
    'X-Title': 'MindSpace - Mental Wellness App',
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

