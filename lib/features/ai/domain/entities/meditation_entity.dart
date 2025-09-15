import 'package:flutter/material.dart';

/// Entity для медитационных сессий
class MeditationEntity {
  /// Название медитационной сессии
  final String title;

  /// Описание техники и её пользы
  final String description;

  /// Emoji для визуального представления
  final String emoji;

  /// Акцентный цвет
  final Color accentColor;

  /// Тип медитации
  final MeditationType type;

  /// Рекомендуемая длительность в минутах
  final int duration;

  /// Пошаговые инструкции
  final List<String> instructions;

  /// Практические советы
  final List<String> tips;

  /// Дата создания
  final DateTime createdAt;

  /// Уровень сложности
  final MeditationDifficulty difficulty;

  const MeditationEntity({
    required this.title,
    required this.description,
    required this.emoji,
    required this.accentColor,
    required this.type,
    required this.duration,
    required this.instructions,
    required this.tips,
    required this.createdAt,
    required this.difficulty,
  });

  /// Создание копии с изменениями
  MeditationEntity copyWith({
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
    return MeditationEntity(
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

  /// Преобразование в Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'accentColor': accentColor.value,
      'type': type.name,
      'duration': duration,
      'instructions': instructions,
      'tips': tips,
      'createdAt': createdAt.toIso8601String(),
      'difficulty': difficulty.name,
    };
  }

  /// Создание из Map
  factory MeditationEntity.fromMap(Map<String, dynamic> map) {
    return MeditationEntity(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '🧘',
      accentColor: Color(map['accentColor'] ?? 0xFF74B9FF),
      type: MeditationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MeditationType.mindfulness,
      ),
      duration: map['duration'] ?? 10,
      instructions: List<String>.from(map['instructions'] ?? []),
      tips: List<String>.from(map['tips'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      difficulty: MeditationDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => MeditationDifficulty.beginner,
      ),
    );
  }

  /// Проверка валидности
  bool get isValid =>
      title.isNotEmpty &&
      description.isNotEmpty &&
      emoji.isNotEmpty &&
      instructions.isNotEmpty &&
      duration > 0;

  /// Получение количества инструкций
  int get instructionCount => instructions.length;

  /// Получение количества советов
  int get tipCount => tips.length;

  /// Проверка, подходит ли для новичков
  bool get isBeginnerFriendly => difficulty == MeditationDifficulty.beginner;

  /// Проверка, является ли короткой сессией
  bool get isShortSession => duration <= 10;

  /// Проверка, является ли длинной сессией
  bool get isLongSession => duration > 20;

  /// Получение формата длительности
  String get durationFormatted => '$duration мин';

  @override
  String toString() {
    return 'MeditationEntity(title: $title, type: ${type.name}, duration: $durationмин, difficulty: ${difficulty.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MeditationEntity &&
        other.title == title &&
        other.description == description &&
        other.emoji == emoji &&
        other.accentColor == accentColor &&
        other.type == type &&
        other.duration == duration &&
        other.instructions.toString() == instructions.toString() &&
        other.tips.toString() == tips.toString() &&
        other.createdAt == createdAt &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      emoji,
      accentColor,
      type,
      duration,
      instructions,
      tips,
      createdAt,
      difficulty,
    );
  }
}

/// Типы медитации
enum MeditationType {
  /// Осознанность
  mindfulness,

  /// Дыхательные упражнения
  breathing,

  /// Тело-сканирование
  bodyScan,

  /// Любящая доброта
  lovingKindness,

  /// Визуализация
  visualization,

  /// Прогрессивная релаксация
  progressiveRelaxation,

  /// Мантры
  mantra,

  /// Ходячая медитация
  walking,
}

/// Уровни сложности медитации
enum MeditationDifficulty {
  /// Новичок
  beginner,

  /// Средний
  intermediate,

  /// Продвинутый
  advanced,
}

/// Расширение для получения названий типов медитации
extension MeditationTypeExtension on MeditationType {
  String get displayName {
    switch (this) {
      case MeditationType.mindfulness:
        return 'Медитация осознанности';
      case MeditationType.breathing:
        return 'Дыхательные упражнения';
      case MeditationType.bodyScan:
        return 'Сканирование тела';
      case MeditationType.lovingKindness:
        return 'Любящая доброта';
      case MeditationType.visualization:
        return 'Визуализация';
      case MeditationType.progressiveRelaxation:
        return 'Прогрессивная релаксация';
      case MeditationType.mantra:
        return 'Медитация с мантрами';
      case MeditationType.walking:
        return 'Ходячая медитация';
    }
  }

  String get emoji {
    switch (this) {
      case MeditationType.mindfulness:
        return '🧘';
      case MeditationType.breathing:
        return '🫁';
      case MeditationType.bodyScan:
        return '👤';
      case MeditationType.lovingKindness:
        return '💝';
      case MeditationType.visualization:
        return '🌅';
      case MeditationType.progressiveRelaxation:
        return '😌';
      case MeditationType.mantra:
        return '🕉️';
      case MeditationType.walking:
        return '🚶';
    }
  }
}

/// Расширение для получения названий уровней сложности
extension MeditationDifficultyExtension on MeditationDifficulty {
  String get displayName {
    switch (this) {
      case MeditationDifficulty.beginner:
        return 'Новичок';
      case MeditationDifficulty.intermediate:
        return 'Средний';
      case MeditationDifficulty.advanced:
        return 'Продвинутый';
    }
  }

  Color get color {
    switch (this) {
      case MeditationDifficulty.beginner:
        return Colors.green;
      case MeditationDifficulty.intermediate:
        return Colors.orange;
      case MeditationDifficulty.advanced:
        return Colors.red;
    }
  }
}

