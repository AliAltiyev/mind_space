import 'package:flutter/material.dart';

import '../../domain/entities/meditation_entity.dart';

/// Модель данных для медитационных сессий
class MeditationSessionModel extends MeditationEntity {
  const MeditationSessionModel({
    required super.title,
    required super.description,
    required super.emoji,
    required super.accentColor,
    required super.type,
    required super.duration,
    required super.instructions,
    required super.tips,
    required super.createdAt,
    required super.difficulty,
  });

  /// Создание из JSON
  factory MeditationSessionModel.fromJson(Map<String, dynamic> json) {
    return MeditationSessionModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🧘',
      accentColor: Color(
        int.parse(
          json['accentColor']?.toString().replaceFirst('#', '0xFF') ??
              '0xFF74B9FF',
        ),
      ),
      type: MeditationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MeditationType.mindfulness,
      ),
      duration: json['duration'] ?? 10,
      instructions: List<String>.from(json['instructions'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      createdAt: DateTime.now(),
      difficulty: MeditationDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => MeditationDifficulty.beginner,
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
      'type': type.name,
      'duration': duration,
      'instructions': instructions,
      'tips': tips,
      'createdAt': createdAt.toIso8601String(),
      'difficulty': difficulty.name,
    };
  }

  /// Создание из entity
  factory MeditationSessionModel.fromEntity(MeditationEntity entity) {
    return MeditationSessionModel(
      title: entity.title,
      description: entity.description,
      emoji: entity.emoji,
      accentColor: entity.accentColor,
      type: entity.type,
      duration: entity.duration,
      instructions: entity.instructions,
      tips: entity.tips,
      createdAt: entity.createdAt,
      difficulty: entity.difficulty,
    );
  }

  /// Преобразование в entity
  MeditationEntity toEntity() {
    return MeditationEntity(
      title: title,
      description: description,
      emoji: emoji,
      accentColor: accentColor,
      type: type,
      duration: duration,
      instructions: instructions,
      tips: tips,
      createdAt: createdAt,
      difficulty: difficulty,
    );
  }

  /// Создание копии с изменениями
  @override
  MeditationSessionModel copyWith({
    String? title,
    String? description,
    String? emoji,
    Color? accentColor,
    MeditationType? type,
    int? duration,
    List<String>? instructions,
    List<String>? tips,
    DateTime? createdAt,
    MeditationDifficulty? difficulty,
  }) {
    return MeditationSessionModel(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      createdAt: createdAt ?? this.createdAt,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

