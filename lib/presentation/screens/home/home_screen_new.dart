import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../app/providers/ai_features_provider.dart';
import '../../widgets/ai/ai_features_grid.dart';
import '../../widgets/core/amazing_background.dart' as amazing;
import '../../widgets/core/amazing_glass_surface.dart' as amazing;
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
        body: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFB9E3A).withOpacity(0.1),
                        const Color(0xFFE6521F).withOpacity(0.1),
                        const Color(0xFFEA2F14).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'home.title'.tr(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(color: Color(0xFFFB9E3A), blurRadius: 15),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Good morning! How are you feeling?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _ActionButton(
                              icon: Icons.notifications_outlined,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFB9E3A), Color(0xFFE6521F)],
                              ),
                              onPressed: () => context.go('/settings/notifications'),
                            ),
                            const SizedBox(width: 12),
                            _ActionButton(
                              icon: Icons.settings_outlined,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE6521F), Color(0xFFEA2F14)],
                              ),
                              onPressed: () => context.go('/settings'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood Blob Section
                    _buildMoodBlobSection(context),
                    
                    const SizedBox(height: 30),
                    
                    // Quick Stats
                    _buildQuickStats(),
                    
                    const SizedBox(height: 30),
                    
                    // Quick Actions Grid
                    _buildQuickActionsGrid(context),
                    
                    const SizedBox(height: 30),
                    
                    // AI Features Section
                    _buildAIFeaturesSection(context, ref),
                    
                    const SizedBox(height: 100), // Bottom padding for navigation
                  ],
                ),
              ),
            ),
          ],
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
                Text(
                  'home.ai_features'.tr(),
                  style: const TextStyle(
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
                    child:  Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.psychology, size: 48, color: Color(0xFFFB9E3A)),
                          SizedBox(height: 16),
                          Text(
                            'home.add_mood_entries'.tr(),
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
                child:  Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'home.loading_ai_features'.tr(),
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
                        'home.error_loading_ai'.tr(),
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(recentMoodEntriesProvider);
                        },
                        child: Text('common.try_again'.tr()),
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
