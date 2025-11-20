import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mind_space/features/ai/presentation/pages/gratitude_journal_page.dart';
import 'package:mind_space/features/ai/presentation/pages/meditation_page.dart';
import 'package:mind_space/features/ai/presentation/pages/meditation_timer_page_tts.dart';
import 'package:mind_space/features/ai/domain/entities/meditation_entity.dart';
import 'package:mind_space/features/ai/presentation/pages/patterns_page.dart';

import '../../features/profile/presentation/pages/achievements_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
// Новые страницы профиля
import '../../features/profile/presentation/pages/statistics_page.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/entry/add_entry_screen_clean.dart';
import '../../presentation/screens/entry/entry_detail_screen.dart';
// Основные экраны
import '../../presentation/screens/home/home_screen_clean.dart';
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
                builder: (context, state) => const MeditationPage(),
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

/// Главная оболочка приложения с навигацией
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTabTapped(context, index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'navigation.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            activeIcon: const Icon(Icons.analytics),
            label: 'navigation.stats'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bedtime_outlined),
            activeIcon: const Icon(Icons.bedtime),
            label: 'navigation.sleep'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.psychology_outlined),
            activeIcon: const Icon(Icons.psychology),
            label: 'ai.chat.title'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: 'navigation.profile'.tr(),
          ),
        ],
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
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/stats');
        break;
      case 2:
        context.go('/sleep');
        break;
      case 3:
        context.go('/ai-chat');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
