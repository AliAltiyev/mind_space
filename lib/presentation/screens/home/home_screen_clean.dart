import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../app/providers/ai_features_provider.dart';

/// Главный экран приложения - строгий и понятный дизайн
class HomeScreenClean extends ConsumerWidget {
  const HomeScreenClean({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastMoodAsync = ref.watch(lastMoodProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        title: Text(
          'home.title'.tr(),
          style: AppTypography.h3.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            onPressed: () => context.go('/settings/notifications'),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            _buildWelcomeSection(),

            const SizedBox(height: 24),

            // Текущее настроение
            _buildCurrentMoodSection(context, lastMoodAsync),

            const SizedBox(height: 24),

            // Быстрая статистика
            _buildQuickStats(),

            const SizedBox(height: 24),

            // Быстрые действия
            _buildQuickActions(context),

            const SizedBox(height: 24),

            // Последние записи
            _buildRecentEntries(context, ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-entry'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Секция приветствия
  Widget _buildWelcomeSection() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark ? null : AppColors.cardShadow,
            border: isDark
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home.welcome'.tr(),
                style: AppTypography.h2.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'home.how_are_you_today'.tr(),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Секция текущего настроения
  Widget _buildCurrentMoodSection(
    BuildContext context,
    AsyncValue lastMoodAsync,
  ) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark ? null : AppColors.cardShadow,
            border: isDark
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home.current_mood'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              lastMoodAsync.when(
                data: (lastMood) {
                  if (lastMood != null) {
                    return _buildMoodDisplay(lastMood);
                  } else {
                    return _buildNoMoodState(context);
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildErrorState(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Отображение настроения
  Widget _buildMoodDisplay(dynamic lastMood) {
    final moodValue = lastMood.moodValue;
    final date = lastMood.createdAt;

    return Row(
      children: [
        // Иконка настроения
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: getMoodGradient(moodValue),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(_getMoodIcon(moodValue), color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        // Информация о настроении
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMoodLabel(moodValue),
                        style: AppTypography.h4.copyWith(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM, HH:mm').format(date),
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        // Кнопка обновить
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh),
          color: AppColors.primary,
        ),
      ],
    );
  }

  /// Состояние без настроения
  Widget _buildNoMoodState(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.mood_outlined,
                size: 40,
                color: isDark ? Colors.white70 : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'entries.no_entries'.tr(),
              style: AppTypography.bodyLarge.copyWith(
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.cardShadow,
              ),
              child: ElevatedButton(
                onPressed: () => context.push('/add-entry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'mood.add_mood'.tr(),
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Состояние ошибки
  Widget _buildErrorState(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 40, color: AppColors.error),
        const SizedBox(height: 8),
        Text(
          'common.error'.tr(),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () {}, child: Text('common.try_again'.tr())),
      ],
    );
  }

  /// Быстрая статистика
  Widget _buildQuickStats() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark ? null : AppColors.cardShadow,
            border: isDark
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'stats.title'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'stats.total_entries'.tr(),
                      value: '12',
                      icon: Icons.list_alt,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'home.today'.tr(),
                      value: '1',
                      icon: Icons.today,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark ? null : AppColors.cardShadow,
            border: isDark
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home.quick_actions'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _ActionCard(
                    title: 'stats.title'.tr(),
                    icon: Icons.analytics,
                    color: AppColors.primary,
                    onTap: () => context.go('/stats'),
                  ),
                  _ActionCard(
                    title: 'entries.title'.tr(),
                    icon: Icons.list,
                    color: AppColors.secondary,
                    onTap: () => context.go('/home/entries'),
                  ),
                  _ActionCard(
                    title: 'AI Инсайты',
                    icon: Icons.psychology,
                    color: AppColors.info,
                    onTap: () => context.go('/stats/insights'),
                  ),
                  _ActionCard(
                    title: 'ai.meditation.title'.tr(),
                    icon: Icons.self_improvement,
                    color: AppColors.success,
                    onTap: () => context.go('/stats/meditation'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Последние записи
  Widget _buildRecentEntries(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark ? null : AppColors.cardShadow,
            border: isDark
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final isDark = theme.brightness == Brightness.dark;
                      return Text(
                        'home.recent_entries'.tr(),
                        style: AppTypography.h4.copyWith(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => context.go('/home/entries'),
                    child: Text('entries.title'.tr()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Здесь будут последние записи
              _buildEmptyState(),
            ],
          ),
        );
      },
    );
  }

  /// Пустое состояние для последних записей
  Widget _buildEmptyState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mood_outlined,
                size: 48,
                color: isDark ? Colors.white70 : AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                'entries.no_entries'.tr(),
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'home.add_first_entry'.tr(),
                style: AppTypography.caption.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Получить иконку настроения
  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 5:
        return Icons.sentiment_very_satisfied;
      case 4:
        return Icons.sentiment_satisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 1:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  /// Получить название настроения
  String _getMoodLabel(int mood) {
    switch (mood) {
      case 5:
        return 'mood.moods.very_happy'.tr();
      case 4:
        return 'mood.moods.happy'.tr();
      case 3:
        return 'mood.moods.neutral'.tr();
      case 2:
        return 'mood.moods.sad'.tr();
      case 1:
        return 'mood.moods.very_sad'.tr();
      default:
        return 'Неизвестно';
    }
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
          Text(value, style: AppTypography.h3.copyWith(color: color)),
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              return Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Карточка действия
class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 0 : 2,
      color: isDark ? const Color(0xFF1E293B) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? BorderSide(color: Colors.white.withOpacity(0.1))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
