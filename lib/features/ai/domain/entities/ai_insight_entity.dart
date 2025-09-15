import 'package:flutter/material.dart';

/// Entity для AI инсайта
class AIInsightEntity {
  /// Заголовок инсайта
  final String title;

  /// Подробное описание
  final String description;

  /// Emoji для визуального представления
  final String emoji;

  /// Акцентный цвет
  final Color accentColor;

  /// Практические советы
  final List<String> suggestions;

  /// Дата создания
  final DateTime createdAt;

  /// Уровень уверенности AI (0.0 - 1.0)
  final double confidence;

  const AIInsightEntity({
    required this.title,
    required this.description,
    required this.emoji,
    required this.accentColor,
    required this.suggestions,
    required this.createdAt,
    this.confidence = 1.0,
  });

  /// Создание копии с изменениями
  AIInsightEntity copyWith({
    String? title,
    String? description,
    String? emoji,
    Color? accentColor,
    List<String>? suggestions,
    DateTime? createdAt,
    double? confidence,
  }) {
    return AIInsightEntity(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
      suggestions: suggestions ?? this.suggestions,
      createdAt: createdAt ?? this.createdAt,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Преобразование в Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'accentColor': accentColor.value,
      'suggestions': suggestions,
      'createdAt': createdAt.toIso8601String(),
      'confidence': confidence,
    };
  }

  /// Создание из Map
  factory AIInsightEntity.fromMap(Map<String, dynamic> map) {
    return AIInsightEntity(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '💭',
      accentColor: Color(map['accentColor'] ?? 0xFF4ECDC4),
      suggestions: List<String>.from(map['suggestions'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      confidence: (map['confidence'] ?? 1.0).toDouble(),
    );
  }

  /// Проверка валидности
  bool get isValid =>
      title.isNotEmpty &&
      description.isNotEmpty &&
      emoji.isNotEmpty &&
      suggestions.isNotEmpty;

  /// Получение длины заголовка
  int get titleLength => title.length;

  /// Получение длины описания
  int get descriptionLength => description.length;

  /// Проверка, является ли инсайт коротким
  bool get isShort => titleLength <= 30 && descriptionLength <= 150;

  /// Проверка, является ли инсайт длинным
  bool get isLong => titleLength > 50 || descriptionLength > 300;

  /// Получение количества советов
  int get suggestionCount => suggestions.length;

  @override
  String toString() {
    return 'AIInsightEntity(title: $title, description: $description, emoji: $emoji, suggestions: ${suggestions.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AIInsightEntity &&
        other.title == title &&
        other.description == description &&
        other.emoji == emoji &&
        other.accentColor == accentColor &&
        other.suggestions.toString() == suggestions.toString() &&
        other.createdAt == createdAt &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      emoji,
      accentColor,
      suggestions,
      createdAt,
      confidence,
    );
  }
}

