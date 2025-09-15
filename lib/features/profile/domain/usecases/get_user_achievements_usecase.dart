import '../entities/user_achievements_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserAchievementsUseCase {
  final ProfileRepository repository;

  GetUserAchievementsUseCase(this.repository);

  Future<UserAchievementsEntity> execute() async {
    return await repository.getUserAchievements();
  }
}
