import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../app/providers/ai_features_provider.dart';

/// Экран статистики - простой и понятный дизайн
class StatsScreenClean extends ConsumerWidget {
  const StatsScreenClean({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEntriesAsync = ref.watch(allMoodEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('stats.title'.tr()),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: allEntriesAsync.when(
        data: (entries) => _buildStatsContent(context, entries),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  /// Основной контент статистики
  Widget _buildStatsContent(BuildContext context, List<dynamic> entries) {
    if (entries.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общая статистика
          _buildOverallStats(entries),
          
          const SizedBox(height: 24),
          
          // Статистика по настроениям
          _buildMoodStats(entries),
          
          const SizedBox(height: 24),
          
          // График трендов
          _buildTrendsChart(entries),
          
          const SizedBox(height: 24),
          
          // Последние записи
          _buildRecentEntries(entries, context),
        ],
      ),
    );
  }

  /// Общая статистика
  Widget _buildOverallStats(List<dynamic> entries) {
    final totalEntries = entries.length;
    final avgMood = entries.isEmpty 
        ? 0.0 
        : entries.map((e) => e.moodValue).reduce((a, b) => a + b) / entries.length;
    final streak = _calculateStreak(entries);
    final thisWeek = entries.where((e) => 
        e.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;

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
          Text(
            'stats.overall_stats'.tr(),
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'stats.total_entries'.tr(),
                  value: totalEntries.toString(),
                  icon: Icons.list_alt,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'stats.average_mood'.tr(),
                  value: avgMood.toStringAsFixed(1),
                  icon: Icons.trending_up,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'stats.streak'.tr(),
                  value: streak.toString(),
                  icon: Icons.local_fire_department,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'stats.this_week'.tr(),
                  value: thisWeek.toString(),
                  icon: Icons.calendar_today,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Статистика по настроениям
  Widget _buildMoodStats(List<dynamic> entries) {
    final moodCounts = List.generate(5, (index) => 
        entries.where((e) => e.moodValue == index + 1).length);

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
          Text(
            'stats.mood_distribution'.tr(),
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final moodValue = index + 1;
            final count = moodCounts[index];
            final percentage = entries.isEmpty ? 0.0 : (count / entries.length) * 100;
            
            return _MoodStatBar(
              moodValue: moodValue,
              count: count,
              percentage: percentage,
              total: entries.length,
            );
          }),
        ],
      ),
    );
  }

  /// График трендов
  Widget _buildTrendsChart(List<dynamic> entries) {
    final weeklyData = _getWeeklyData(entries);

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
          Text(
            'stats.weekly_trends'.tr(),
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildSimpleChart(weeklyData),
          ),
        ],
      ),
    );
  }

  /// Последние записи
  Widget _buildRecentEntries(List<dynamic> entries, BuildContext context) {
    final recentEntries = entries.take(5).toList();

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home.recent_entries'.tr(),
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () => context.go('/home/entries'),
                child: Text('entries.title'.tr()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentEntries.map((entry) => _RecentEntryItem(entry: entry)),
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
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'stats.no_data'.tr(),
            style: AppTypography.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'stats.add_entries_for_stats'.tr(),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
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

  /// Состояние ошибки
  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'common.error'.tr(),
            style: AppTypography.h3.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Простой график
  Widget _buildSimpleChart(List<double> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'stats.no_data_display'.tr(),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _SimpleChartPainter(data),
    );
  }

  /// Расчет серии дней
  int _calculateStreak(List<dynamic> entries) {
    if (entries.isEmpty) return 0;

    final sortedEntries = List.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < sortedEntries.length; i++) {
      final entryDate = sortedEntries[i].createdAt;
      final daysDiff = today.difference(entryDate).inDays;
      
      if (daysDiff == streak) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Получить данные за неделю
  List<double> _getWeeklyData(List<dynamic> entries) {
    final now = DateTime.now();
    final weekData = <double>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = entries.where((e) => 
          e.createdAt.year == date.year &&
          e.createdAt.month == date.month &&
          e.createdAt.day == date.day
      ).toList();
      
      if (dayEntries.isEmpty) {
        weekData.add(0.0);
      } else {
        final avg = dayEntries.map((e) => e.moodValue).reduce((a, b) => a + b) / dayEntries.length;
        weekData.add(avg);
      }
    }
    
    return weekData;
  }
}

/// Карточка статистики
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h3.copyWith(color: color),
          ),
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

/// Бар статистики настроения
class _MoodStatBar extends StatelessWidget {
  final int moodValue;
  final int count;
  final double percentage;
  final int total;

  const _MoodStatBar({
    required this.moodValue,
    required this.count,
    required this.percentage,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Иконка настроения
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: getMoodGradient(moodValue),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getMoodIcon(moodValue),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // Название
          SizedBox(
            width: 80,
            child: Text(
              _getMoodLabel(moodValue),
              style: AppTypography.bodyMedium,
            ),
          ),
          // Прогресс-бар
          Expanded(
            child: LinearProgressIndicator(
              value: total == 0 ? 0.0 : count / total,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(getMoodColor(moodValue)),
            ),
          ),
          const SizedBox(width: 12),
          // Процент
          SizedBox(
            width: 40,
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
      case 5: return Icons.sentiment_very_satisfied;
      case 4: return Icons.sentiment_satisfied;
      case 3: return Icons.sentiment_neutral;
      case 2: return Icons.sentiment_dissatisfied;
      case 1: return Icons.sentiment_very_dissatisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 5: return 'mood.moods.very_happy'.tr();
      case 4: return 'mood.moods.happy'.tr();
      case 3: return 'mood.moods.neutral'.tr();
      case 2: return 'mood.moods.sad'.tr();
      case 1: return 'mood.moods.very_sad'.tr();
      default: return 'stats.unknown'.tr();
    }
  }
}

/// Элемент последней записи
class _RecentEntryItem extends StatelessWidget {
  final dynamic entry;

  const _RecentEntryItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: getMoodGradient(entry.moodValue),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getMoodLabel(entry.moodValue),
              style: AppTypography.bodyMedium,
            ),
          ),
          Text(
            DateFormat('dd.MM').format(entry.createdAt),
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 5: return 'mood.moods.very_happy'.tr();
      case 4: return 'mood.moods.happy'.tr();
      case 3: return 'mood.moods.neutral'.tr();
      case 2: return 'mood.moods.sad'.tr();
      case 1: return 'mood.moods.very_sad'.tr();
      default: return 'stats.unknown'.tr();
    }
  }
}

/// Простой художник графика
class _SimpleChartPainter extends CustomPainter {
  final List<double> data;

  _SimpleChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);
    final maxValue = 5.0; // Максимальное значение настроения

    // Создаем путь для линии
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Завершаем заливку
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Рисуем заливку и линию
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Рисуем точки
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
