import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfileEntity> execute() async {
    return await repository.getUserProfile();
  }
}
