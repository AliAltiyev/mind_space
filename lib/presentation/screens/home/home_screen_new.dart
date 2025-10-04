import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/ai_features_provider.dart';
import '../../widgets/ai/ai_features_grid.dart';
import '../../widgets/core/amazing_background.dart' as amazing;
import '../../widgets/core/perfected_mood_blob.dart';

/// Главный экран приложения
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return amazing.AmazingBackground(
      type: amazing.BackgroundType.cosmic,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Mind Space',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 10)],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFB9E3A), Color(0xFFE6521F)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFB9E3A).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6521F), Color(0xFFEA2F14)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE6521F).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.go('/settings'),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                // Центральная область с MoodBlob
                Expanded(
                  flex: 3,
                  child: Center(
                    child: PerfectedMoodBlobWithFAB(
                      moodRating: 3, // TODO: Получать из реальных данных
                      onTap: () => context.push('/add-entry'),
                    ),
                  ),
                ),

                // Нижняя область с быстрыми действиями и AI функциями
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Быстрые действия
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickActionCard(
                                    icon: Icons.analytics,
                                    title: 'View Stats',
                                    subtitle: 'See your progress',
                                    onTap: () => context.go('/stats'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _QuickActionCard(
                                    icon: Icons.list,
                                    title: 'All Entries',
                                    subtitle: 'Browse history',
                                    onTap: () => context.go('/home/entries'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _QuickActionCard(
                                    icon: Icons.insights,
                                    title: 'AI Insights',
                                    subtitle: 'Get recommendations',
                                    onTap: () => context.go('/stats/insights'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _QuickActionCard(
                                    icon: Icons.self_improvement,
                                    title: 'Meditation',
                                    subtitle: 'Find peace',
                                    onTap: () =>
                                        context.go('/stats/meditation'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // AI Features Section
                            _buildAIFeaturesSection(context, ref),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Секция AI функций для главного экрана
  Widget _buildAIFeaturesSection(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final moodEntriesAsync = ref.watch(moodEntriesProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'AI Features',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Обновляем все AI функции
                    ref.invalidate(recentMoodEntriesProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Обновить AI функции',
                ),
              ],
            ),
            const SizedBox(height: 16),

            moodEntriesAsync.when(
              data: (moodEntries) {
                if (moodEntries.isEmpty) {
                  return Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFFB9E3A).withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.psychology, size: 48, color: Color(0xFFFB9E3A)),
                          SizedBox(height: 16),
                          Text(
                            'Добавьте записи настроения для AI функций',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return AIFeaturesGrid(
                  moodEntries: moodEntries,
                  onRefresh: () {
                    ref.invalidate(recentMoodEntriesProvider);
                  },
                );
              },
              loading: () => Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Загружаем AI функции...',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              error: (error, stack) => Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Color(0xFFEA2F14).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFEA2F14).withOpacity(0.3)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFEA2F14),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки AI функций',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(recentMoodEntriesProvider);
                        },
                        child: const Text('Попробовать снова'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
