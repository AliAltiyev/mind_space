import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mind_space/features/ai/presentation/pages/gratitude_journal_page.dart';
import 'package:mind_space/features/ai/presentation/pages/meditation_page.dart';
import 'package:mind_space/features/ai/presentation/pages/meditation_timer_page_tts.dart';
import 'package:mind_space/features/ai/domain/entities/meditation_entity.dart';
import 'package:mind_space/features/ai/presentation/pages/patterns_page.dart';
import 'package:mind_space/presentation/screens/home/home_screen_clean.dart';

import '../../features/profile/presentation/pages/achievements_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
// Новые страницы профиля
import '../../features/profile/presentation/pages/statistics_page.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/entry/add_entry_screen_clean.dart';
import '../../presentation/screens/entry/entry_detail_screen.dart';
// Основные экраны
import '../../presentation/screens/entries/entries_screen_clean.dart';
import '../../presentation/screens/home/quick_add_screen.dart';
import '../../presentation/screens/settings/about_screen.dart';
import '../../presentation/screens/settings/appearance_settings_screen.dart';
import '../../presentation/screens/settings/data_export_screen.dart';
import '../../presentation/screens/settings/notification_settings_screen.dart';
import '../../presentation/screens/settings/privacy_settings_screen.dart';
import '../../presentation/screens/settings/settings_screen_modern.dart';
import '../../core/constants/navigation.dart';
import '../../presentation/screens/stats/stats_screen_clean.dart';
import '../../presentation/screens/ai/ai_chat_screen.dart';
import '../../presentation/screens/profile/profile_screen_clean.dart';
import '../../features/ai/presentation/pages/ai_insights_page_clean.dart';
import '../../features/sleep/presentation/pages/sleep_tracking_page.dart';
import '../../features/sleep/presentation/pages/sleep_stats_page.dart';
import '../../shared/presentation/pages/onboarding_page.dart';
import '../../shared/presentation/pages/splash_page.dart';

/// Конфигурация маршрутов приложения
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    navigatorKey: navigatorKey,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Auth Screen (заглушка для будущей аутентификации)
      GoRoute(
        path: '/auth',
        name: 'auth',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        ),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Home Tab
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeScreenClean(),
            ),
            routes: [
              // Quick Add Modal
              GoRoute(
                path: '/quick-add',
                name: 'quick-add',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const QuickAddScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: child,
                        );
                      },
                ),
              ),
              // Entries List
              GoRoute(
                path: '/entries',
                name: 'entries',
                builder: (context, state) => const EntriesScreenClean(),
              ),
            ],
          ),

          // Stats Tab
          GoRoute(
            path: '/stats',
            name: 'stats',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const StatsScreenClean(),
            ),
            routes: [
              // Insights Overview
              GoRoute(
                path: '/insights',
                name: 'insights',
                builder: (context, state) => const AIInsightsPageClean(),
              ),
              // Patterns
              GoRoute(
                path: '/patterns',
                name: 'patterns',
                builder: (context, state) => const PatternsPage(),
              ),
              // Gratitude Journal
              GoRoute(
                path: '/gratitude',
                name: 'gratitude',
                builder: (context, state) => const GratitudeJournalPage(),
              ),
              // Meditation
              GoRoute(
                path: '/meditation',
                name: 'meditation',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const MeditationPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
                routes: [
                  // Meditation Timer
                  GoRoute(
                    path: '/timer',
                    name: 'meditation-timer',
                    pageBuilder: (context, state) {
                      final meditation = state.extra as MeditationEntity;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: MeditationTimerPageTTS(meditation: meditation),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // AI Chat Tab
          GoRoute(
            path: '/ai-chat',
            name: 'ai-chat',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AiChatScreen(),
            ),
          ),

          // Sleep Tab
          GoRoute(
            path: '/sleep',
            name: 'sleep',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SleepTrackingPage(),
            ),
            routes: [
              // Sleep Stats
              GoRoute(
                path: '/stats',
                name: 'sleep-stats',
                builder: (context, state) => const SleepStatsPage(),
              ),
            ],
          ),

          // Profile Tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreenClean(),
            ),
            routes: [
              // Edit Profile
              GoRoute(
                path: '/edit',
                name: 'edit-profile',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const EditProfilePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                          ),
                          child: child,
                        );
                      },
                ),
              ),
              // Statistics
              GoRoute(
                path: '/statistics',
                name: 'profile-statistics',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const StatisticsPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                          ),
                          child: child,
                        );
                      },
                ),
              ),
              // Achievements
              GoRoute(
                path: '/achievements',
                name: 'achievements',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const AchievementsPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                          ),
                          child: child,
                        );
                      },
                ),
              ),
            ],
          ),

          // AI Features Tab
          GoRoute(
            path: '/ai-insights',
            name: 'ai-insights',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AIInsightsPageClean(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOut)),
                      ),
                      child: child,
                    );
                  },
            ),
          ),

          GoRoute(
            path: '/ai-patterns',
            name: 'ai-patterns',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PatternsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOut)),
                      ),
                      child: child,
                    );
                  },
            ),
          ),

          GoRoute(
            path: '/ai-gratitude',
            name: 'ai-gratitude',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const GratitudeJournalPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOut)),
                      ),
                      child: child,
                    );
                  },
            ),
          ),

          GoRoute(
            path: '/ai-meditation',
            name: 'ai-meditation',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MeditationPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOut)),
                      ),
                      child: child,
                    );
                  },
            ),
          ),
        ],
      ),

      // Add Entry Modal (глобальный модальный экран)
      GoRoute(
        path: '/add-entry',
        name: 'add-entry',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddEntryScreenClean(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: child,
            );
          },
        ),
      ),

      // Entry Detail Screen
      GoRoute(
        path: '/entry/:id',
        name: 'entry-detail',
        builder: (context, state) {
          final entryId = state.pathParameters['id']!;
          return EntryDetailScreen(entryId: entryId);
        },
      ),

      // Settings Flow
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreenModern(),
        routes: [
          // Notification Settings
          GoRoute(
            path: '/notifications',
            name: 'notification-settings',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          // Appearance Settings
          GoRoute(
            path: '/appearance',
            name: 'appearance-settings',
            builder: (context, state) => const AppearanceSettingsScreen(),
          ),
          // Data Export
          GoRoute(
            path: '/export',
            name: 'data-export',
            builder: (context, state) => const DataExportScreen(),
          ),
          // Privacy Settings
          GoRoute(
            path: '/privacy',
            name: 'privacy-settings',
            builder: (context, state) => const PrivacySettingsScreen(),
          ),
          // About
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],

    // Обработка ошибок маршрутизации
    errorBuilder: (context, state) => ErrorPage(error: state.error),

    // Перенаправления и защищенные маршруты
    redirect: (context, state) {
      // Перенаправление корневого маршрута на главный экран
      if (state.uri.path == '/') {
        return '/home';
      }
      // TODO: Добавить логику перенаправления на основе состояния приложения
      return null;
    },
  );
});

/// Главная оболочка приложения с навигацией в стиле iOS
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItemData(
      path: '/home',
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      labelKey: 'navigation.home',
    ),
    _TabItemData(
      path: '/stats',
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_circle_fill,
      labelKey: 'navigation.stats',
    ),
    _TabItemData(
      path: '/sleep',
      icon: CupertinoIcons.bed_double,
      activeIcon: CupertinoIcons.bed_double_fill,
      labelKey: 'navigation.sleep',
    ),
    _TabItemData(
      path: '/ai-chat',
      icon: CupertinoIcons.sparkles,
      activeIcon: CupertinoIcons.sparkles,
      labelKey: 'ai.chat.title',
    ),
    _TabItemData(
      path: '/profile',
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      labelKey: 'navigation.profile',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(context);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: child),
          _buildCupertinoTabBar(context, currentIndex),
        ],
      ),
    );
  }

  Widget _buildCupertinoTabBar(BuildContext context, int currentIndex) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  return _buildTabItem(
                    context,
                    index: index,
                    currentIndex: currentIndex,
                    tab: tab,
                    isDark: isDark,
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required _TabItemData tab,
    required bool isDark,
  }) {
    final isActive = index == currentIndex;
    final label = tab.labelKey.tr();
    final activeColor = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.5)
        : Colors.black54;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(context, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.12))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? tab.activeIcon : tab.icon,
                size: 24,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? activeColor : inactiveColor,
                ),
                child: Text(label),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1 : 0,
                child: Container(
                  height: 3,
                  width: 18,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/stats')) return 1;
    if (location.startsWith('/sleep')) return 2;
    if (location.startsWith('/ai-chat')) return 3;
    if (location.startsWith('/profile')) return 4;

    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    final tab = _tabs[index];
    context.go(tab.path);
  }
}

class _TabItemData {
  const _TabItemData({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });

  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
}

/// Страница ошибки
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.error});

  final GoException? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('error.title'.tr())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '${'error.occurred'.tr()}: ${error?.toString() ?? 'error.unknown_error'.tr()}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: Text('error.go_home'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
