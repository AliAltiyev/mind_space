import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/database.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../app/providers/ai_features_provider.dart';
import '../../domain/entities/sleep_entry.dart';
import '../../domain/entities/sleep_insight.dart';
import '../../data/repositories/sleep_repository_impl.dart';
import '../../data/repositories/sleep_repository.dart';
import '../../../../core/api/groq_client.dart';

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

  return entriesAsync.when(
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
    loading: () async => [],
    error: (_, __) async => [],
  );
});

/// Экран статистики сна - Профессиональный дизайн
class SleepStatsPage extends ConsumerStatefulWidget {
  const SleepStatsPage({super.key});

  @override
  ConsumerState<SleepStatsPage> createState() => _SleepStatsPageState();
}

class _SleepStatsPageState extends ConsumerState<SleepStatsPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    // Запускаем анимацию графика с небольшой задержкой
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _chartAnimationController.forward();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Обновляем данные при возврате в приложение
    if (state == AppLifecycleState.resumed && mounted) {
      ref.invalidate(sleepEntriesProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final entriesAsync = ref.watch(sleepEntriesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Современный AppBar
            _buildModernAppBar(context, isDark),

            // Основной контент
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }
                  return _buildStatsContent(context, ref, isDark, entries);
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
                error: (error, stack) => _buildErrorState(context, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.arrow_left,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sleep.stats.title'.tr(),
                  style: AppTypography.h3.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Последние 30 дней',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Кнопка обновления
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              ref.invalidate(sleepEntriesProvider);
              // Перезапускаем анимацию графика
              _chartAnimationController.reset();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _chartAnimationController.forward();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.arrow_clockwise,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.bed_double,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'sleep.stats.no_data'.tr(),
              style: AppTypography.h3.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'sleep.stats.no_data_description'.tr(),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'sleep.stats.error'.tr(),
              style: AppTypography.h4.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    List<SleepEntry> entries,
  ) {
    final avgDuration = SleepEntry.getAverageDuration(entries);
    final avgQuality = SleepEntry.getAverageQuality(entries);
    final hours = avgDuration ~/ 60;
    final minutes = avgDuration.toInt() % 60;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Ключевые метрики
              _buildKeyMetrics(
                isDark,
                hours,
                minutes,
                avgQuality,
                entries.length,
              ),

              const SizedBox(height: 24),

              // График продолжительности
              _buildAnimatedChart(
                child: _buildDurationChart(isDark, entries),
                delay: 300,
              ),

              const SizedBox(height: 24),

              // График качества
              _buildAnimatedChart(
                child: _buildQualityChart(isDark, entries),
                delay: 400,
              ),

              const SizedBox(height: 24),

              // AI Инсайты
              _buildAnimatedChart(
                child: _buildAIInsights(context, ref, isDark),
                delay: 500,
              ),

              const SizedBox(height: 24),

              // Рекомендации
              _buildAnimatedChart(
                child: _buildRecommendations(context, ref, isDark),
                delay: 600,
              ),

              const SizedBox(height: 24),

              // Корреляция с настроением
              _buildAnimatedChart(
                child: _buildMoodCorrelation(context, ref, isDark, entries),
                delay: 700,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedChart({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildKeyMetrics(
    bool isDark,
    int hours,
    int minutes,
    double avgQuality,
    int totalEntries,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildAnimatedMetricCard(
                  icon: CupertinoIcons.clock_fill,
                  value: '$hoursч $minutesм',
                  label: 'sleep.stats.avg_duration'.tr(),
                  color: AppColors.primary,
                  isDark: isDark,
                  delay: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedMetricCard(
                  icon: CupertinoIcons.star_fill,
                  value: avgQuality.toStringAsFixed(1),
                  label: 'sleep.stats.avg_quality'.tr(),
                  color: AppColors.primaryLight,
                  isDark: isDark,
                  delay: 100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedMetricCard(
                  icon: CupertinoIcons.bed_double_fill,
                  value: totalEntries.toString(),
                  label: 'sleep.stats.total_entries'.tr(),
                  color: AppColors.primaryDark,
                  isDark: isDark,
                  delay: 200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMetricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: _buildMetricCard(
            icon: icon,
            value: value,
            label: label,
            color: color,
            isDark: isDark,
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChart(bool isDark, List<SleepEntry> entries) {
    // Создаем копию списка для сортировки
    final entriesCopy = List<SleepEntry>.from(entries);

    // Сортируем по дате и времени начала сна (от старых к новым)
    entriesCopy.sort((a, b) {
      // Сравниваем по дате и времени начала сна
      final startCompare = a.sleepStart.compareTo(b.sleepStart);
      if (startCompare != 0) return startCompare;
      // Если время начала одинаковое, сравниваем по времени окончания
      return a.sleepEnd.compareTo(b.sleepEnd);
    });

    // Берем последние 14 записей (самые новые) - они уже отсортированы от старых к новым
    final recentEntries = entriesCopy.length > 14
        ? entriesCopy.sublist(entriesCopy.length - 14)
        : entriesCopy;
    if (recentEntries.isEmpty) {
      return _buildEmptyChartCard(isDark, 'sleep.stats.duration_chart'.tr());
    }

    final chartColor = AppColors.primary;
    final dateLabels = recentEntries
        .map((entry) => DateFormat('dd.MM').format(entry.sleepStart))
        .toList();

    // Вычисляем максимальное значение для правильного масштабирования
    final allHours = recentEntries
        .map((e) => e.durationMinutes / 60.0)
        .toList();
    if (allHours.isEmpty) {
      return _buildEmptyChartCard(isDark, 'sleep.stats.duration_chart'.tr());
    }

    final maxHours = allHours.reduce((a, b) => a > b ? a : b);

    // Добавляем 25% отступ сверху для комфортного отображения
    // Округляем до ближайшего целого числа вверх
    double maxY = (maxHours * 1.25).ceil().toDouble();

    // Минимум 8 часов для нормального отображения
    if (maxY < 8.0) {
      maxY = 8.0;
    }

    // Для очень больших значений (больше 24 часов) ограничиваем до 24
    if (maxY > 24.0) {
      maxY = 24.0;
    }

    // Гарантируем, что maxY всегда больше максимального значения данных
    // Добавляем небольшой запас на случай округления
    if (maxY <= maxHours) {
      maxY = (maxHours * 1.3).ceil().toDouble();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: chartColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(CupertinoIcons.clock, color: chartColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'sleep.stats.duration_chart'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            isDark ? AppColors.darkSurface : Colors.white,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final hours = spot.y;
                            return LineTooltipItem(
                              '${hours.toStringAsFixed(1)} ч',
                              AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval:
                          maxY /
                          6, // Динамический интервал в зависимости от maxY
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceVariant,
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
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
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
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
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
                          final index = e.key;
                          final entry = e.value;
                          final hours = entry.durationMinutes / 60.0;
                          // Гарантируем, что значение не превышает maxY
                          final clampedHours = hours.clamp(0.0, maxY);
                          // Применяем анимацию - линия появляется постепенно
                          final animatedHours =
                              clampedHours * _chartAnimation.value;
                          // Используем индекс как X координату (0, 1, 2, ...)
                          return FlSpot(index.toDouble(), animatedHours);
                        }).toList(),
                        isCurved: true,
                        color: chartColor,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: chartColor,
                              strokeWidth: 3,
                              strokeColor: isDark
                                  ? AppColors.darkBackground
                                  : Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              chartColor.withOpacity(0.2),
                              chartColor.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    minY: 0,
                    maxY: maxY,
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        // Референсная линия на 8 часов (рекомендуемая норма)
                        if (maxY >= 8)
                          HorizontalLine(
                            y: 8,
                            strokeWidth: 1,
                            dashArray: [6, 4],
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.surfaceVariant,
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 8),
                              style: AppTypography.caption.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                              labelResolver: (line) => '8ч',
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityChart(bool isDark, List<SleepEntry> entries) {
    // Создаем копию списка для сортировки
    final entriesCopy = List<SleepEntry>.from(entries);

    // Сортируем по дате и времени начала сна (от старых к новым)
    entriesCopy.sort((a, b) {
      // Сравниваем по дате и времени начала сна
      final startCompare = a.sleepStart.compareTo(b.sleepStart);
      if (startCompare != 0) return startCompare;
      // Если время начала одинаковое, сравниваем по времени окончания
      return a.sleepEnd.compareTo(b.sleepEnd);
    });

    // Берем последние 14 записей (самые новые) - они уже отсортированы от старых к новым
    final recentEntries = entriesCopy.length > 14
        ? entriesCopy.sublist(entriesCopy.length - 14)
        : entriesCopy;
    if (recentEntries.isEmpty) {
      return _buildEmptyChartCard(isDark, 'sleep.stats.quality_chart'.tr());
    }

    final baseColor = AppColors.primaryLight;
    final dateLabels = recentEntries
        .map((entry) => DateFormat('dd.MM').format(entry.sleepStart))
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.star_fill,
                  color: baseColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'sleep.stats.quality_chart'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            isDark ? AppColors.darkSurface : Colors.white,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toStringAsFixed(1)} ★',
                            AppTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
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
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceVariant,
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
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
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
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
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
                      final index = e.key;
                      final entry = e.value;
                      final quality = entry.quality.toDouble();
                      // Применяем анимацию - столбцы растут снизу вверх
                      final animatedQuality = quality * _chartAnimation.value;
                      final gradient = LinearGradient(
                        colors: [baseColor.withOpacity(0.3), baseColor],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      );
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: animatedQuality,
                            gradient: gradient,
                            width: 14,
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
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceVariant,
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 8),
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            labelResolver: (line) => '4★',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartCard(bool isDark, String title) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.chart_bar,
              size: 48,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'sleep.stats.no_data'.tr(),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsights(BuildContext context, WidgetRef ref, bool isDark) {
    final insightAsync = ref.watch(sleepInsightProvider);
    final accentColor = AppColors.primary;

    return insightAsync.when(
      data: (insight) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.15),
              accentColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.sparkles,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'sleep.stats.ai_insights'.tr(),
                  style: AppTypography.h4.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              insight.title,
              style: AppTypography.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              insight.description,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.5,
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
    bool isDark,
  ) {
    final recommendationsAsync = ref.watch(sleepRecommendationsProvider);
    final accentColor = AppColors.primaryLight;

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.lightbulb,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'sleep.stats.recommendations'.tr(),
                    style: AppTypography.h4.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
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
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.check_mark_circled,
                          color: accentColor,
                          size: 16,
                        ),
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
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rec.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                height: 1.4,
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
    bool isDark,
    List<SleepEntry> sleepEntries,
  ) {
    final moodEntriesAsync = ref.watch(recentMoodEntriesProvider);

    return moodEntriesAsync.when(
      data: (moodEntries) {
        if (moodEntries.isEmpty || sleepEntries.isEmpty) {
          return const SizedBox.shrink();
        }

        final correlation = _calculateCorrelation(sleepEntries, moodEntries);
        final accentColor = AppColors.primary;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_up_right,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'sleep.stats.mood_correlation'.tr(),
                    style: AppTypography.h4.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
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
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.5,
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

      final normalizedSleep = sleep.quality / 5.0;
      final normalizedMood = mood.moodValue / 5.0;

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
