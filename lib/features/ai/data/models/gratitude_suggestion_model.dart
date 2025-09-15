import 'package:flutter/material.dart';

import '../../domain/entities/gratitude_entity.dart';

/// Модель данных для благодарственных предложений
class GratitudeSuggestionModel extends GratitudeEntity {
  const GratitudeSuggestionModel({
    required super.title,
    required super.description,
    required super.emoji,
    required super.accentColor,
    required super.prompts,
    required super.createdAt,
    required super.category,
  });

  /// Создание из JSON
  factory GratitudeSuggestionModel.fromJson(Map<String, dynamic> json) {
    return GratitudeSuggestionModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🙏',
      accentColor: Color(
        int.parse(
          json['accentColor']?.toString().replaceFirst('#', '0xFF') ??
              '0xFFFFD93D',
        ),
      ),
      prompts: List<String>.from(json['prompts'] ?? []),
      createdAt: DateTime.now(),
      category: GratitudeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => GratitudeCategory.general,
      ),
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'accentColor': '#${accentColor.value.toRadixString(16).substring(2)}',
      'prompts': prompts,
      'createdAt': createdAt.toIso8601String(),
      'category': category.name,
    };
  }

  /// Создание из entity
  factory GratitudeSuggestionModel.fromEntity(GratitudeEntity entity) {
    return GratitudeSuggestionModel(
      title: entity.title,
      description: entity.description,
      emoji: entity.emoji,
      accentColor: entity.accentColor,
      prompts: entity.prompts,
      createdAt: entity.createdAt,
      category: entity.category,
    );
  }

  /// Преобразование в entity
  GratitudeEntity toEntity() {
    return GratitudeEntity(
      title: title,
      description: description,
      emoji: emoji,
      accentColor: accentColor,
      prompts: prompts,
      createdAt: createdAt,
      category: category,
    );
  }

  /// Создание копии с изменениями
  @override
  GratitudeSuggestionModel copyWith({
    String? title,
    String? description,
    String? emoji,
    Color? accentColor,
    List<String>? prompts,
    DateTime? createdAt,
    GratitudeCategory? category,
  }) {
    return GratitudeSuggestionModel(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
      prompts: prompts ?? this.prompts,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}

