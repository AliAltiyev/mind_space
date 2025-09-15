import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_animations/simple_animations.dart';

import '../constants/app_design.dart';
import '../features/mood_tracking/domain/entities/mood_entry.dart';
import '../features/mood_tracking/presentation/bloc/mood_tracking_bloc.dart';
import '../features/mood_tracking/presentation/bloc/mood_tracking_event.dart';
import '../features/mood_tracking/presentation/bloc/mood_tracking_state.dart';
import '../widgets/glass_card.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _listController;

  late Animation<double> _chartAnimation;

  DateTime _selectedStartDate = DateTime.now().subtract(
    const Duration(days: 7),
  );
  DateTime _selectedEndDate = DateTime.now();
  MoodLevel? _selectedMoodFilter;

  @override
  void initState() {
    super.initState();

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOut,
    );

    _chartController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppDesign.paddingLarge),
      child: Row(
        children: [
          GlassButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: AppDesign.textPrimary),
          ),
          const SizedBox(width: AppDesign.paddingMedium),
          Text('История настроений', style: AppTextStyles.headline2),
          const Spacer(),
          GlassButton(
            onPressed: _showFilterDialog,
            child: Icon(Icons.filter_list, color: AppDesign.textPrimary),
          ),
        ],
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
          Text('Ошибка загрузки', style: AppTextStyles.headline3),
          const SizedBox(height: AppDesign.paddingMedium),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Text(
        'Загрузка...',
        style: AppTextStyles.bodyLarge.copyWith(color: AppDesign.textSecondary),
      ),
    );
  }

  Widget _buildLoadedState(MoodTrackingLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesign.paddingLarge),
      child: Column(
        children: [
          _buildChartSection(state.entries),
          const SizedBox(height: AppDesign.paddingLarge),
          _buildStatisticsSection(state.statistics),
          const SizedBox(height: AppDesign.paddingLarge),
          _buildEntriesList(state.entries),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<MoodEntry> entries) {
    return FadeIn(
      delay: const Duration(milliseconds: 200),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('График настроений', style: AppTextStyles.headline3),
            const SizedBox(height: AppDesign.paddingLarge),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() % 2 == 0) {
                                final date = DateTime.now().subtract(
                                  Duration(days: 6 - value.toInt()),
                                );
                                return Text(
                                  '${date.day}/${date.month}',
                                  style: AppTextStyles.caption,
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _prepareChartData(entries),
                          isCurved: true,
                          color: AppDesign.accentColor,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: _getMoodColorFromValue(spot.y),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppDesign.accentColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _prepareChartData(List<MoodEntry> entries) {
    final Map<int, double> dailyAverages = {};

    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dayEntries = entries.where((entry) {
        return entry.createdAt.year == date.year &&
            entry.createdAt.month == date.month &&
            entry.createdAt.day == date.day;
      }).toList();

      if (dayEntries.isNotEmpty) {
        final average =
            dayEntries.map((e) => e.mood.value).reduce((a, b) => a + b) /
            dayEntries.length;
        dailyAverages[i] = average;
      } else {
        dailyAverages[i] = 3.0; // Нейтральное значение
      }
    }

    return dailyAverages.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  Widget _buildStatisticsSection(Map<MoodLevel, int>? statistics) {
    if (statistics == null || statistics.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = statistics.values.fold(0, (sum, count) => sum + count);

    return FadeIn(
      delay: const Duration(milliseconds: 400),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статистика', style: AppTextStyles.headline3),
            const SizedBox(height: AppDesign.paddingMedium),
            ...statistics.entries.map((entry) {
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

  Widget _buildEntriesList(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return FadeIn(
        delay: const Duration(milliseconds: 600),
        child: GlassCard(
          child: Column(
            children: [
              Icon(
                Icons.sentiment_neutral,
                size: 64,
                color: AppDesign.textTertiary,
              ),
              const SizedBox(height: AppDesign.paddingLarge),
              Text('Пока нет записей', style: AppTextStyles.headline3),
              const SizedBox(height: AppDesign.paddingMedium),
              Text(
                'Начните записывать свое настроение',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppDesign.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FadeIn(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Записи', style: AppTextStyles.headline3),
          const SizedBox(height: AppDesign.paddingMedium),
          ...entries.asMap().entries.map((entry) {
            return _buildMoodEntryCard(entry.value, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildMoodEntryCard(MoodEntry entry, int index) {
    return FadeIn(
      delay: Duration(milliseconds: 800 + (index * 100)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDesign.paddingMedium),
        child: GlassCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesign.paddingMedium),
                decoration: BoxDecoration(
                  color: _getMoodColor(entry.mood).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
                ),
                child: Text(
                  entry.mood.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: AppDesign.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.mood.label,
                      style: AppTextStyles.bodyLarge.copyWith(
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
                    const SizedBox(height: AppDesign.paddingSmall),
                    Text(
                      _formatDate(entry.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Color _getMoodColorFromValue(double value) {
    if (value < 2) return AppDesign.verySadGradient[0];
    if (value < 3) return AppDesign.sadGradient[0];
    if (value < 4) return AppDesign.neutralGradient[0];
    if (value < 5) return AppDesign.happyGradient[0];
    return AppDesign.veryHappyGradient[0];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Вчера в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDesign.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        ),
        title: Text('Фильтры', style: AppTextStyles.headline3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('По дате', style: AppTextStyles.bodyLarge),
              subtitle: Text(
                '${_selectedStartDate.day}.${_selectedStartDate.month} - ${_selectedEndDate.day}.${_selectedEndDate.month}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppDesign.textSecondary,
                ),
              ),
              onTap: _selectDateRange,
            ),
            const Divider(color: AppDesign.textTertiary),
            ListTile(
              title: Text('По настроению', style: AppTextStyles.bodyLarge),
              subtitle: Text(
                _selectedMoodFilter?.label ?? 'Все',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppDesign.textSecondary,
                ),
              ),
              onTap: _selectMoodFilter,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMoodFilter = null;
                _selectedStartDate = DateTime.now().subtract(
                  const Duration(days: 7),
                );
                _selectedEndDate = DateTime.now();
              });
              context.read<MoodTrackingBloc>().add(ClearFilters());
              Navigator.pop(context);
            },
            child: Text(
              'Сбросить',
              style: AppTextStyles.button.copyWith(
                color: AppDesign.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Закрыть',
              style: AppTextStyles.button.copyWith(
                color: AppDesign.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      context.read<MoodTrackingBloc>().add(
        FilterMoodEntriesByDate(_selectedStartDate, _selectedEndDate),
      );
      Navigator.pop(context);
    }
  }

  void _selectMoodFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDesign.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        ),
        title: Text('Выберите настроение', style: AppTextStyles.headline3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Все', style: AppTextStyles.bodyLarge),
              onTap: () {
                setState(() => _selectedMoodFilter = null);
                context.read<MoodTrackingBloc>().add(ClearFilters());
                Navigator.pop(context);
              },
            ),
            ...MoodLevel.values.map(
              (mood) => ListTile(
                leading: Text(mood.emoji, style: const TextStyle(fontSize: 20)),
                title: Text(mood.label, style: AppTextStyles.bodyLarge),
                onTap: () {
                  setState(() => _selectedMoodFilter = mood);
                  context.read<MoodTrackingBloc>().add(
                    FilterMoodEntriesByMood(mood),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
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
