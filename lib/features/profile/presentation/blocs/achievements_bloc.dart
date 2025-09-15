import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_achievements_entity.dart';
import '../../domain/repositories/profile_repository.dart';

// Events
abstract class AchievementsEvent {}

class LoadAchievements extends AchievementsEvent {}

class RefreshAchievements extends AchievementsEvent {}

class UnlockAchievement extends AchievementsEvent {
  final String achievementId;

  UnlockAchievement(this.achievementId);
}

class UpdateAchievementProgress extends AchievementsEvent {
  final String achievementId;
  final int progress;

  UpdateAchievementProgress(this.achievementId, this.progress);
}

// States
abstract class AchievementsState {}

class AchievementsInitial extends AchievementsState {}

class AchievementsLoading extends AchievementsState {}

class AchievementsLoaded extends AchievementsState {
  final UserAchievementsEntity achievements;

  AchievementsLoaded(this.achievements);
}

class AchievementsUpdating extends AchievementsState {
  final UserAchievementsEntity currentAchievements;

  AchievementsUpdating(this.currentAchievements);
}

class AchievementUnlocked extends AchievementsState {
  final UserAchievementsEntity achievements;
  final String achievementId;

  AchievementUnlocked(this.achievements, this.achievementId);
}

class AchievementProgressUpdated extends AchievementsState {
  final UserAchievementsEntity achievements;
  final String achievementId;
  final int progress;

  AchievementProgressUpdated(
    this.achievements,
    this.achievementId,
    this.progress,
  );
}

class AchievementsError extends AchievementsState {
  final String message;

  AchievementsError(this.message);
}

// Bloc
class AchievementsBloc extends Bloc<AchievementsEvent, AchievementsState> {
  final ProfileRepository repository;

  AchievementsBloc({required this.repository}) : super(AchievementsInitial()) {
    on<LoadAchievements>(_onLoadAchievements);
    on<RefreshAchievements>(_onRefreshAchievements);
    on<UnlockAchievement>(_onUnlockAchievement);
    on<UpdateAchievementProgress>(_onUpdateAchievementProgress);
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(AchievementsLoading());
    try {
      final achievements = await repository.getUserAchievements();
      emit(AchievementsLoaded(achievements));
    } catch (e) {
      emit(AchievementsError('Failed to load achievements: $e'));
    }
  }

  Future<void> _onRefreshAchievements(
    RefreshAchievements event,
    Emitter<AchievementsState> emit,
  ) async {
    try {
      final achievements = await repository.getUserAchievements();
      emit(AchievementsLoaded(achievements));
    } catch (e) {
      emit(AchievementsError('Failed to refresh achievements: $e'));
    }
  }

  Future<void> _onUnlockAchievement(
    UnlockAchievement event,
    Emitter<AchievementsState> emit,
  ) async {
    if (state is AchievementsLoaded) {
      emit(AchievementsUpdating((state as AchievementsLoaded).achievements));
    }

    try {
      await repository.unlockAchievement(event.achievementId);
      final updatedAchievements = await repository.getUserAchievements();
      emit(AchievementUnlocked(updatedAchievements, event.achievementId));
    } catch (e) {
      emit(AchievementsError('Failed to unlock achievement: $e'));
    }
  }

  Future<void> _onUpdateAchievementProgress(
    UpdateAchievementProgress event,
    Emitter<AchievementsState> emit,
  ) async {
    if (state is AchievementsLoaded) {
      emit(AchievementsUpdating((state as AchievementsLoaded).achievements));
    }

    try {
      await repository.updateAchievementProgress(
        event.achievementId,
        event.progress,
      );
      final updatedAchievements = await repository.getUserAchievements();
      emit(
        AchievementProgressUpdated(
          updatedAchievements,
          event.achievementId,
          event.progress,
        ),
      );
    } catch (e) {
      emit(AchievementsError('Failed to update achievement progress: $e'));
    }
  }
}
