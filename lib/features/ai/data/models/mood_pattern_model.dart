import 'dart:ui';

import '../../domain/entities/mood_pattern_entity.dart';

/// Модель данных для анализа паттернов настроения
class MoodPatternModel extends MoodPatternEntity {
  const MoodPatternModel({
    required super.title,
    required super.description,
    required super.emoji,
    required super.accentColor,
    required super.patterns,
    required super.recommendations,
    required super.analyzedAt,
    required super.analysisPeriod,
  });

  /// Создание из JSON
  factory MoodPatternModel.fromJson(Map<String, dynamic> json) {
    return MoodPatternModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '📊',
      accentColor: Color(
        int.parse(
          json['accentColor']?.toString().replaceFirst('#', '0xFF') ??
              '0xFF74B9FF',
        ),
      ),
      patterns: List<String>.from(json['patterns'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      analyzedAt: DateTime.now(),
      analysisPeriod: json['analysisPeriod'] ?? 0,
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'accentColor': '#${accentColor.value.toRadixString(16).substring(2)}',
      'patterns': patterns,
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
      'analysisPeriod': analysisPeriod,
    };
  }

  /// Создание из entity
  factory MoodPatternModel.fromEntity(MoodPatternEntity entity) {
    return MoodPatternModel(
      title: entity.title,
      description: entity.description,
      emoji: entity.emoji,
      accentColor: entity.accentColor,
      patterns: entity.patterns,
      recommendations: entity.recommendations,
      analyzedAt: entity.analyzedAt,
      analysisPeriod: entity.analysisPeriod,
    );
  }

  /// Преобразование в entity
  MoodPatternEntity toEntity() {
    return MoodPatternEntity(
      title: title,
      description: description,
      emoji: emoji,
      accentColor: accentColor,
      patterns: patterns,
      recommendations: recommendations,
      analyzedAt: analyzedAt,
      analysisPeriod: analysisPeriod,
    );
  }

  /// Создание копии с изменениями
  @override
  MoodPatternModel copyWith({
    String? title,
    String? description,
    String? emoji,
    Color? accentColor,
    List<String>? patterns,
    List<String>? recommendations,
    DateTime? analyzedAt,
    int? analysisPeriod,
  }) {
    return MoodPatternModel(
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
}

