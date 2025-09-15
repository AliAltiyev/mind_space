import 'package:hive/hive.dart';
import '../../domain/entities/mood_entry.dart';

part 'mood_entry_model.g.dart';

@HiveType(typeId: 0)
class MoodEntryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int moodValue;

  @HiveField(2)
  String note;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  List<String> tags;

  @HiveField(5)
  String? voiceNotePath;

  MoodEntryModel({
    required this.id,
    required this.moodValue,
    required this.note,
    required this.createdAt,
    this.tags = const [],
    this.voiceNotePath,
  });

  factory MoodEntryModel.fromEntity(MoodEntry entry) {
    return MoodEntryModel(
      id: entry.id,
      moodValue: entry.mood.value,
      note: entry.note,
      createdAt: entry.createdAt,
      tags: entry.tags,
      voiceNotePath: entry.voiceNotePath,
    );
  }

  MoodEntry toEntity() {
    return MoodEntry(
      id: id,
      mood: MoodLevel.values.firstWhere((m) => m.value == moodValue),
      note: note,
      createdAt: createdAt,
      tags: tags,
      voiceNotePath: voiceNotePath,
    );
  }
}

