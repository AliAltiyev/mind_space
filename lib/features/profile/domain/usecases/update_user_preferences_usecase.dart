import '../entities/user_preferences_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateUserPreferencesUseCase {
  final ProfileRepository repository;

  UpdateUserPreferencesUseCase(this.repository);

  Future<void> execute(UserPreferencesEntity preferences) async {
    // Validate preferences data
    if (preferences.language.trim().isEmpty) {
      throw Exception('Language cannot be empty');
    }

    if (preferences.dailyReminderTime.hour < 0 ||
        preferences.dailyReminderTime.hour > 23) {
      throw Exception('Invalid reminder hour');
    }

    if (preferences.dailyReminderTime.minute < 0 ||
        preferences.dailyReminderTime.minute > 59) {
      throw Exception('Invalid reminder minute');
    }

    await repository.updateUserPreferences(preferences);
  }
}
