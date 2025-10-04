import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../blocs/achievements_bloc.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/stats_bloc.dart';
import '../widgets/achievement_card_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/stats_grid_widget.dart';
import 'achievements_page.dart';
import 'edit_profile_page.dart';
import 'statistics_page.dart';
import '../../../../presentation/widgets/core/amazing_background.dart' as amazing;
    
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return amazing.AmazingBackground(
      type: amazing.BackgroundType.cosmic,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'navigation.profile'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 10)],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
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
                onPressed: () => _navigateToEditProfile(context),
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
          ],
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>(
              create: (context) =>
                  context.read<ProfileBloc>()..add(LoadProfile()),
            ),
            BlocProvider<StatsBloc>(
              create: (context) => context.read<StatsBloc>()..add(LoadStats()),
            ),
            BlocProvider<AchievementsBloc>(
              create: (context) =>
                  context.read<AchievementsBloc>()..add(LoadAchievements()),
            ),
          ],
          child: const _ProfilePageContent(),
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (!context.read<ProfileBloc>().isClosed) {
          context.read<ProfileBloc>().add(RefreshProfile());
        }
        if (!context.read<StatsBloc>().isClosed) {
          context.read<StatsBloc>().add(RefreshStats());
        }
        if (!context.read<AchievementsBloc>().isClosed) {
          context.read<AchievementsBloc>().add(RefreshAchievements());
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const _ProfileLoadingWidget();
                } else if (state is ProfileLoaded) {
                  return ProfileHeaderWidget(
                    profile: state.profile,
                    onEditTap: () => _navigateToEditProfile(context),
                  );
                } else if (state is ProfileError) {
                  return _ProfileErrorWidget(
                    message: state.message,
                    onRetry: () {
                      if (!context.read<ProfileBloc>().isClosed) {
                        context.read<ProfileBloc>().add(LoadProfile());
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 20),

            // Stats Section
            BlocBuilder<StatsBloc, StatsState>(
              builder: (context, state) {
                if (state is StatsLoading) {
                  return const _StatsLoadingWidget();
                } else if (state is StatsLoaded) {
                  return StatsGridWidget(
                    stats: state.stats,
                    onTap: () => _navigateToStatistics(context),
                  );
                } else if (state is StatsError) {
                  return _StatsErrorWidget(
                    message: state.message,
                    onRetry: () {
                      if (!context.read<StatsBloc>().isClosed) {
                        context.read<StatsBloc>().add(LoadStats());
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 20),

            // Recent Achievements Section
            BlocBuilder<AchievementsBloc, AchievementsState>(
              builder: (context, state) {
                if (state is AchievementsLoading) {
                  return const _AchievementsLoadingWidget();
                } else if (state is AchievementsLoaded) {
                  final recentAchievements = state
                      .achievements
                      .unlockedAchievements
                      .take(3)
                      .toList();

                  if (recentAchievements.isEmpty) {
                    return _EmptyAchievementsWidget();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'profile.recent_achievements'.tr(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _navigateToAchievements(context),
                            child: Text(
                              'common.all'.tr(),
                              style: const TextStyle(color: Color(0xFFFB9E3A)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...recentAchievements.map(
                        (achievement) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AchievementCardWidget(
                            achievement: achievement,
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is AchievementsError) {
                  return _AchievementsErrorWidget(
                    message: state.message,
                    onRetry: () {
                      if (!context.read<AchievementsBloc>().isClosed) {
                        context.read<AchievementsBloc>().add(
                          LoadAchievements(),
                        );
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  void _navigateToStatistics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsPage()),
    );
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AchievementsPage()),
    );
  }
}

// Loading and Error Widgets
class _ProfileLoadingWidget extends StatelessWidget {
  const _ProfileLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFB9E3A).withOpacity(0.3)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFB9E3A),
        ),
      ),
    );
  }
}

class _ProfileErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEA2F14).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEA2F14).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, color: Color(0xFFEA2F14), size: 48),
          const SizedBox(height: 16),
          Text(
            'profile.error_loading'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFB9E3A),
              foregroundColor: Colors.white,
            ),
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _StatsLoadingWidget extends StatelessWidget {
  const _StatsLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _StatsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StatsErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'Ошибка загрузки статистики',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}

class _AchievementsLoadingWidget extends StatelessWidget {
  const _AchievementsLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _AchievementsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AchievementsErrorWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'Ошибка загрузки достижений',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}

class _EmptyAchievementsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Продолжайте вести дневник настроения, чтобы получить первые достижения!',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white60),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
