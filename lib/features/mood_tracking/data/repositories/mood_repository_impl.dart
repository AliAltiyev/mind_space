import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_local_datasource.dart';
import '../models/mood_entry_model.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodLocalDataSource localDataSource;

  MoodRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final models = await localDataSource.getAllMoodEntries();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<MoodEntry?> getMoodEntryById(String id) async {
    try {
      final model = await localDataSource.getMoodEntryById(id);
      return model?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByDateRange(
      DateTime start, DateTime end) async {
    final models = await localDataSource.getMoodEntriesByDateRange(start, end);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveMoodEntry(MoodEntry entry) async {
    final model = MoodEntryModel.fromEntity(entry);
    await localDataSource.saveMoodEntry(model);
  }

  @override
  Future<void> updateMoodEntry(MoodEntry entry) async {
    final model = MoodEntryModel.fromEntity(entry);
    await localDataSource.updateMoodEntry(model);
  }

  @override
  Future<void> deleteMoodEntry(String id) async {
    await localDataSource.deleteMoodEntry(id);
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByMood(MoodLevel mood) async {
    final models = await localDataSource.getMoodEntriesByMood(mood.value);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Map<MoodLevel, int>> getMoodStatistics(
      DateTime start, DateTime end) async {
    final statistics = await localDataSource.getMoodStatistics(start, end);
    final result = <MoodLevel, int>{};
    
    for (final entry in statistics.entries) {
      final moodLevel = MoodLevel.values.firstWhere(
        (m) => m.value == entry.key,
      );
      result[moodLevel] = entry.value;
    }
    
    return result;
  }
}

