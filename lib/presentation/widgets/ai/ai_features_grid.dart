import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_space/core/database/database.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../app/providers/ai_features_provider.dart';
import '../../../features/ai/presentation/blocs/ai_insights_bloc.dart';
import '../../../features/ai/presentation/blocs/gratitude_bloc.dart';
import '../../../features/ai/presentation/blocs/meditation_bloc.dart';
import '../../../features/ai/presentation/blocs/patterns_bloc.dart';
import '../../../features/ai/presentation/widgets/ai_insight_card.dart';
import '../../../features/ai/presentation/widgets/gratitude_suggestion_card.dart';
import '../../../features/ai/presentation/widgets/meditation_suggestion_card.dart';
import '../../../features/ai/presentation/widgets/pattern_analysis_card.dart';
import '../../widgets/core/amazing_glass_surface.dart' as amazing;

/// Сетка AI функций для главного экрана
class AIFeaturesGrid extends ConsumerWidget {
  final List<MoodEntry> moodEntries;
  final VoidCallback? onRefresh;

  const AIFeaturesGrid({super.key, required this.moodEntries, this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // AI Insights
        _buildAIFeatureCard(
          context: context,
          ref: ref,
          title: 'AI Insights',
          icon: Icons.psychology,
          routeName: 'ai-insights',
          effectType: amazing.GlassEffectType.neon,
          colorScheme: amazing.ColorScheme.neon,
          child: BlocProvider<AIInsightsBloc>(
            create: (context) => ref.read(aiInsightsBlocProvider),
            child: _AIInsightsWidget(moodEntries: moodEntries),
          ),
        ),

        const SizedBox(height: 16),

        // Patterns Analysis
        _buildAIFeatureCard(
          context: context,
          ref: ref,
          title: 'Patterns',
          icon: Icons.analytics,
          routeName: 'ai-patterns',
          effectType: amazing.GlassEffectType.cyber,
          colorScheme: amazing.ColorScheme.cyber,
          child: BlocProvider<PatternsBloc>(
            create: (context) => ref.read(patternsBlocProvider),
            child: _PatternsWidget(moodEntries: moodEntries),
          ),
        ),

        const SizedBox(height: 16),

        // Gratitude & Meditation Row
        Row(
          children: [
            Expanded(
              child: _buildAIFeatureCard(
                context: context,
                ref: ref,
                title: 'Gratitude',
                icon: Icons.favorite,
                routeName: 'ai-gratitude',
                effectType: amazing.GlassEffectType.cosmic,
                colorScheme: amazing.ColorScheme.cosmic,
                child: BlocProvider<GratitudeBloc>(
                  create: (context) => ref.read(gratitudeBlocProvider),
                  child: _GratitudeWidget(moodEntries: moodEntries),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _buildAIFeatureCard(
                context: context,
                ref: ref,
                title: 'Meditation',
                icon: Icons.self_improvement,
                routeName: 'ai-meditation',
                effectType: amazing.GlassEffectType.rainbow,
                colorScheme: amazing.ColorScheme.rainbow,
                child: BlocProvider<MeditationBloc>(
                  create: (context) => ref.read(meditationBlocProvider),
                  child: _MeditationWidget(moodEntries: moodEntries),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIFeatureCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required Widget child,
    String? routeName,
    amazing.GlassEffectType effectType = amazing.GlassEffectType.neon,
    amazing.ColorScheme colorScheme = amazing.ColorScheme.neon,
  }) {
    return GestureDetector(
      onTap: routeName != null ? () => context.go('/$routeName') : null,
      child: amazing.AmazingGlassSurface(
        effectType: effectType,
        colorScheme: colorScheme,
        child: Container(
          height: 200, // Fixed height to prevent unbounded constraints
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: colorScheme.neonColors.take(2).toList(),
                        stops: const [0.0, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.borderColor.withOpacity(0.8),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: colorScheme.borderColor,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (routeName != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colorScheme.neonColors.take(2).toList(),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.borderColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет для AI Insights
class _AIInsightsWidget extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const _AIInsightsWidget({required this.moodEntries});

  @override
  State<_AIInsightsWidget> createState() => _AIInsightsWidgetState();
}

class _AIInsightsWidgetState extends State<_AIInsightsWidget> {
  @override
  void initState() {
    super.initState();
    // Загружаем AI инсайты при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.moodEntries.isNotEmpty) {
        try {
          context.read<AIInsightsBloc>().add(
            LoadAIInsights(widget.moodEntries, days: 7),
          );
        } catch (e) {
          debugPrint('Error loading AI insights: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AIInsightsBloc, AIInsightsState>(
      builder: (context, state) {
        if (state is AIInsightsLoading) {
          return const AIInsightLoadingCard(height: 120);
        } else if (state is AIInsightsLoaded) {
          return SizedBox(
            height: 120,
            child: AIInsightCard(
              insight: state.insight,
              height: 120,
              showSuggestions: false,
              onTap: () {
                // TODO: Navigate to detailed insights
              },
            ),
          );
        } else if (state is AIInsightsError) {
          return AIInsightErrorCard(
            message: state.message,
            suggestion: state.suggestion,
            height: 120,
            onRetry: () {
              context.read<AIInsightsBloc>().add(
                RefreshAIInsights(widget.moodEntries, days: 7),
              );
            },
          );
        }

        // Показываем сообщение, если нет данных
        return Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, color: Colors.white70, size: 32),
              SizedBox(height: 8),
              Text(
                'home.add_mood_entries'.tr(),
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Виджет для Patterns Analysis
class _PatternsWidget extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const _PatternsWidget({required this.moodEntries});

  @override
  State<_PatternsWidget> createState() => _PatternsWidgetState();
}

class _PatternsWidgetState extends State<_PatternsWidget> {
  @override
  void initState() {
    super.initState();
    // Загружаем анализ паттернов при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.moodEntries.isNotEmpty) {
        try {
          if (widget.moodEntries.length >= 7) {
            context.read<PatternsBloc>().add(
              LoadPatternAnalysis(widget.moodEntries, days: 30),
            );
          } else {
            context.read<PatternsBloc>().add(
              QuickPatternAnalysis(widget.moodEntries),
            );
          }
        } catch (e) {
          debugPrint('Error loading patterns: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatternsBloc, PatternsState>(
      builder: (context, state) {
        if (state is PatternsLoading) {
          return const PatternAnalysisLoadingCard(height: 120);
        } else if (state is PatternsLoaded) {
          return SizedBox(
            height: 120,
            child: PatternAnalysisCard(
              patterns: state.patterns,
              height: 120,
              onTap: () {
                // TODO: Navigate to detailed patterns
              },
            ),
          );
        } else if (state is PatternsError) {
          return PatternAnalysisErrorCard(
            message: state.message,
            suggestion: state.suggestion,
            height: 120,
            onRetry: () {
              context.read<PatternsBloc>().add(
                RefreshPatternAnalysis(widget.moodEntries, days: 30),
              );
            },
          );
        }

        // Показываем сообщение, если нет данных
        return Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, color: Colors.white70, size: 32),
              SizedBox(height: 8),
              Text(
                'home.add_mood_entries'.tr(),
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Виджет для Gratitude
class _GratitudeWidget extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const _GratitudeWidget({required this.moodEntries});

  @override
  State<_GratitudeWidget> createState() => _GratitudeWidgetState();
}

class _GratitudeWidgetState extends State<_GratitudeWidget> {
  @override
  void initState() {
    super.initState();
    // Загружаем благодарственные предложения при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.moodEntries.isNotEmpty) {
        try {
          context.read<GratitudeBloc>().add(
            LoadGratitudeForCurrentMood(widget.moodEntries),
          );
        } catch (e) {
          debugPrint('Error loading gratitude: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GratitudeBloc, GratitudeState>(
      builder: (context, state) {
        if (state is GratitudeLoading) {
          return const GratitudeSuggestionLoadingCard(height: 120);
        } else if (state is GratitudeLoaded) {
          return SizedBox(
            height: 120,
            child: GratitudeSuggestionCard(
              gratitude: state.gratitude,
              height: 120,
              onTap: () {
                // TODO: Navigate to gratitude journal
              },
            ),
          );
        } else if (state is GratitudeError) {
          return GratitudeSuggestionErrorCard(
            message: state.message,
            suggestion: state.suggestion,
            height: 120,
            onRetry: () {
              context.read<GratitudeBloc>().add(
                RefreshGratitudePrompts(widget.moodEntries),
              );
            },
          );
        }

        // Показываем сообщение, если нет данных
        return Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, color: Colors.white70, size: 32),
              SizedBox(height: 8),
              Text(
                'home.add_mood_entries'.tr(),
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Виджет для Meditation
class _MeditationWidget extends StatefulWidget {
  final List<MoodEntry> moodEntries;

  const _MeditationWidget({required this.moodEntries});

  @override
  State<_MeditationWidget> createState() => _MeditationWidgetState();
}

class _MeditationWidgetState extends State<_MeditationWidget> {
  @override
  void initState() {
    super.initState();
    // Загружаем медитацию при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.moodEntries.isNotEmpty) {
        try {
          context.read<MeditationBloc>().add(
            LoadMeditationForTimeOfDay(widget.moodEntries),
          );
        } catch (e) {
          debugPrint('Error loading meditation: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeditationBloc, MeditationState>(
      builder: (context, state) {
        if (state is MeditationLoading) {
          return const MeditationSuggestionLoadingCard(height: 120);
        } else if (state is MeditationLoaded) {
          return SizedBox(
            height: 120,
            child: MeditationSuggestionCard(
              meditation: state.meditation,
              height: 120,
              onTap: () {
                // TODO: Navigate to meditation
              },
              onStart: () {
                // TODO: Start meditation session
              },
            ),
          );
        } else if (state is MeditationError) {
          return MeditationSuggestionErrorCard(
            message: state.message,
            suggestion: state.suggestion,
            height: 120,
            onRetry: () {
              context.read<MeditationBloc>().add(
                RefreshMeditationSession(widget.moodEntries),
              );
            },
          );
        }

        // Показываем сообщение, если нет данных
        return Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, color: Colors.white70, size: 32),
              SizedBox(height: 8),
              Text(
                'home.add_mood_entries'.tr(),
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
