import 'package:equatable/equatable.dart';

enum MoodLevel {
  verySad(1, '😢', 'Очень грустно'),
  sad(2, '😔', 'Грустно'),
  neutral(3, '😐', 'Нейтрально'),
  happy(4, '😊', 'Хорошо'),
  veryHappy(5, '😄', 'Отлично');

  const MoodLevel(this.value, this.emoji, this.label);
  
  final int value;
  final String emoji;
  final String label;
}

class MoodEntry extends Equatable {
  final String id;
  final MoodLevel mood;
  final String note;
  final DateTime createdAt;
  final List<String> tags;
  final String? voiceNotePath;

  const MoodEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.createdAt,
    this.tags = const [],
    this.voiceNotePath,
  });

  @override
  List<Object?> get props => [id, mood, note, createdAt, tags, voiceNotePath];

  MoodEntry copyWith({
    String? id,
    MoodLevel? mood,
    String? note,
    DateTime? createdAt,
    List<String>? tags,
    String? voiceNotePath,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
    );
  }
}

