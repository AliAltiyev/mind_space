import 'dart:ui';

import '../../domain/entities/ai_insight_entity.dart';

/// Модель данных для AI инсайта
class AIInsightModel extends AIInsightEntity {
  const AIInsightModel({
    required super.title,
    required super.description,
    required super.emoji,
    required super.accentColor,
    required super.suggestions,
    required super.createdAt,
    super.confidence,
  });

  /// Создание из JSON
  factory AIInsightModel.fromJson(Map<String, dynamic> json) {
    return AIInsightModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '💭',
      accentColor: Color(
        int.parse(
          json['accentColor']?.toString().replaceFirst('#', '0xFF') ??
              '0xFF4ECDC4',
        ),
      ),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      createdAt: DateTime.now(),
      confidence: (json['confidence'] ?? 1.0).toDouble(),
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'accentColor': '#${accentColor.value.toRadixString(16).substring(2)}',
      'suggestions': suggestions,
      'createdAt': createdAt.toIso8601String(),
      'confidence': confidence,
    };
  }

  /// Создание из entity
  factory AIInsightModel.fromEntity(AIInsightEntity entity) {
    return AIInsightModel(
      title: entity.title,
      description: entity.description,
      emoji: entity.emoji,
      accentColor: entity.accentColor,
      suggestions: entity.suggestions,
      createdAt: entity.createdAt,
      confidence: entity.confidence,
    );
  }

  /// Преобразование в entity
  AIInsightEntity toEntity() {
    return AIInsightEntity(
      title: title,
      description: description,
      emoji: emoji,
      accentColor: accentColor,
      suggestions: suggestions,
      createdAt: createdAt,
      confidence: confidence,
    );
  }

  /// Создание копии с изменениями
  @override
  AIInsightModel copyWith({
    String? title,
    String? description,
    String? emoji,
    Color? accentColor,
    List<String>? suggestions,
    DateTime? createdAt,
    double? confidence,
  }) {
    return AIInsightModel(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
      suggestions: suggestions ?? this.suggestions,
      createdAt: createdAt ?? this.createdAt,
      confidence: confidence ?? this.confidence,
    );
  }
}

