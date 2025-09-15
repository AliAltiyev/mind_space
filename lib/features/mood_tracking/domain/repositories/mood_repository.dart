import '../entities/mood_entry.dart';

abstract class MoodRepository {
  Future<List<MoodEntry>> getAllMoodEntries();
  Future<MoodEntry?> getMoodEntryById(String id);
  Future<List<MoodEntry>> getMoodEntriesByDateRange(DateTime start, DateTime end);
  Future<void> saveMoodEntry(MoodEntry entry);
  Future<void> updateMoodEntry(MoodEntry entry);
  Future<void> deleteMoodEntry(String id);
  Future<List<MoodEntry>> getMoodEntriesByMood(MoodLevel mood);
  Future<Map<MoodLevel, int>> getMoodStatistics(DateTime start, DateTime end);
}

