/// Константы для OpenRouter API
class OpenRouterConstants {
  OpenRouterConstants._();

  /// Базовый URL для OpenRouter API
  static const String baseUrl = 'https://openrouter.ai/api/v1';

  /// Эндпоинт для чат-запросов
  static const String chatEndpoint = '/chat/completions';

  /// API ключ (получите на openrouter.ai)
  /// ВАЖНО: Ключ должен быть получен из настроек приложения или переменных окружения
  static String get apiKey {
    // TODO: Получать ключ из настроек приложения или переменных окружения
    // Пример: return AppSettingsService().getOpenRouterApiKey() ?? '';
    return ''; // Пустой ключ по умолчанию - должен быть настроен пользователем
  }

  /// Заголовки по умолчанию
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://mindspace.app', // Опционально, для отслеживания
    'X-Title': 'Mind Space', // Опционально, название приложения
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

  /// Модели по умолчанию
  static const String claudeModel = 'anthropic/claude-3-haiku';
  static const String gpt4Model = 'openai/gpt-4-turbo';
  static const String defaultModel = claudeModel;
}
