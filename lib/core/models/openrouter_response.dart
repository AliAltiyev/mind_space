/// Модель ответа от AI API (совместима с OpenAI/Groq форматом)
class OpenRouterResponse {
  /// ID ответа
  final String id;

  /// Модель, которая была использована
  final String model;

  /// Сгенерированный контент
  final String content;

  /// Количество использованных токенов
  final int? usageTokens;

  /// Время создания
  final DateTime createdAt;

  const OpenRouterResponse({
    required this.id,
    required this.model,
    required this.content,
    this.usageTokens,
    required this.createdAt,
  });

  /// Создание из JSON
  factory OpenRouterResponse.fromJson(Map<String, dynamic> json) {
    final choices = json['choices'] as List;
    final message = choices.first['message'] as Map<String, dynamic>;

    return OpenRouterResponse(
      id: json['id'] as String,
      model: json['model'] as String,
      content: message['content'] as String,
      usageTokens: json['usage']?['total_tokens'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['created'] as int) * 1000,
      ),
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'content': content,
      'usage_tokens': usageTokens,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Создание копии с изменениями
  OpenRouterResponse copyWith({
    String? id,
    String? model,
    String? content,
    int? usageTokens,
    DateTime? createdAt,
  }) {
    return OpenRouterResponse(
      id: id ?? this.id,
      model: model ?? this.model,
      content: content ?? this.content,
      usageTokens: usageTokens ?? this.usageTokens,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Проверка, является ли ответ валидным
  bool get isValid => content.isNotEmpty && content.trim().isNotEmpty;

  /// Получение длины контента
  int get contentLength => content.length;

  /// Проверка, является ли ответ коротким
  bool get isShort => contentLength < 100;

  /// Проверка, является ли ответ длинным
  bool get isLong => contentLength > 1000;

  @override
  String toString() {
    return 'OpenRouterResponse(id: $id, model: $model, contentLength: $contentLength, usageTokens: $usageTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OpenRouterResponse &&
        other.id == id &&
        other.model == model &&
        other.content == content &&
        other.usageTokens == usageTokens &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, model, content, usageTokens, createdAt);
  }
}
