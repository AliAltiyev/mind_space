import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../app/providers/ai_features_provider.dart';

/// AI Инсайты - строгий и понятный дизайн
class AIInsightsPageClean extends ConsumerWidget {
  const AIInsightsPageClean({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEntriesAsync = ref.watch(allMoodEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ai.insights.title'.tr()),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(allMoodEntriesProvider);
            },
          ),
        ],
      ),
      body: allEntriesAsync.when(
        data: (entries) => _buildInsightsContent(context, entries),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  /// Основной контент инсайтов
  Widget _buildInsightsContent(BuildContext context, List<dynamic> entries) {
    if (entries.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Обзор
          _buildOverview(entries),

          const SizedBox(height: 24),

          // Анализ настроений
          _buildMoodAnalysis(entries),

          const SizedBox(height: 24),

          // Паттерны
          _buildPatterns(entries),

          const SizedBox(height: 24),

          // Рекомендации
          _buildRecommendations(entries),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Обзор
  Widget _buildOverview(List<dynamic> entries) {
    final totalEntries = entries.length;
    final avgMood = entries.isEmpty
        ? 0.0
        : entries.map((e) => e.moodValue).reduce((a, b) => a + b) /
              entries.length;
    final thisWeek = entries
        .where(
          (e) => e.createdAt.isAfter(
            DateTime.now().subtract(const Duration(days: 7)),
          ),
        )
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ai.insights.data_overview'.tr(),
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  title: 'stats.total_entries'.tr(),
                  value: totalEntries.toString(),
                  icon: Icons.list_alt,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightCard(
                  title: 'stats.average_mood'.tr(),
                  value: avgMood.toStringAsFixed(1),
                  icon: Icons.sentiment_satisfied,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _InsightCard(
            title: 'ai.insights.weekly_entries'.tr(),
            value:
                '$thisWeek ${thisWeek == 1 ? 'stats.entry'.tr() : 'stats.entries'.tr()}',
            icon: Icons.calendar_today,
            color: AppColors.info,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  /// Анализ настроений
  Widget _buildMoodAnalysis(List<dynamic> entries) {
    final moodCounts = List.generate(
      5,
      (index) => entries.where((e) => e.moodValue == index + 1).length,
    );
    final total = entries.length;
    final dominantMood =
        moodCounts.indexOf(moodCounts.reduce((a, b) => a > b ? a : b)) + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning, AppColors.success],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ai.insights.mood_analysis'.tr(),
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Доминирующее настроение
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getMoodColor(dominantMood).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: getMoodColor(dominantMood).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: getMoodGradient(dominantMood),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _getMoodIcon(dominantMood),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ai.insights.dominant_mood'.tr(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMoodLabel(dominantMood),
                        style: AppTypography.h4.copyWith(
                          color: getMoodColor(dominantMood),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${((moodCounts[dominantMood - 1] / total) * 100).toStringAsFixed(0)}%',
                  style: AppTypography.h3.copyWith(
                    color: getMoodColor(dominantMood),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Распределение настроений
          ...List.generate(5, (index) {
            final moodValue = index + 1;
            final count = moodCounts[index];
            final percentage = total == 0 ? 0.0 : (count / total) * 100;

            return _MoodDistributionBar(
              moodValue: moodValue,
              count: count,
              percentage: percentage,
              total: total,
            );
          }),
        ],
      ),
    );
  }

  /// Паттерны
  Widget _buildPatterns(List<dynamic> entries) {
    final weeklyPattern = _getWeeklyPattern(entries);
    final monthlyPattern = _getMonthlyPattern(entries);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ai.insights.patterns'.tr(),
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Недельный паттерн
          _PatternCard(
            title: 'ai.insights.weekly_pattern'.tr(),
            description: weeklyPattern,
            icon: Icons.calendar_view_week,
            color: AppColors.primary,
          ),

          const SizedBox(height: 12),

          // Месячный паттерн
          _PatternCard(
            title: 'ai.insights.monthly_pattern'.tr(),
            description: monthlyPattern,
            icon: Icons.calendar_month,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  /// Рекомендации
  Widget _buildRecommendations(List<dynamic> entries) {
    final recommendations = _generateRecommendations(entries);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Рекомендации',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...recommendations.map(
            (recommendation) => _RecommendationCard(
              title: recommendation.title,
              description: recommendation.description,
              icon: recommendation.icon,
              priority: recommendation.priority,
            ),
          ),
        ],
      ),
    );
  }

  /// Пустое состояние
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'ai.insights.no_data_for_analysis'.tr(),
            style: AppTypography.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'ai.insights.add_entries_for_insights'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/add-entry'),
            child: Text('mood.add_mood'.tr()),
          ),
        ],
      ),
    );
  }

  /// Состояние загрузки
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Состояние ошибки
  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'common.error'.tr(),
            style: AppTypography.h3.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Вспомогательные методы
  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 5:
        return Icons.sentiment_very_satisfied;
      case 4:
        return Icons.sentiment_satisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 1:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 5:
        return 'mood.moods.very_happy'.tr();
      case 4:
        return 'mood.moods.happy'.tr();
      case 3:
        return 'mood.moods.neutral'.tr();
      case 2:
        return 'mood.moods.sad'.tr();
      case 1:
        return 'mood.moods.very_sad'.tr();
      default:
        return 'stats.unknown'.tr();
    }
  }

  String _getWeeklyPattern(List<dynamic> entries) {
    if (entries.isEmpty) return 'ai.insights.insufficient_data'.tr();

    final weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final counts = List.generate(7, (index) => 0);

    for (final entry in entries) {
      final weekday = entry.createdAt.weekday - 1;
      counts[weekday]++;
    }

    final maxIndex = counts.indexOf(counts.reduce((a, b) => a > b ? a : b));
    return 'ai.insights.most_records_on'.tr(
      namedArgs: {'day': weekdays[maxIndex]},
    );
  }

  String _getMonthlyPattern(List<dynamic> entries) {
    if (entries.isEmpty) return 'ai.insights.insufficient_data'.tr();

    final now = DateTime.now();
    final thisMonth = entries
        .where(
          (e) => e.createdAt.month == now.month && e.createdAt.year == now.year,
        )
        .length;
    final lastMonth = entries
        .where(
          (e) =>
              e.createdAt.month == now.month - 1 &&
              e.createdAt.year == now.year,
        )
        .length;

    if (thisMonth > lastMonth) {
      return 'ai.insights.activity_growing'.tr(
        namedArgs: {'diff': (thisMonth - lastMonth).toString()},
      );
    } else if (thisMonth < lastMonth) {
      return 'ai.insights.activity_decreasing'.tr(
        namedArgs: {'diff': (lastMonth - thisMonth).toString()},
      );
    } else {
      return 'ai.insights.stable_activity'.tr();
    }
  }

  List<_Recommendation> _generateRecommendations(List<dynamic> entries) {
    final recommendations = <_Recommendation>[];

    if (entries.isEmpty) {
      recommendations.add(
        _Recommendation(
          title: 'ai.insights.start_tracking_mood'.tr(),
          description: 'ai.insights.add_first_entry_desc'.tr(),
          icon: Icons.add_circle_outline,
          priority: _Priority.high,
        ),
      );
      return recommendations;
    }

    final avgMood =
        entries.map((e) => e.moodValue).reduce((a, b) => a + b) /
        entries.length;

    if (avgMood < 3) {
      recommendations.add(
        _Recommendation(
          title: 'ai.insights.try_meditation'.tr(),
          description: 'ai.insights.meditation_help_mood'.tr(),
          icon: Icons.self_improvement,
          priority: _Priority.high,
        ),
      );
    }

    recommendations.add(
      _Recommendation(
        title: 'ai.insights.keep_gratitude_journal'.tr(),
        description: 'ai.insights.gratitude_journal_desc'.tr(),
        icon: Icons.favorite,
        priority: _Priority.medium,
      ),
    );

    recommendations.add(
      _Recommendation(
        title: 'ai.insights.track_mood_regularly'.tr(),
        description: 'ai.insights.daily_records_help'.tr(),
        icon: Icons.trending_up,
        priority: _Priority.medium,
      ),
    );

    return recommendations;
  }
}

/// Карточка инсайта
class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isFullWidth;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.h3.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Бар распределения настроения
class _MoodDistributionBar extends StatelessWidget {
  final int moodValue;
  final int count;
  final double percentage;
  final int total;

  const _MoodDistributionBar({
    required this.moodValue,
    required this.count,
    required this.percentage,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: getMoodGradient(moodValue),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getMoodIcon(moodValue), color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              _getMoodLabel(moodValue),
              style: AppTypography.bodyMedium,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: total == 0 ? 0.0 : count / total,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                getMoodColor(moodValue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTypography.caption,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 5:
        return Icons.sentiment_very_satisfied;
      case 4:
        return Icons.sentiment_satisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 1:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 5:
        return 'mood.moods.very_happy'.tr();
      case 4:
        return 'mood.moods.happy'.tr();
      case 3:
        return 'mood.moods.neutral'.tr();
      case 2:
        return 'mood.moods.sad'.tr();
      case 1:
        return 'mood.moods.very_sad'.tr();
      default:
        return 'stats.unknown'.tr();
    }
  }
}

/// Карточка паттерна
class _PatternCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _PatternCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Карточка рекомендации
class _RecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final _Priority priority;

  const _RecommendationCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getPriorityColor(priority).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(priority).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: _getPriorityColor(priority), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPriorityLabel(priority),
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(_Priority priority) {
    switch (priority) {
      case _Priority.high:
        return AppColors.error;
      case _Priority.medium:
        return AppColors.warning;
      case _Priority.low:
        return AppColors.success;
    }
  }

  String _getPriorityLabel(_Priority priority) {
    switch (priority) {
      case _Priority.high:
        return 'ai.insights.priority_high'.tr();
      case _Priority.medium:
        return 'ai.insights.priority_medium'.tr();
      case _Priority.low:
        return 'ai.insights.priority_low'.tr();
    }
  }
}

/// Класс рекомендации
class _Recommendation {
  final String title;
  final String description;
  final IconData icon;
  final _Priority priority;

  _Recommendation({
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
  });
}

/// Приоритет рекомендации
enum _Priority { high, medium, low }
