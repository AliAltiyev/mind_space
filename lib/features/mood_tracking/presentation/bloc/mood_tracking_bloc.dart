import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/entities/mood_entry.dart';
import 'mood_tracking_event.dart';
import 'mood_tracking_state.dart';

class MoodTrackingBloc extends Bloc<MoodTrackingEvent, MoodTrackingState> {
  final MoodRepository moodRepository;

  MoodTrackingBloc({required this.moodRepository}) : super(MoodTrackingInitial()) {
    on<LoadMoodEntries>(_onLoadMoodEntries);
    on<AddMoodEntry>(_onAddMoodEntry);
    on<UpdateMoodEntry>(_onUpdateMoodEntry);
    on<DeleteMoodEntry>(_onDeleteMoodEntry);
    on<FilterMoodEntriesByDate>(_onFilterMoodEntriesByDate);
    on<FilterMoodEntriesByMood>(_onFilterMoodEntriesByMood);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadMoodEntries(
    LoadMoodEntries event,
    Emitter<MoodTrackingState> emit,
  ) async {
    try {
      emit(MoodTrackingLoading());
      final entries = await moodRepository.getAllMoodEntries();
      final statistics = await _calculateStatistics(entries);
      emit(MoodTrackingLoaded(entries: entries, statistics: statistics));
    } catch (e) {
      emit(MoodTrackingError('Ошибка загрузки записей: $e'));
    }
  }

  Future<void> _onAddMoodEntry(
    AddMoodEntry event,
    Emitter<MoodTrackingState> emit,
  ) async {
    try {
      await moodRepository.saveMoodEntry(event.entry);
      add(LoadMoodEntries());
    } catch (e) {
      emit(MoodTrackingError('Ошибка сохранения записи: $e'));
    }
  }

  Future<void> _onUpdateMoodEntry(
    UpdateMoodEntry event,
    Emitter<MoodTrackingState> emit,
  ) async {
    try {
      await moodRepository.updateMoodEntry(event.entry);
      add(LoadMoodEntries());
    } catch (e) {
      emit(MoodTrackingError('Ошибка обновления записи: $e'));
    }
  }

  Future<void> _onDeleteMoodEntry(
    DeleteMoodEntry event,
    Emitter<MoodTrackingState> emit,
  ) async {
    try {
      await moodRepository.deleteMoodEntry(event.id);
      add(LoadMoodEntries());
    } catch (e) {
      emit(MoodTrackingError('Ошибка удаления записи: $e'));
    }
  }

  Future<void> _onFilterMoodEntriesByDate(
    FilterMoodEntriesByDate event,
    Emitter<MoodTrackingState> emit,
  ) async {
    try {
      emit(MoodTrackingLoading());
      final entries = await moodRepository.getMoodEntriesByDateRange(
        event.start,
        event.end,
      );
      final statistics = await _calculateStatistics(entries);
      emit(MoodTrackingLoaded(
        entries: entries,
        statistics: statistics,
        filterStart: event.start,
        filterEnd: event.end,
      ));
    } catch (e) {
      emit(MoodTrackingError('Ошибка фильтрации по дате: $e'));
    }
  }

  Future<void> _onFilterMoodEntriesByMood(
    FilterMoodEntriesByMood event,
    Emitter<MoodTrackingState> emit,
  ) async {
    try {
      emit(MoodTrackingLoading());
      final entries = await moodRepository.getMoodEntriesByMood(event.mood);
      final statistics = await _calculateStatistics(entries);
      emit(MoodTrackingLoaded(
        entries: entries,
        statistics: statistics,
        filterMood: event.mood,
      ));
    } catch (e) {
      emit(MoodTrackingError('Ошибка фильтрации по настроению: $e'));
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<MoodTrackingState> emit,
  ) async {
    add(LoadMoodEntries());
  }

  Future<Map<MoodLevel, int>> _calculateStatistics(List<MoodEntry> entries) async {
    final statistics = <MoodLevel, int>{};
    for (final entry in entries) {
      statistics[entry.mood] = (statistics[entry.mood] ?? 0) + 1;
    }
    return statistics;
  }
}
