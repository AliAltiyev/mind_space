import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_animations/simple_animations.dart';

import '../constants/app_design.dart';
import '../features/mood_tracking/domain/entities/mood_entry.dart';
import '../features/mood_tracking/presentation/bloc/mood_tracking_bloc.dart';
import '../features/mood_tracking/presentation/bloc/mood_tracking_event.dart';
import '../features/mood_tracking/presentation/bloc/mood_tracking_state.dart';
import '../widgets/animated_mood_blob.dart';
import '../widgets/glass_card.dart';
import 'add_mood_screen.dart';
import 'mood_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _rippleController;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _rippleController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: BlocBuilder<MoodTrackingBloc, MoodTrackingState>(
            builder: (context, state) {
              if (state is MoodTrackingLoading) {
                return _buildLoadingState();
              }

              if (state is MoodTrackingError) {
                return _buildErrorState(state.message);
              }

              if (state is MoodTrackingLoaded) {
                return _buildLoadedState(state);
              }

              return _buildInitialState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppDesign.accentColor),
          ),
          const SizedBox(height: AppDesign.paddingLarge),
          Text(
            'Загрузка...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppDesign.accentColor),
          const SizedBox(height: AppDesign.paddingLarge),
          Text('Ошибка', style: AppTextStyles.headline2),
          const SizedBox(height: AppDesign.paddingMedium),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesign.paddingLarge),
          GlassButton(
            onPressed: () {
              context.read<MoodTrackingBloc>().add(LoadMoodEntries());
            },
            child: Text('Попробовать снова', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Добро пожаловать в MindSpace!',
            style: AppTextStyles.headline1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesign.paddingLarge),
          Text(
            'Начните отслеживать свое настроение',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppDesign.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(MoodTrackingLoaded state) {
    final todayEntries = state.entries.where((entry) {
      final now = DateTime.now();
      final entryDate = entry.createdAt;
      return now.year == entryDate.year &&
          now.month == entryDate.month &&
          now.day == entryDate.day;
    }).toList();

    final todayMood = todayEntries.isNotEmpty ? todayEntries.first.mood : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesign.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDesign.paddingXLarge),
          _buildMoodBlob(todayMood),
          const SizedBox(height: AppDesign.paddingXLarge),
          _buildTodaySection(todayEntries),
          const SizedBox(height: AppDesign.paddingLarge),
          _buildStatisticsSection(state.statistics),
          const SizedBox(height: AppDesign.paddingLarge),
          _buildRecentEntries(state.entries),
          const SizedBox(height: 100), // Отступ для FAB
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeIn(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Добро пожаловать!', style: AppTextStyles.headline1),
          const SizedBox(height: AppDesign.paddingSmall),
          Text(
            'Как дела сегодня?',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodBlob(MoodLevel? mood) {
    return Center(
      child: FadeIn(
        delay: const Duration(milliseconds: 400),
        child: AnimatedMoodBlob(
          mood: mood,
          size: 200,
          onTap: _openAddMoodScreen,
          isPulsing: true,
        ),
      ),
    );
  }

  Widget _buildTodaySection(List<MoodEntry> todayEntries) {
    return FadeIn(
      delay: const Duration(milliseconds: 600),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сегодня', style: AppTextStyles.headline3),
            const SizedBox(height: AppDesign.paddingMedium),
            if (todayEntries.isEmpty)
              _buildEmptyState()
            else
              ...todayEntries.asMap().entries.map((entry) {
                return _buildMoodEntryCard(entry.value, entry.key);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.paddingLarge),
      decoration: BoxDecoration(
        color: AppDesign.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
        border: Border.all(color: AppDesign.accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.sentiment_neutral, size: 48, color: AppDesign.accentColor),
          const SizedBox(height: AppDesign.paddingMedium),
          Text(
            'Пока нет записей за сегодня',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppDesign.textSecondary,
            ),
          ),
          const SizedBox(height: AppDesign.paddingSmall),
          Text(
            'Нажмите на каплю выше, чтобы добавить настроение',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEntryCard(MoodEntry entry, int index) {
    return FadeIn(
      delay: Duration(milliseconds: 800 + (index * 100)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.paddingMedium),
        padding: const EdgeInsets.all(AppDesign.paddingMedium),
        decoration: BoxDecoration(
          color: _getMoodColor(entry.mood).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
          border: Border.all(color: _getMoodColor(entry.mood).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(entry.mood.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppDesign.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.mood.label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: _getMoodColor(entry.mood),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: AppDesign.paddingSmall),
                    Text(
                      entry.note,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppDesign.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(Map<MoodLevel, int>? statistics) {
    if (statistics == null || statistics.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeIn(
      delay: const Duration(milliseconds: 800),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статистика за неделю', style: AppTextStyles.headline3),
            const SizedBox(height: AppDesign.paddingMedium),
            ...statistics.entries.map((entry) {
              final total = statistics.values.fold(
                0,
                (sum, count) => sum + count,
              );
              final percentage = (entry.value / total * 100).round();

              return Container(
                margin: const EdgeInsets.only(bottom: AppDesign.paddingMedium),
                child: Row(
                  children: [
                    Text(entry.key.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppDesign.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key.label,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppDesign.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDesign.paddingSmall),
                          LinearProgressIndicator(
                            value: entry.value / total,
                            backgroundColor: _getMoodColor(
                              entry.key,
                            ).withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getMoodColor(entry.key),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntries(List<MoodEntry> entries) {
    final recentEntries = entries.take(5).toList();

    return FadeIn(
      delay: const Duration(milliseconds: 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Последние записи', style: AppTextStyles.headline3),
              GlassButton(
                onPressed: _openMoodHistory,
                child: Text(
                  'Все записи',
                  style: AppTextStyles.button.copyWith(
                    color: AppDesign.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.paddingMedium),
          ...recentEntries.asMap().entries.map((entry) {
            return _buildMoodEntryCard(entry.value, entry.key);
          }),
        ],
      ),
    );
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.verySad:
        return AppDesign.verySadGradient[0];
      case MoodLevel.sad:
        return AppDesign.sadGradient[0];
      case MoodLevel.neutral:
        return AppDesign.neutralGradient[0];
      case MoodLevel.happy:
        return AppDesign.happyGradient[0];
      case MoodLevel.veryHappy:
        return AppDesign.veryHappyGradient[0];
    }
  }

  void _openAddMoodScreen() {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddMoodScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }

  void _openMoodHistory() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MoodHistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
        transitionDuration: AppAnimations.medium,
      ),
    );
  }
}

class FadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const FadeIn({super.key, required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      delay: delay,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: this.child,
          ),
        );
      },
    );
  }
}
