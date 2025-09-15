import 'package:flutter/material.dart';

/// Entity для благодарственных предложений
class GratitudeEntity {
  /// Заголовок раздела благодарности
  final String title;

  /// Описание важности благодарности
  final String description;

  /// Emoji для визуального представления
  final String emoji;

  /// Акцентный цвет
  final Color accentColor;

  /// Предложения для благодарности
  final List<String> prompts;

  /// Дата создания
  final DateTime createdAt;

  /// Категория благодарности
  final GratitudeCategory category;

  const GratitudeEntity({
    required this.title,
    required this.description,
    required this.emoji,
    required this.accentColor,
    required this.prompts,
    required this.createdAt,
    required this.category,
  });

  /// Создание копии с изменениями
  GratitudeEntity copyWith({
    String? title,
    String? description,
    String? emoji,
    Color? accentColor,
    List<String>? prompts,
    DateTime? createdAt,
    GratitudeCategory? category,
  }) {
    return GratitudeEntity(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
      prompts: prompts ?? this.prompts,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  /// Преобразование в Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'accentColor': accentColor.value,
      'prompts': prompts,
      'createdAt': createdAt.toIso8601String(),
      'category': category.name,
    };
  }

  /// Создание из Map
  factory GratitudeEntity.fromMap(Map<String, dynamic> map) {
    return GratitudeEntity(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '🙏',
      accentColor: Color(map['accentColor'] ?? 0xFFFFD93D),
      prompts: List<String>.from(map['prompts'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      category: GratitudeCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => GratitudeCategory.general,
      ),
    );
  }

  /// Проверка валидности
  bool get isValid =>
      title.isNotEmpty &&
      description.isNotEmpty &&
      emoji.isNotEmpty &&
      prompts.isNotEmpty;

  /// Получение количества предложений
  int get promptCount => prompts.length;

  /// Проверка, достаточно ли предложений
  bool get hasEnoughPrompts => prompts.length >= 3;

  /// Получение случайного предложения
  String getRandomPrompt() {
    if (prompts.isEmpty) return '';
    final random = DateTime.now().millisecondsSinceEpoch % prompts.length;
    return prompts[random];
  }

  @override
  String toString() {
    return 'GratitudeEntity(title: $title, category: ${category.name}, prompts: ${prompts.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GratitudeEntity &&
        other.title == title &&
        other.description == description &&
        other.emoji == emoji &&
        other.accentColor == accentColor &&
        other.prompts.toString() == prompts.toString() &&
        other.createdAt == createdAt &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      emoji,
      accentColor,
      prompts,
      createdAt,
      category,
    );
  }
}

/// Категории благодарности
enum GratitudeCategory {
  /// Общая благодарность
  general,

  /// Благодарность за людей
  people,

  /// Благодарность за достижения
  achievements,

  /// Благодарность за простые радости
  simpleJoys,

  /// Благодарность за опыт
  experiences,

  /// Благодарность за здоровье
  health,
}

/// Расширение для получения названий категорий
extension GratitudeCategoryExtension on GratitudeCategory {
  String get displayName {
    switch (this) {
      case GratitudeCategory.general:
        return 'Общая благодарность';
      case GratitudeCategory.people:
        return 'Люди в моей жизни';
      case GratitudeCategory.achievements:
        return 'Достижения и успехи';
      case GratitudeCategory.simpleJoys:
        return 'Простые радости';
      case GratitudeCategory.experiences:
        return 'Опыт и воспоминания';
      case GratitudeCategory.health:
        return 'Здоровье и благополучие';
    }
  }

  String get emoji {
    switch (this) {
      case GratitudeCategory.general:
        return '🙏';
      case GratitudeCategory.people:
        return '👥';
      case GratitudeCategory.achievements:
        return '🏆';
      case GratitudeCategory.simpleJoys:
        return '😊';
      case GratitudeCategory.experiences:
        return '🌟';
      case GratitudeCategory.health:
        return '💪';
    }
  }
}

