import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/achievements_bloc.dart';
import '../widgets/achievement_card_widget.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) =>
            context.read<AchievementsBloc>()..add(LoadAchievements()),
        child: const _AchievementsPageContent(),
      ),
    );
  }
}

class _AchievementsPageContent extends StatelessWidget {
  const _AchievementsPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementsBloc, AchievementsState>(
      builder: (context, state) {
        if (state is AchievementsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AchievementsLoaded) {
          final achievements = state.achievements;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AchievementsBloc>().add(RefreshAchievements());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Прогресс достижений',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${achievements.totalUnlocked} из ${achievements.totalAchievements}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: achievements.completionPercentage,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(achievements.completionPercentage * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Unlocked Achievements
                  if (achievements.unlockedAchievements.isNotEmpty) ...[
                    Text(
                      'Полученные достижения',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...achievements.unlockedAchievements.map(
                      (achievement) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AchievementCardWidget(achievement: achievement),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Locked Achievements
                  if (achievements.lockedAchievements.isNotEmpty) ...[
                    Text(
                      'Доступные достижения',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...achievements.lockedAchievements.map(
                      (achievement) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AchievementCardWidget(achievement: achievement),
                      ),
                    ),
                  ],

                  // Empty State
                  if (achievements.achievements.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 48,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Пока нет достижений',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Продолжайте вести дневник настроения, чтобы получить первые достижения!',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        } else if (state is AchievementsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки достижений',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AchievementsBloc>().add(LoadAchievements());
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Неизвестное состояние'));
      },
    );
  }
}
