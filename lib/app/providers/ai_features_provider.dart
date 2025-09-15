import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/openrouter_client.dart';
import '../../core/database/database.dart';
import '../../features/ai/data/datasources/ai_local_datasource.dart';
import '../../features/ai/data/datasources/openrouter_datasource.dart';
import '../../features/ai/data/repositories/ai_repository_impl.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/ai/domain/usecases/analyze_mood_patterns_usecase.dart';
import '../../features/ai/domain/usecases/generate_gratitude_prompts_usecase.dart';
import '../../features/ai/domain/usecases/get_ai_insights_usecase.dart';
import '../../features/ai/domain/usecases/suggest_meditation_usecase.dart';
import '../../features/ai/presentation/blocs/ai_insights_bloc.dart';
import '../../features/ai/presentation/blocs/gratitude_bloc.dart';
import '../../features/ai/presentation/blocs/meditation_bloc.dart';
import '../../features/ai/presentation/blocs/patterns_bloc.dart';
import 'app_providers.dart';

/// Провайдер для OpenRouter клиента
final openRouterClientProvider = Provider<OpenRouterClient>((ref) {
  return OpenRouterClient();
});

/// Провайдер для локального хранилища AI
final aiLocalDataSourceProvider = Provider<AILocalDataSource>((ref) {
  return AILocalDataSource();
});

/// Провайдер для OpenRouter DataSource
final openRouterDataSourceProvider = Provider<OpenRouterDataSource>((ref) {
  final client = ref.watch(openRouterClientProvider);
  return OpenRouterDataSource(client);
});

/// Провайдер для AI репозитория
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final remoteDataSource = ref.watch(openRouterDataSourceProvider);
  final localDataSource = ref.watch(aiLocalDataSourceProvider);

  return AIRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Провайдер для Use Cases
final getAIInsightsUseCaseProvider = Provider<GetAIInsightsUseCase>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return GetAIInsightsUseCase(repository);
});

final analyzeMoodPatternsUseCaseProvider = Provider<AnalyzeMoodPatternsUseCase>(
  (ref) {
    final repository = ref.watch(aiRepositoryProvider);
    return AnalyzeMoodPatternsUseCase(repository);
  },
);

final generateGratitudePromptsUseCaseProvider =
    Provider<GenerateGratitudePromptsUseCase>((ref) {
      final repository = ref.watch(aiRepositoryProvider);
      return GenerateGratitudePromptsUseCase(repository);
    });

final suggestMeditationUseCaseProvider = Provider<SuggestMeditationUseCase>((
  ref,
) {
  final repository = ref.watch(aiRepositoryProvider);
  return SuggestMeditationUseCase(repository);
});

/// Провайдеры для Bloc'ов
final aiInsightsBlocProvider = Provider<AIInsightsBloc>((ref) {
  final useCase = ref.watch(getAIInsightsUseCaseProvider);
  return AIInsightsBloc(useCase);
});

final patternsBlocProvider = Provider<PatternsBloc>((ref) {
  final useCase = ref.watch(analyzeMoodPatternsUseCaseProvider);
  return PatternsBloc(useCase);
});

final gratitudeBlocProvider = Provider<GratitudeBloc>((ref) {
  final useCase = ref.watch(generateGratitudePromptsUseCaseProvider);
  return GratitudeBloc(useCase);
});

final meditationBlocProvider = Provider<MeditationBloc>((ref) {
  final useCase = ref.watch(suggestMeditationUseCaseProvider);
  return MeditationBloc(useCase);
});

/// Провайдер для получения записей настроения
final moodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  // Получаем записи за последние 30 дней
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));

  return await database.getMoodsForPeriod(startDate, endDate);
});

/// Провайдер для получения последних записей настроения (7 дней)
final recentMoodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  // Получаем записи за последние 7 дней
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 7));

  return await database.getMoodsForPeriod(startDate, endDate);
});

/// Провайдер для получения всех записей настроения
final allMoodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  // Получаем все записи
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 365));

  return await database.getMoodsForPeriod(startDate, endDate);
});
