/// AI инсайт о сне
class SleepInsight {
  final String title;
  final String description;
  final String type; // pattern, recommendation, correlation
  final double confidence;
  final Map<String, dynamic>? data; // Дополнительные данные
  final DateTime createdAt;

  SleepInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.confidence,
    this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'confidence': confidence,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SleepInsight.fromMap(Map<String, dynamic> map) {
    return SleepInsight(
      title: map['title'],
      description: map['description'],
      type: map['type'],
      confidence: map['confidence']?.toDouble() ?? 0.0,
      data: map['data'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

/// Типы инсайтов о сне
enum SleepInsightType {
  pattern, // Паттерн
  recommendation, // Рекомендация
  correlation, // Корреляция с настроением
  warning, // Предупреждение
}



