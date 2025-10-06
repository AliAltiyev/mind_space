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

  /// Секция с Mood Blob
  Widget _buildMoodBlobSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final lastMoodAsync = ref.watch(lastMoodProvider);
        
        return Center(
          child: amazing.AmazingGlassSurface(
            effectType: amazing.GlassEffectType.neon,
            colorScheme: amazing.ColorScheme.neon,
            child: Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  lastMoodAsync.when(
                    data: (lastMood) => PerfectedMoodBlobWithFAB(
                      moodRating: lastMood?.moodValue ?? 3,
                      onTap: () => context.push('/add-entry'),
                    ),
                    loading: () => PerfectedMoodBlobWithFAB(
                      moodRating: 3,
                      onTap: () => context.push('/add-entry'),
                    ),
                    error: (_, __) => PerfectedMoodBlobWithFAB(
                      moodRating: 3,
                      onTap: () => context.push('/add-entry'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  lastMoodAsync.when(
                    data: (lastMood) => Text(
                      lastMood != null 
                        ? '${'home.last_mood'.tr()}: ${_getMoodLabel(lastMood.moodValue)}'
                        : 'home.tap_to_add_mood'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    loading: () => Text(
                      'common.loading'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    error: (_, __) => Text(
                      'home.tap_to_add_mood'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'entries.very_bad'.tr();
      case 2:
        return 'entries.bad'.tr();
      case 3:
        return 'entries.okay'.tr();
      case 4:
        return 'entries.good'.tr();
      case 5:
        return 'entries.excellent'.tr();
      default:
        return 'common.unknown'.tr();
    }
  }

  /// Быстрая статистика
  Widget _buildQuickStats() {
    return amazing.AmazingGlassSurface(
      effectType: amazing.GlassEffectType.cyber,
      colorScheme: amazing.ColorScheme.cyber,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Overview',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Color(0xFFFCEF91), blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Current Mood',
                    value: 'Good',
                    icon: Icons.mood,
                    color: const Color(0xFFFCEF91),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Streak',
                    value: '12 days',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFFB9E3A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Entries',
                    value: '47',
                    icon: Icons.list_alt,
                    color: const Color(0xFFE6521F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Avg Mood',
                    value: '4.2',
                    icon: Icons.trending_up,
                    color: const Color(0xFFEA2F14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Сетка быстрых действий
  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _ModernQuickActionCard(
              icon: Icons.analytics,
              title: 'Statistics',
              subtitle: 'View your progress',
              gradient: const LinearGradient(
                colors: [Color(0xFFFB9E3A), Color(0xFFE6521F)],
              ),
              onTap: () => context.go('/stats'),
            ),
            _ModernQuickActionCard(
              icon: Icons.list,
              title: 'All Entries',
              subtitle: 'Browse history',
              gradient: const LinearGradient(
                colors: [Color(0xFFE6521F), Color(0xFFEA2F14)],
              ),
              onTap: () => context.go('/home/entries'),
            ),
            _ModernQuickActionCard(
              icon: Icons.insights,
              title: 'AI Insights',
              subtitle: 'Get recommendations',
              gradient: const LinearGradient(
                colors: [Color(0xFFEA2F14), Color(0xFF6D67E4)],
              ),
              onTap: () => context.go('/stats/insights'),
            ),
            _ModernQuickActionCard(
              icon: Icons.self_improvement,
              title: 'Meditation',
              subtitle: 'Find peace',
              gradient: const LinearGradient(
                colors: [Color(0xFF6D67E4), Color(0xFFFCEF91)],
              ),
              onTap: () => context.go('/stats/meditation'),
            ),
          ],
        ),
      ],
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
                  'AI Features',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFB9E3A), Color(0xFFE6521F)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      ref.invalidate(recentMoodEntriesProvider);
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh AI features',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            moodEntriesAsync.when(
              data: (moodEntries) {
                if (moodEntries.isEmpty) {
                  return amazing.AmazingGlassSurface(
                    effectType: amazing.GlassEffectType.cosmic,
                    colorScheme: amazing.ColorScheme.cosmic,
                    child: Container(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.psychology,
                              size: 48,
                              color: Color(0xFFFB9E3A),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Add mood entries for AI features',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/add-entry'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Entry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFB9E3A),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
              loading: () => amazing.AmazingGlassSurface(
                effectType: amazing.GlassEffectType.neon,
                colorScheme: amazing.ColorScheme.neon,
                child: Container(
                  height: 200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFB9E3A)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading AI features...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              error: (error, stack) => amazing.AmazingGlassSurface(
                effectType: amazing.GlassEffectType.rainbow,
                colorScheme: amazing.ColorScheme.rainbow,
                child: Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFFEA2F14),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading AI features',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.invalidate(recentMoodEntriesProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA2F14),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
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

// Action Button для App Bar
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// Stat Card для быстрой статистики
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
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Modern Quick Action Card
class _ModernQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ModernQuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient.colors.first.withOpacity(0.2),
            gradient.colors.last.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.colors.first.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Старый QuickActionCard (для совместимости)
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
