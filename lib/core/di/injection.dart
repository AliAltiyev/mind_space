import 'package:get_it/get_it.dart';

import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/ai_insights_repository_impl.dart';
import '../../domain/repositories/ai_insights_repository.dart';
import '../database/database.dart';
import '../network/api_client.dart';

/// Глобальный экземпляр GetIt для DI
final GetIt getIt = GetIt.instance;

/// Инициализация всех зависимостей
Future<void> configureDependencies() async {
  // Регистрация основных зависимостей
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<ApiClient>(ApiClient(createDioClient()));

  // Регистрация AI зависимостей
  getIt.registerSingleton<RemoteDataSource>(
    RemoteDataSource(createDioClient()),
  );

  getIt.registerSingleton<AIInsightsRepository>(
    AIInsightsRepositoryImpl(
      remoteDataSource: getIt<RemoteDataSource>(),
      database: getIt<AppDatabase>(),
    ),
  );
}
