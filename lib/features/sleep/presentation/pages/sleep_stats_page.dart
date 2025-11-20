import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../app/providers/ai_features_provider.dart';
import '../../domain/entities/sleep_entry.dart';
import '../../domain/entities/sleep_insight.dart';
import '../../data/repositories/sleep_repository_impl.dart';
import '../../data/repositories/sleep_repository.dart';
import '../../../../core/api/groq_client.dart';
import '../widgets/sleep_background.dart';
import '../widgets/sleep_card.dart';

/// Провайдер для репозитория сна
final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  return SleepRepositoryImpl(
    database: ref.read(appDatabaseProvider),
    groqClient: GroqClient(),
  );
});

/// Провайдер для записей сна за последние 30 дней
final sleepEntriesProvider = FutureProvider<List<SleepEntry>>((ref) async {
  final repository = ref.read(sleepRepositoryProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));
  return await repository.getSleepEntries(startDate, endDate);
});

/// Провайдер для AI анализа сна
final sleepInsightProvider = FutureProvider<SleepInsight>((ref) async {
  final entriesAsync = ref.watch(sleepEntriesProvider);
  return entriesAsync.when(
    data: (entries) async {
      if (entries.isEmpty) {
        return SleepInsight(
          title: 'sleep.stats.insights.no_data_title'.tr(),
          description: 'sleep.stats.insights.no_data_description'.tr(),
          type: 'pattern',
          confidence: 0.0,
          createdAt: DateTime.now(),
        );
      }
      final repository = ref.read(sleepRepositoryProvider);
      return await repository.analyzeSleepPatterns(entries);
    },
    loading: () => SleepInsight(
      title: 'sleep.stats.insights.loading_title'.tr(),
      description: 'sleep.stats.insights.loading_description'.tr(),
      type: 'pattern',
      confidence: 0.0,
      createdAt: DateTime.now(),
    ),
    error: (_, __) => SleepInsight(
      title: 'sleep.stats.insights.error_title'.tr(),
      description: 'sleep.stats.insights.error_description'.tr(),
      type: 'pattern',
      confidence: 0.0,
      createdAt: DateTime.now(),
    ),
  );
});

/// Провайдер для рекомендаций по сну
final sleepRecommendationsProvider = FutureProvider<List<SleepInsight>>((
  ref,
) async {
  final entriesAsync = ref.watch(sleepEntriesProvider);
  final moodEntriesAsync = ref.watch(recentMoodEntriesProvider);

  return await entriesAsync.when(
    data: (entries) async {
      if (entries.isEmpty) {
        return [];
      }
      final moodEntries = moodEntriesAsync.when(
        data: (moods) => moods,
        loading: () => <MoodEntry>[],
        error: (_, __) => <MoodEntry>[],
      );
      final repository = ref.read(sleepRepositoryProvider);
      return await repository.getSleepRecommendations(entries, moodEntries);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Экран статистики сна
class SleepStatsPage extends ConsumerWidget {
  const SleepStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final entriesAsync = ref.watch(sleepEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'sleep.stats.title'.tr(),
          style: AppTypography.h3.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      body: SleepBackground(
        child: SafeArea(
          child: entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return _buildEmptyState(context, theme, colorScheme, isDark);
              }
              return _buildStatsContent(
                context,
                ref,
                theme,
                colorScheme,
                isDark,
                entries,
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
            error: (error, stack) => Center(
              child: SleepCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'sleep.stats.error'.tr(),
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SleepCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bedtime_outlined,
                size: 64,
                color: isDark
                    ? Colors.white.withOpacity(0.3)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(height: 24),
              Text(
                'sleep.stats.no_data'.tr(),
                style: AppTypography.h3.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'sleep.stats.no_data_description'.tr(),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
    List<SleepEntry> entries,
  ) {
    final avgDuration = SleepEntry.getAverageDuration(entries);
    final avgQuality = SleepEntry.getAverageQuality(entries);
    final hours = avgDuration ~/ 60;
    final minutes = avgDuration.toInt() % 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Общая статистика
          _buildOverallStats(
            context,
            colorScheme,
            isDark,
            hours,
            minutes,
            avgQuality,
            entries.length,
          ),

          const SizedBox(height: 24),

          // График продолжительности сна
          _buildDurationChart(context, colorScheme, isDark, entries),

          const SizedBox(height: 24),

          // График качества сна
          _buildQualityChart(context, colorScheme, isDark, entries),

          const SizedBox(height: 24),

          // AI Инсайты
          _buildAIInsights(context, ref, colorScheme, isDark),

          const SizedBox(height: 24),

          // Рекомендации
          _buildRecommendations(context, ref, colorScheme, isDark),

          const SizedBox(height: 24),

          // Корреляция с настроением
          _buildMoodCorrelation(context, ref, colorScheme, isDark, entries),
        ],
      ),
    );
  }

  Widget _buildOverallStats(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
    int hours,
    int minutes,
    double avgQuality,
    int totalEntries,
  ) {
    return SleepCard(
      child: Column(
        children: [
          Text(
            'sleep.stats.overview'.tr(),
            style: AppTypography.h4.copyWith(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SleepStatCard(
                  value: '$hoursч $minutesм',
                  label: 'sleep.stats.avg_duration'.tr(),
                  icon: Icons.access_time_rounded,
                  color: isDark
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SleepStatCard(
                  value: avgQuality.toStringAsFixed(1),
                  label: 'sleep.stats.avg_quality'.tr(),
                  icon: Icons.star_rounded,
                  color: isDark
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SleepStatCard(
                  value: totalEntries.toString(),
                  label: 'sleep.stats.total_entries'.tr(),
                  icon: Icons.bedtime_rounded,
                  color: isDark
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChart(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
    List<SleepEntry> entries,
  ) {
    final recentEntries = entries.take(14).toList().reversed.toList();
    if (recentEntries.isEmpty) {
      return SleepCard(
        child: _buildEmptyChartState(
          isDark: isDark,
          text: 'sleep.stats.no_data'.tr(),
        ),
      );
    }

    final chartColor = isDark
        ? const Color(0xFF6366F1)
        : const Color(0xFF475569);
    final dateLabels = recentEntries
        .map((entry) => DateFormat('dd.MM').format(entry.sleepStart))
        .toList();

    return SleepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'sleep.stats.duration_chart'.tr(),
            style: AppTypography.h4.copyWith(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        isDark ? Colors.black.withOpacity(0.7) : Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((barSpot) {
                        final hours = barSpot.y;
                        return LineTooltipItem(
                          '${hours.toStringAsFixed(1)} ч',
                          AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}ч',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= dateLabels.length ||
                            index.isOdd) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateLabels[index],
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.5)
                                  : const Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: recentEntries.asMap().entries.map((e) {
                      final hours = e.value.durationMinutes / 60;
                      return FlSpot(e.key.toDouble(), hours);
                    }).toList(),
                    isCurved: true,
                    color: chartColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: chartColor,
                          strokeWidth: 2,
                          strokeColor: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          chartColor.withOpacity(0.15),
                          chartColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 12,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 8,
                      strokeWidth: 1,
                      dashArray: [6, 4],
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFCBD5F5),
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : const Color(0xFF475569),
                        ),
                        labelResolver: (line) => '8ч',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityChart(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
    List<SleepEntry> entries,
  ) {
    final recentEntries = entries.take(14).toList().reversed.toList();
    if (recentEntries.isEmpty) {
      return SleepCard(
        child: _buildEmptyChartState(
          isDark: isDark,
          text: 'sleep.stats.no_data'.tr(),
        ),
      );
    }
    final baseColor = isDark
        ? const Color(0xFF6366F1)
        : const Color(0xFF475569);
    final dateLabels = recentEntries
        .map((entry) => DateFormat('dd.MM').format(entry.sleepStart))
        .toList();

    return SleepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'sleep.stats.quality_chart'.tr(),
            style: AppTypography.h4.copyWith(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        isDark ? Colors.black.withOpacity(0.7) : Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)} ★',
                        AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= dateLabels.length ||
                            index.isOdd) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateLabels[index],
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.5)
                                  : const Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: recentEntries.asMap().entries.map((e) {
                  final quality = e.value.quality.toDouble();
                  final gradient = LinearGradient(
                    colors: [baseColor.withOpacity(0.2), baseColor],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  );
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: quality,
                        gradient: gradient,
                        width: 12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  );
                }).toList(),
                maxY: 5,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 4,
                      dashArray: [6, 4],
                      strokeWidth: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFFE5E7EB),
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 8),
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : const Color(0xFF475569),
                        ),
                        labelResolver: (line) => '4★',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartState({required bool isDark, required String text}) {
    return SizedBox(
      height: 140,
      child: Center(
        child: Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? Colors.white.withOpacity(0.7)
                : const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAIInsights(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final insightAsync = ref.watch(sleepInsightProvider);
    final accentColor = isDark
        ? const Color(0xFF6366F1)
        : const Color(0xFF475569);

    return insightAsync.when(
      data: (insight) => SleepCard(
        glowColor: accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_rounded, color: accentColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  'sleep.stats.ai_insights'.tr(),
                  style: AppTypography.h4.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              insight.title,
              style: AppTypography.bodyLarge.copyWith(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              insight.description,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecommendations(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final recommendationsAsync = ref.watch(sleepRecommendationsProvider);
    final accentColor = isDark
        ? const Color(0xFF6366F1)
        : const Color(0xFF475569);

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) return const SizedBox.shrink();

        return SleepCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: accentColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'sleep.stats.recommendations'.tr(),
                    style: AppTypography.h4.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.title,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rec.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? Colors.white.withOpacity(0.7)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMoodCorrelation(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    bool isDark,
    List<SleepEntry> sleepEntries,
  ) {
    final moodEntriesAsync = ref.watch(recentMoodEntriesProvider);

    return moodEntriesAsync.when(
      data: (moodEntries) {
        if (moodEntries.isEmpty || sleepEntries.isEmpty) {
          return const SizedBox.shrink();
        }

        // Вычисляем корреляцию
        final correlation = _calculateCorrelation(sleepEntries, moodEntries);
        final accentColor = isDark
            ? const Color(0xFF6366F1)
            : const Color(0xFF475569);

        return SleepCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: accentColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'sleep.stats.mood_correlation'.tr(),
                    style: AppTypography.h4.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getCorrelationText(correlation),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  double _calculateCorrelation(
    List<SleepEntry> sleepEntries,
    List<MoodEntry> moodEntries,
  ) {
    // Упрощенный расчет корреляции
    // Сопоставляем сон и настроение по датам
    final correlations = <double>[];

    for (final sleep in sleepEntries) {
      final sleepDate = DateTime(
        sleep.sleepStart.year,
        sleep.sleepStart.month,
        sleep.sleepStart.day,
      );

      final mood = moodEntries.firstWhere((m) {
        final moodDate = DateTime(
          m.createdAt.year,
          m.createdAt.month,
          m.createdAt.day,
        );
        return moodDate.isAtSameMomentAs(sleepDate);
      }, orElse: () => moodEntries.first);

      // Нормализуем значения (0-1)
      final normalizedSleep = sleep.quality / 5.0;
      final normalizedMood = mood.moodValue / 5.0;

      // Простая корреляция
      correlations.add((normalizedSleep + normalizedMood) / 2);
    }

    if (correlations.isEmpty) return 0.0;
    return correlations.reduce((a, b) => a + b) / correlations.length;
  }

  String _getCorrelationText(double correlation) {
    if (correlation >= 0.7) {
      return 'sleep.stats.strong_correlation'.tr();
    } else if (correlation >= 0.5) {
      return 'sleep.stats.moderate_correlation'.tr();
    } else {
      return 'sleep.stats.weak_correlation'.tr();
    }
  }
}
