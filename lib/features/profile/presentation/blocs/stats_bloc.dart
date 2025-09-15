import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/profile_repository.dart';

// Events
abstract class StatsEvent {}

class LoadStats extends StatsEvent {}

class RefreshStats extends StatsEvent {}

class CalculateStatsFromMoodEntries extends StatsEvent {
  final List<dynamic> moodEntries;

  CalculateStatsFromMoodEntries(this.moodEntries);
}

// States
abstract class StatsState {}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final UserStatsEntity stats;

  StatsLoaded(this.stats);
}

class StatsCalculating extends StatsState {
  final UserStatsEntity? currentStats;

  StatsCalculating(this.currentStats);
}

class StatsCalculated extends StatsState {
  final UserStatsEntity stats;

  StatsCalculated(this.stats);
}

class StatsError extends StatsState {
  final String message;

  StatsError(this.message);
}

// Bloc
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final ProfileRepository repository;

  StatsBloc({required this.repository}) : super(StatsInitial()) {
    on<LoadStats>(_onLoadStats);
    on<RefreshStats>(_onRefreshStats);
    on<CalculateStatsFromMoodEntries>(_onCalculateStatsFromMoodEntries);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(StatsLoading());
    try {
      final stats = await repository.getUserStats();
      emit(StatsLoaded(stats));
    } catch (e) {
      emit(StatsError('Failed to load stats: $e'));
    }
  }

  Future<void> _onRefreshStats(
    RefreshStats event,
    Emitter<StatsState> emit,
  ) async {
    try {
      final stats = await repository.getUserStats();
      emit(StatsLoaded(stats));
    } catch (e) {
      emit(StatsError('Failed to refresh stats: $e'));
    }
  }

  Future<void> _onCalculateStatsFromMoodEntries(
    CalculateStatsFromMoodEntries event,
    Emitter<StatsState> emit,
  ) async {
    if (state is StatsLoaded) {
      emit(StatsCalculating((state as StatsLoaded).stats));
    } else {
      emit(StatsCalculating(null));
    }

    try {
      await repository.calculateStatsFromMoodEntries(event.moodEntries);
      final updatedStats = await repository.getUserStats();
      emit(StatsCalculated(updatedStats));
    } catch (e) {
      emit(StatsError('Failed to calculate stats: $e'));
    }
  }
}
