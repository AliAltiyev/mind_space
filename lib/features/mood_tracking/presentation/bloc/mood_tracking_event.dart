import 'package:equatable/equatable.dart';

import '../../domain/entities/mood_entry.dart';

abstract class MoodTrackingEvent extends Equatable {
  const MoodTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoodEntries extends MoodTrackingEvent {}

class AddMoodEntry extends MoodTrackingEvent {
  final MoodEntry entry;

  const AddMoodEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class UpdateMoodEntry extends MoodTrackingEvent {
  final MoodEntry entry;

  const UpdateMoodEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DeleteMoodEntry extends MoodTrackingEvent {
  final String id;

  const DeleteMoodEntry(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterMoodEntriesByDate extends MoodTrackingEvent {
  final DateTime start;
  final DateTime end;

  const FilterMoodEntriesByDate(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

class FilterMoodEntriesByMood extends MoodTrackingEvent {
  final MoodLevel mood;

  const FilterMoodEntriesByMood(this.mood);

  @override
  List<Object?> get props => [mood];
}

class ClearFilters extends MoodTrackingEvent {}
