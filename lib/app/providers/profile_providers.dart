import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/datasources/user_preferences_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/entities/user_achievements_entity.dart';
import '../../features/profile/domain/entities/user_preferences_entity.dart';
import '../../features/profile/domain/entities/user_profile_entity.dart';
import '../../features/profile/domain/entities/user_stats_entity.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_achievements_usecase.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_user_stats_usecase.dart';
import '../../features/profile/domain/usecases/update_user_preferences_usecase.dart';
import '../../features/profile/domain/usecases/update_user_profile_usecase.dart';
import '../../features/profile/presentation/blocs/achievements_bloc.dart';
import '../../features/profile/presentation/blocs/preferences_bloc.dart';
import '../../features/profile/presentation/blocs/profile_bloc.dart';
import '../../features/profile/presentation/blocs/stats_bloc.dart';

/// Провайдер для Dio
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
});

/// Провайдер для ProfileLocalDataSource
final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource();
});

/// Провайдер для UserPreferencesDataSource
final userPreferencesDataSourceProvider = Provider<UserPreferencesDataSource>((
  ref,
) {
  return UserPreferencesDataSource();
});

/// Провайдер для ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final localDataSource = ref.watch(profileLocalDataSourceProvider);
  final preferencesDataSource = ref.watch(userPreferencesDataSourceProvider);

  return ProfileRepositoryImpl(
    localDataSource: localDataSource,
    preferencesDataSource: preferencesDataSource,
  );
});

/// Провайдеры для Use Cases
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserProfileUseCase(repository);
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((
  ref,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
});

final getUserStatsUseCaseProvider = Provider<GetUserStatsUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserStatsUseCase(repository);
});

final updateUserPreferencesUseCaseProvider =
    Provider<UpdateUserPreferencesUseCase>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return UpdateUserPreferencesUseCase(repository);
    });

final getUserAchievementsUseCaseProvider = Provider<GetUserAchievementsUseCase>(
  (ref) {
    final repository = ref.watch(profileRepositoryProvider);
    return GetUserAchievementsUseCase(repository);
  },
);

/// Провайдеры для Bloc'ов
final profileBlocProvider = Provider<ProfileBloc>((ref) {
  final getUserProfile = ref.watch(getUserProfileUseCaseProvider);
  final updateUserProfile = ref.watch(updateUserProfileUseCaseProvider);

  return ProfileBloc(
    getUserProfile: getUserProfile,
    updateUserProfile: updateUserProfile,
  );
});

final preferencesBlocProvider = Provider<PreferencesBloc>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return PreferencesBloc(repository: repository);
});

final statsBlocProvider = Provider<StatsBloc>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return StatsBloc(repository: repository);
});

final achievementsBlocProvider = Provider<AchievementsBloc>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return AchievementsBloc(repository: repository);
});

/// Провайдеры для получения данных профиля
final userProfileProvider = FutureProvider<UserProfileEntity>((ref) async {
  final useCase = ref.watch(getUserProfileUseCaseProvider);
  return await useCase.execute();
});

final userStatsProvider = FutureProvider<UserStatsEntity>((ref) async {
  final useCase = ref.watch(getUserStatsUseCaseProvider);
  return await useCase.execute();
});

final userAchievementsProvider = FutureProvider<UserAchievementsEntity>((
  ref,
) async {
  final useCase = ref.watch(getUserAchievementsUseCaseProvider);
  return await useCase.execute();
});

/// Провайдер для настроек пользователя
final userPreferencesProvider = FutureProvider<UserPreferencesEntity>((
  ref,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getUserPreferences();
});

/// Провайдер для синхронизации данных
final syncProfileDataProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  await repository.syncWithRemote();
});

/// Провайдер для очистки локальных данных
final clearProfileDataProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  await repository.clearLocalData();
});
