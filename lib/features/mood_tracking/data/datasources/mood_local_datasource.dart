import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry_model.dart';

abstract class MoodLocalDataSource {
  Future<List<MoodEntryModel>> getAllMoodEntries();
  Future<MoodEntryModel?> getMoodEntryById(String id);
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange(DateTime start, DateTime end);
  Future<void> saveMoodEntry(MoodEntryModel entry);
  Future<void> updateMoodEntry(MoodEntryModel entry);
  Future<void> deleteMoodEntry(String id);
  Future<List<MoodEntryModel>> getMoodEntriesByMood(int moodValue);
  Future<Map<int, int>> getMoodStatistics(DateTime start, DateTime end);
}

class MoodLocalDataSourceImpl implements MoodLocalDataSource {
  static const String _boxName = 'mood_entries';
  late Box<MoodEntryModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<MoodEntryModel>(_boxName);
  }

  @override
  Future<List<MoodEntryModel>> getAllMoodEntries() async {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<MoodEntryModel?> getMoodEntryById(String id) async {
    return _box.values.firstWhere(
      (entry) => entry.id == id,
      orElse: () => throw Exception('Mood entry not found'),
    );
  }

  @override
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange(
      DateTime start, DateTime end) async {
    return _box.values
        .where((entry) =>
            entry.createdAt.isAfter(start) && entry.createdAt.isBefore(end))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveMoodEntry(MoodEntryModel entry) async {
    await _box.put(entry.id, entry);
  }

  @override
  Future<void> updateMoodEntry(MoodEntryModel entry) async {
    await _box.put(entry.id, entry);
  }

  @override
  Future<void> deleteMoodEntry(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<MoodEntryModel>> getMoodEntriesByMood(int moodValue) async {
    return _box.values
        .where((entry) => entry.moodValue == moodValue)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Map<int, int>> getMoodStatistics(DateTime start, DateTime end) async {
    final entries = await getMoodEntriesByDateRange(start, end);
    final statistics = <int, int>{};
    
    for (final entry in entries) {
      statistics[entry.moodValue] = (statistics[entry.moodValue] ?? 0) + 1;
    }
    
    return statistics;
  }
}

