import '../entities/user_stats_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserStatsUseCase {
  final ProfileRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<UserStatsEntity> execute() async {
    return await repository.getUserStats();
  }
}
