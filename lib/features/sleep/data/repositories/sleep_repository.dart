import '../../domain/entities/sleep_entry.dart';
import '../../domain/entities/sleep_insight.dart';

/// Репозиторий для работы с данными о сне
abstract class SleepRepository {
  Future<List<SleepEntry>> getSleepEntries(DateTime startDate, DateTime endDate);
  Future<SleepEntry?> getLastSleepEntry();
  Future<void> saveSleepEntry(SleepEntry entry);
  Future<SleepInsight> analyzeSleepPatterns(List<SleepEntry> entries);
  Future<List<SleepInsight>> getSleepRecommendations(
    List<SleepEntry> entries,
    List<dynamic> moodEntries,
  );
}



