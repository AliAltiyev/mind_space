/// Модель запроса к OpenRouter API
class OpenRouterRequest {
  /// Модель AI для использования
  final String model;

  /// Сообщения для контекста
  final List<Map<String, String>> messages;

  /// Температура генерации (0.0 - 1.0)
  final double temperature;

  /// Максимальное количество токенов
  final int maxTokens;

  const OpenRouterRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.7,
    this.maxTokens = 1000,
  });

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };
  }

  /// Создание из JSON
  factory OpenRouterRequest.fromJson(Map<String, dynamic> json) {
    return OpenRouterRequest(
      model: json['model'] as String,
      messages: List<Map<String, String>>.from(
        (json['messages'] as List).map(
          (message) => Map<String, String>.from(message),
        ),
      ),
      temperature: (json['temperature'] ?? 0.7).toDouble(),
      maxTokens: json['max_tokens'] ?? 1000,
    );
  }

  /// Создание копии с изменениями
  OpenRouterRequest copyWith({
    String? model,
    List<Map<String, String>>? messages,
    double? temperature,
    int? maxTokens,
  }) {
    return OpenRouterRequest(
      model: model ?? this.model,
      messages: messages ?? this.messages,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }

  @override
  String toString() {
    return 'OpenRouterRequest(model: $model, messages: ${messages.length}, temperature: $temperature, maxTokens: $maxTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OpenRouterRequest &&
        other.model == model &&
        other.messages.toString() == messages.toString() &&
        other.temperature == temperature &&
        other.maxTokens == maxTokens;
  }

  @override
  int get hashCode {
    return Object.hash(model, messages, temperature, maxTokens);
  }
}

