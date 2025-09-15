import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateUserProfileUseCase {
  final ProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<void> execute(UserProfileEntity profile) async {
    // Validate profile data
    if (profile.name.trim().isEmpty) {
      throw Exception('Name cannot be empty');
    }

    if (profile.email != null && !_isValidEmail(profile.email!)) {
      throw Exception('Invalid email format');
    }

    if (profile.dateOfBirth != null &&
        profile.dateOfBirth!.isAfter(DateTime.now())) {
      throw Exception('Date of birth cannot be in the future');
    }

    await repository.updateUserProfile(profile);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
