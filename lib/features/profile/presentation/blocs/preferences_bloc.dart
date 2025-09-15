import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/profile_repository.dart';

// Events
abstract class PreferencesEvent {}

class LoadPreferences extends PreferencesEvent {}

class UpdatePreferences extends PreferencesEvent {
  final UserPreferencesEntity preferences;

  UpdatePreferences(this.preferences);
}

class ToggleDarkMode extends PreferencesEvent {}

class UpdateLanguage extends PreferencesEvent {
  final String language;

  UpdateLanguage(this.language);
}

class ToggleNotifications extends PreferencesEvent {}

class UpdateDailyReminder extends PreferencesEvent {
  final DateTime time;

  UpdateDailyReminder(this.time);
}

class ToggleAiInsights extends PreferencesEvent {}

class UpdateEnabledFeatures extends PreferencesEvent {
  final List<String> features;

  UpdateEnabledFeatures(this.features);
}

class ResetPreferences extends PreferencesEvent {}

// States
abstract class PreferencesState {}

class PreferencesInitial extends PreferencesState {}

class PreferencesLoading extends PreferencesState {}

class PreferencesLoaded extends PreferencesState {
  final UserPreferencesEntity preferences;

  PreferencesLoaded(this.preferences);
}

class PreferencesUpdating extends PreferencesState {
  final UserPreferencesEntity currentPreferences;

  PreferencesUpdating(this.currentPreferences);
}

class PreferencesUpdated extends PreferencesState {
  final UserPreferencesEntity preferences;

  PreferencesUpdated(this.preferences);
}

class PreferencesError extends PreferencesState {
  final String message;

  PreferencesError(this.message);
}

// Bloc
class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final ProfileRepository repository;

  PreferencesBloc({required this.repository}) : super(PreferencesInitial()) {
    on<LoadPreferences>(_onLoadPreferences);
    on<UpdatePreferences>(_onUpdatePreferences);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<ToggleNotifications>(_onToggleNotifications);
    on<UpdateDailyReminder>(_onUpdateDailyReminder);
    on<ToggleAiInsights>(_onToggleAiInsights);
    on<UpdateEnabledFeatures>(_onUpdateEnabledFeatures);
    on<ResetPreferences>(_onResetPreferences);
  }

  Future<void> _onLoadPreferences(
    LoadPreferences event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(PreferencesLoading());
    try {
      final preferences = await repository.getUserPreferences();
      emit(PreferencesLoaded(preferences));
    } catch (e) {
      emit(PreferencesError('Failed to load preferences: $e'));
    }
  }

  Future<void> _onUpdatePreferences(
    UpdatePreferences event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state is PreferencesLoaded) {
      emit(PreferencesUpdating((state as PreferencesLoaded).preferences));
    }

    try {
      await repository.updateUserPreferences(event.preferences);
      final updatedPreferences = await repository.getUserPreferences();
      emit(PreferencesUpdated(updatedPreferences));
    } catch (e) {
      emit(PreferencesError('Failed to update preferences: $e'));
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state is PreferencesLoaded) {
      final currentPreferences = (state as PreferencesLoaded).preferences;
      final updatedPreferences = currentPreferences.copyWith(
        darkMode: !currentPreferences.darkMode,
      );
      add(UpdatePreferences(updatedPreferences));
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state is PreferencesLoaded) {
      final currentPreferences = (state as PreferencesLoaded).preferences;
      final updatedPreferences = currentPreferences.copyWith(
        language: event.language,
      );
      add(UpdatePreferences(updatedPreferences));
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state is PreferencesLoaded) {
      final currentPreferences = (state as PreferencesLoaded).preferences;
      final updatedPreferences = currentPreferences.copyWith(
        notificationsEnabled: !currentPreferences.notificationsEnabled,
      );
      add(UpdatePreferences(updatedPreferences));
    }
  }

  Future<void> _onUpdateDailyReminder(
    UpdateDailyReminder event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state is PreferencesLoaded) {
      final currentPreferences = (state as PreferencesLoaded).preferences;
      final updatedPreferences = currentPreferences.copyWith(
        dailyReminderTime: TimeOfDay.fromDateTime(event.time),
      );
      add(UpdatePreferences(updatedPreferences));
    }
  }

  Future<void> _onToggleAiInsights(
    ToggleAiInsights event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state is PreferencesLoaded) {
      final currentPreferences = (state as PreferencesLoaded).preferences;
      final updatedPreferences = currentPreferences.copyWith(
        aiInsightsEnabled: !currentPreferences.aiInsightsEnabled,
      );
      add(UpdatePreferences(updatedPreferences));
    }
  }

  Future<void> _onUpdateEnabledFeatures(
    UpdateEnabledFeatures event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state is PreferencesLoaded) {
      final currentPreferences = (state as PreferencesLoaded).preferences;
      final updatedPreferences = currentPreferences.copyWith(
        enabledFeatures: event.features,
      );
      add(UpdatePreferences(updatedPreferences));
    }
  }

  Future<void> _onResetPreferences(
    ResetPreferences event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(PreferencesLoading());
    try {
      await repository.resetUserPreferences();
      final defaultPreferences = await repository.getUserPreferences();
      emit(PreferencesLoaded(defaultPreferences));
    } catch (e) {
      emit(PreferencesError('Failed to reset preferences: $e'));
    }
  }
}
