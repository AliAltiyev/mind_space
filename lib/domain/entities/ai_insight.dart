import 'package:flutter/material.dart';

/// Сущность AI инсайта для Domain слоя
class AIInsight {
  /// Заголовок инсайта
  final String title;

  /// Подробное описание инсайта
  final String description;

  /// Emoji для визуального представления
  final String emoji;

  /// Акцентный цвет для карточки
  final Color accentColor;

  const AIInsight({
    required this.title,
    required this.description,
    required this.emoji,
    required this.accentColor,
  });

  /// Создание копии с изменениями
  AIInsight copyWith({
    String? title,
    String? description,
    String? emoji,
    Color? accentColor,
  }) {
    return AIInsight(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  /// Преобразование в Map для сериализации
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'emoji': emoji,
      'accentColor': accentColor.value,
    };
  }

  /// Создание из Map
  factory AIInsight.fromMap(Map<String, dynamic> map) {
    return AIInsight(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '💭',
      accentColor: Color(map['accentColor'] ?? 0xFF4ECDC4),
    );
  }

  /// Преобразование в JSON
  String toJson() {
    return '''
    {
      "title": "$title",
      "description": "$description",
      "emoji": "$emoji",
      "accentColor": "${accentColor.value.toRadixString(16).padLeft(8, '0')}"
    }
    ''';
  }

  /// Создание из JSON
  factory AIInsight.fromJson(String jsonString) {
    final map = Map<String, dynamic>.from(
      Uri.splitQueryString(jsonString.replaceAll(RegExp(r'[{}"]'), '')),
    );

    return AIInsight(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '💭',
      accentColor: Color(
        int.parse(map['accentColor'] ?? 'FF4ECDC4', radix: 16),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AIInsight &&
        other.title == title &&
        other.description == description &&
        other.emoji == emoji &&
        other.accentColor == accentColor;
  }

  @override
  int get hashCode {
    return Object.hash(title, description, emoji, accentColor);
  }

  @override
  String toString() {
    return 'AIInsight(title: $title, description: $description, emoji: $emoji, accentColor: $accentColor)';
  }

  /// Проверка валидности инсайта
  bool get isValid {
    return title.isNotEmpty && description.isNotEmpty && emoji.isNotEmpty;
  }

  /// Получение длины заголовка
  int get titleLength => title.length;

  /// Получение длины описания
  int get descriptionLength => description.length;

  /// Проверка, является ли инсайт коротким
  bool get isShort => titleLength <= 20 && descriptionLength <= 100;

  /// Проверка, является ли инсайт длинным
  bool get isLong => titleLength > 50 || descriptionLength > 200;
}
