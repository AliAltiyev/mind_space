import 'package:flutter/material.dart';
import 'package:mind_space/presentation/widgets/core/glass_surface.dart';

import '../../domain/entities/user_stats_entity.dart';

class StatsGridWidget extends StatelessWidget {
  final UserStatsEntity stats;
  final VoidCallback? onTap;

  const StatsGridWidget({super.key, required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Статистика',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  IconButton(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  context,
                  'Всего записей',
                  '${stats.totalEntries}',
                  Icons.notes,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Текущая серия',
                  '${stats.currentStreak}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Лучшая серия',
                  '${stats.longestStreak}',
                  Icons.emoji_events,
                  Colors.purple,
                ),
                _buildStatCard(
                  context,
                  'Среднее настроение',
                  stats.averageMood.toStringAsFixed(1),
                  Icons.sentiment_satisfied,
                  Colors.green,
                ),
              ],
            ),

            if (stats.moodDistribution.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Распределение настроений',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildMoodDistribution(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.85),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(BuildContext context) {
    final total = stats.moodDistribution.values.fold(
      0,
      (sum, count) => sum + count,
    );

    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: stats.moodDistribution.entries.map((entry) {
        final percentage = (entry.value / total * 100).round();
        final moodColor = _getMoodColor(entry.key);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: moodColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getMoodLabel(entry.key),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ),
              Text(
                '${entry.value} ($percentage%)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getMoodColor(String moodCategory) {
    switch (moodCategory) {
      case 'very_low':
        return Colors.red;
      case 'low':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'high':
        return Colors.lightGreen;
      case 'very_high':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getMoodLabel(String moodCategory) {
    switch (moodCategory) {
      case 'very_low':
        return 'Очень низкое';
      case 'low':
        return 'Низкое';
      case 'medium':
        return 'Среднее';
      case 'high':
        return 'Хорошее';
      case 'very_high':
        return 'Отличное';
      default:
        return moodCategory;
    }
  }
}
