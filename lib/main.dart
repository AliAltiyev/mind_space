import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants/app_design.dart';
import 'features/mood_tracking/data/datasources/mood_local_datasource.dart';
import 'features/mood_tracking/data/models/mood_entry_model.dart';
import 'features/mood_tracking/data/repositories/mood_repository_impl.dart';
import 'features/mood_tracking/presentation/bloc/mood_tracking_bloc.dart';
import 'features/mood_tracking/presentation/bloc/mood_tracking_event.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MoodEntryModelAdapter());

  // Инициализация локального источника данных
  final moodLocalDataSource = MoodLocalDataSourceImpl();
  await moodLocalDataSource.init();

  // Создание репозитория
  final moodRepository = MoodRepositoryImpl(
    localDataSource: moodLocalDataSource,
  );

  runApp(MindSpaceApp(moodRepository: moodRepository));
}

class MindSpaceApp extends StatelessWidget {
  final MoodRepositoryImpl moodRepository;

  const MindSpaceApp({super.key, required this.moodRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.inter().fontFamily,
        scaffoldBackgroundColor: AppDesign.primaryBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppDesign.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            borderSide: BorderSide(
              color: AppDesign.accentColor.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            borderSide: const BorderSide(color: AppDesign.accentColor),
          ),
        ),
      ),
      home: BlocProvider(
        create: (context) =>
            MoodTrackingBloc(moodRepository: moodRepository)
              ..add(LoadMoodEntries()),
        child: const OnboardingScreen(),
      ),
    );
  }
}
