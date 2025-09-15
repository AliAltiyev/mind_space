import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

// Events
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UserProfileEntity profile;

  UpdateProfile(this.profile);
}

class RefreshProfile extends ProfileEvent {}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity profile;

  ProfileLoaded(this.profile);
}

class ProfileUpdating extends ProfileState {
  final UserProfileEntity currentProfile;

  ProfileUpdating(this.currentProfile);
}

class ProfileUpdated extends ProfileState {
  final UserProfileEntity profile;

  ProfileUpdated(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfile;
  final UpdateUserProfileUseCase updateUserProfile;

  ProfileBloc({required this.getUserProfile, required this.updateUserProfile})
    : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<RefreshProfile>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await getUserProfile.execute();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit(ProfileUpdating((state as ProfileLoaded).profile));
    }

    try {
      await updateUserProfile.execute(event.profile);
      final updatedProfile = await getUserProfile.execute();
      emit(ProfileUpdated(updatedProfile));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final profile = await getUserProfile.execute();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError('Failed to refresh profile: $e'));
    }
  }
}
