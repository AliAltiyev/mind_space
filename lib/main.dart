import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers/ai_features_provider.dart';
import 'app/providers/profile_providers.dart';
import 'app/routing/app_router.dart';
import 'core/di/injection.dart';
import 'features/ai/presentation/blocs/ai_insights_bloc.dart';
import 'features/ai/presentation/blocs/gratitude_bloc.dart';
import 'features/ai/presentation/blocs/meditation_bloc.dart';
import 'features/ai/presentation/blocs/patterns_bloc.dart';
import 'features/profile/presentation/blocs/achievements_bloc.dart';
import 'features/profile/presentation/blocs/preferences_bloc.dart';
import 'features/profile/presentation/blocs/profile_bloc.dart';
import 'features/profile/presentation/blocs/stats_bloc.dart';
import 'shared/presentation/theme/app_theme.dart' as app_theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локализации
  await EasyLocalization.ensureInitialized();

  // Инициализация DI
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: MindSpaceApp()),
    ),
  );
}

/// Главное приложение
class MindSpaceApp extends ConsumerWidget {
  const MindSpaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MultiBlocProvider(
      providers: [
        // AI Bloc'и
        BlocProvider<AIInsightsBloc>(
          create: (context) => ref.read(aiInsightsBlocProvider),
        ),
        BlocProvider<PatternsBloc>(
          create: (context) => ref.read(patternsBlocProvider),
        ),
        BlocProvider<GratitudeBloc>(
          create: (context) => ref.read(gratitudeBlocProvider),
        ),
        BlocProvider<MeditationBloc>(
          create: (context) => ref.read(meditationBlocProvider),
        ),

        // Profile Bloc'и
        BlocProvider<ProfileBloc>(
          create: (context) => ref.read(profileBlocProvider),
        ),
        BlocProvider<PreferencesBloc>(
          create: (context) => ref.read(preferencesBlocProvider),
        ),
        BlocProvider<StatsBloc>(
          create: (context) => ref.read(statsBlocProvider),
        ),
        BlocProvider<AchievementsBloc>(
          create: (context) => ref.read(achievementsBlocProvider),
        ),
      ],
      child: MaterialApp.router(
        title: 'Mind Space',
        debugShowCheckedModeBanner: false,

        // Локализация
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        // Тема
        theme: app_theme.AppTheme.lightTheme,

        // Роутинг
        routerConfig: router,

        // Настройки
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      ),
    );
  }
}
