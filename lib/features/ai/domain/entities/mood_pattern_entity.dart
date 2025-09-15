import 'package:flutter/material.dart';

/// Entity для анализа паттернов настроения
class MoodPatternEntity {
  /// Заголовок анализа
  final String title;

  /// Описание выявленных паттернов
  final String description;

  /// Emoji для визуального представления
  final String emoji;

  /// Акцентный цвет
  final Color accentColor;

  /// Выявленные паттерны
  final List<String> patterns;

  /// Рекомендации на основе анализа
  final List<String> recommendations;

  /// Дата анализа
  final DateTime analyzedAt;

  /// Период анализа (количество дней)
  final int analysisPeriod;

  const MoodPatternEntity({
    required this.title,
    required this.description,
    required this.emoji,
    required this.accentColor,
    required this.patterns,
    required this.recommendations,
    required this.analyzedAt,
    required this.analysisPeriod,
  });

  /// Создание копии с изменениями
  MoodPatternEntity copyWith({
    String? title,
    String? description,
    String? emoji,
    Color? accentColor,
    List<String>? patterns,
    List<String>? recommendations,
    DateTime? analyzedAt,
    int? analysisPeriod,
  }) {
    return MoodPatternEntity(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
      patterns: patterns ?? this.patterns,
      recommendations: recommendations ?? this.recommendations,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      analysisPeriod: analysisPeriod ?? this.analysisPeriod,
    );
  }

  /// Преобразование в Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'accentColor': accentColor.value,
      'patterns': patterns,
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
      'analysisPeriod': analysisPeriod,
    };
  }

  /// Создание из Map
  factory MoodPatternEntity.fromMap(Map<String, dynamic> map) {
    return MoodPatternEntity(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '📊',
      accentColor: Color(map['accentColor'] ?? 0xFF74B9FF),
      patterns: List<String>.from(map['patterns'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      analyzedAt: DateTime.parse(map['analyzedAt']),
      analysisPeriod: map['analysisPeriod'] ?? 0,
    );
  }

  /// Проверка валидности
  bool get isValid =>
      title.isNotEmpty &&
      description.isNotEmpty &&
      emoji.isNotEmpty &&
      patterns.isNotEmpty &&
      recommendations.isNotEmpty;

  /// Получение количества паттернов
  int get patternCount => patterns.length;

  /// Получение количества рекомендаций
  int get recommendationCount => recommendations.length;

  /// Проверка, есть ли важные паттерны
  bool get hasImportantPatterns => patterns.length >= 2;

  /// Проверка, есть ли практические рекомендации
  bool get hasPracticalRecommendations => recommendations.length >= 2;

  @override
  String toString() {
    return 'MoodPatternEntity(title: $title, patterns: ${patterns.length}, recommendations: ${recommendations.length}, period: $analysisPeriodд)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MoodPatternEntity &&
        other.title == title &&
        other.description == description &&
        other.emoji == emoji &&
        other.accentColor == accentColor &&
        other.patterns.toString() == patterns.toString() &&
        other.recommendations.toString() == recommendations.toString() &&
        other.analyzedAt == analyzedAt &&
        other.analysisPeriod == analysisPeriod;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      emoji,
      accentColor,
      patterns,
      recommendations,
      analyzedAt,
      analysisPeriod,
    );
  }
}

