import 'package:equatable/equatable.dart';
import '../../domain/entities/mood_entry.dart';

abstract class MoodTrackingState extends Equatable {
  const MoodTrackingState();

  @override
  List<Object?> get props => [];
}

class MoodTrackingInitial extends MoodTrackingState {}

class MoodTrackingLoading extends MoodTrackingState {}

class MoodTrackingLoaded extends MoodTrackingState {
  final List<MoodEntry> entries;
  final Map<MoodLevel, int>? statistics;
  final DateTime? filterStart;
  final DateTime? filterEnd;
  final MoodLevel? filterMood;

  const MoodTrackingLoaded({
    required this.entries,
    this.statistics,
    this.filterStart,
    this.filterEnd,
    this.filterMood,
  });

  @override
  List<Object?> get props => [entries, statistics, filterStart, filterEnd, filterMood];

  MoodTrackingLoaded copyWith({
    List<MoodEntry>? entries,
    Map<MoodLevel, int>? statistics,
    DateTime? filterStart,
    DateTime? filterEnd,
    MoodLevel? filterMood,
  }) {
    return MoodTrackingLoaded(
      entries: entries ?? this.entries,
      statistics: statistics ?? this.statistics,
      filterStart: filterStart ?? this.filterStart,
      filterEnd: filterEnd ?? this.filterEnd,
      filterMood: filterMood ?? this.filterMood,
    );
  }
}

class MoodTrackingError extends MoodTrackingState {
  final String message;

  const MoodTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

