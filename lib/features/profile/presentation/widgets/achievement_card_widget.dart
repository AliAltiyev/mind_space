import 'package:flutter/material.dart';
import 'package:mind_space/presentation/widgets/core/glass_surface.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/user_achievements_entity.dart';

class AchievementCardWidget extends StatelessWidget {
  final AchievementEntity achievement;
  final VoidCallback? onTap;

  const AchievementCardWidget({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Achievement Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: achievement.unlocked
                      ? _getRarityColor(achievement.rarity).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: achievement.unlocked
                        ? _getRarityColor(achievement.rarity)
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getAchievementIcon(achievement.icon),
                  color: achievement.unlocked
                      ? _getRarityColor(achievement.rarity)
                      : Colors.grey,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Achievement Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: achievement.unlocked
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
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
                      achievement.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.75),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (!achievement.unlocked) ...[
                      const SizedBox(height: 8),
                      // Progress Bar
                      LinearProgressIndicator(
                        value: achievement.progressPercentage,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRarityColor(achievement.rarity),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.progress}/${achievement.target}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.75),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _getRarityColor(achievement.rarity),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'achievements.unlocked'.tr(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _getRarityColor(achievement.rarity),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Rarity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRarityColor(achievement.rarity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getRarityColor(achievement.rarity),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getRarityLabel(achievement.rarity),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getRarityColor(achievement.rarity),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'first_entry':
        return Icons.emoji_emotions;
      case 'streak_7':
        return Icons.local_fire_department;
      case 'streak_30':
        return Icons.whatshot;
      case 'streak_100':
        return Icons.auto_awesome;
      case 'mood_master':
        return Icons.psychology;
      case 'data_collector':
        return Icons.analytics;
      case 'early_bird':
        return Icons.wb_sunny;
      case 'night_owl':
        return Icons.nights_stay;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRarityLabel(String rarity) {
    switch (rarity) {
      case 'common':
        return 'achievements.rarity.common'.tr();
      case 'uncommon':
        return 'achievements.rarity.uncommon'.tr();
      case 'rare':
        return 'achievements.rarity.rare'.tr();
      case 'epic':
        return 'achievements.rarity.epic'.tr();
      case 'legendary':
        return 'achievements.rarity.legendary'.tr();
      default:
        return 'achievements.rarity.common'.tr();
    }
  }
}
