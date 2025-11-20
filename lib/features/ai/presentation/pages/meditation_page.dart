import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../../app/providers/ai_features_provider.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/presentation/theme/platform_utils.dart';
import '../blocs/meditation_bloc.dart';
import '../../domain/entities/meditation_entity.dart';

/// Страница медитации и релаксации
class MeditationPage extends ConsumerStatefulWidget {
  const MeditationPage({super.key});

  @override
  ConsumerState<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends ConsumerState<MeditationPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем предложения медитации при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMeditation();
    });
  }

  void _loadMeditation() {
    final bloc = context.read<MeditationBloc>();
    if (!bloc.isClosed) {
      // Получаем реальные данные настроений из provider
      final moodEntriesAsync = ref.read(recentMoodEntriesProvider);
      moodEntriesAsync.when(
        data: (moodEntries) {
          if (!bloc.isClosed) {
            bloc.add(LoadMeditationSession(moodEntries));
          }
        },
        loading: () {
          // Данные загружаются, используем пустой список (fallback медитация будет создана)
          if (!bloc.isClosed) {
            bloc.add(LoadMeditationSession([]));
          }
        },
        error: (_, __) {
          // Ошибка загрузки, используем пустой список
          if (!bloc.isClosed) {
            bloc.add(LoadMeditationSession([]));
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('ai.meditation.title'.tr()),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: _loadMeditation,
          ),
        ],
      ),
      body: BlocProvider<MeditationBloc>.value(
        value: ref.read(meditationBlocProvider),
        child: RefreshIndicator(
          onRefresh: () async {
            _loadMeditation();
            // Ждем немного для анимации
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(PlatformUtils.getAdaptivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _buildHeroSection(context, theme, colorScheme, isDark),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(context, theme, colorScheme),

                const SizedBox(height: 24),

                // Meditation Content
                BlocBuilder<MeditationBloc, MeditationState>(
                  builder: (context, state) {
                    if (state is MeditationLoading) {
                      return _MeditationLoadingWidget(
                        theme: theme,
                        colorScheme: colorScheme,
                      );
                    } else if (state is MeditationLoaded) {
                      return _MeditationCard(
                        meditation: state.meditation,
                        theme: theme,
                        colorScheme: colorScheme,
                      );
                    } else if (state is MeditationError) {
                      return _MeditationErrorWidget(
                        message: state.message,
                        theme: theme,
                        colorScheme: colorScheme,
                        onRetry: _loadMeditation,
                      );
                    }
                    return _buildEmptyState(context, theme, colorScheme);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [colorScheme.surfaceContainerHighest, colorScheme.surface]
              : [
                  colorScheme.primaryContainer.withOpacity(0.3),
                  colorScheme.secondaryContainer.withOpacity(0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          PlatformUtils.getAdaptiveRadius(context),
        ),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.self_improvement,
              color: colorScheme.onPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ai.meditation.title'.tr(),
                  style: AppTypography.h2.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ai.meditation.personal_practices'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final moodEntriesAsync = ref.watch(recentMoodEntriesProvider);

    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.access_time,
            label: 'ai.meditation.quick'.tr(),
            colorScheme: colorScheme,
            onTap: () {
              final bloc = context.read<MeditationBloc>();
              if (!bloc.isClosed) {
                moodEntriesAsync.when(
                  data: (moodEntries) {
                    if (!bloc.isClosed) {
                      bloc.add(LoadShortMeditationSession(moodEntries));
                    }
                  },
                  loading: () {
                    if (!bloc.isClosed) {
                      bloc.add(LoadShortMeditationSession([]));
                    }
                  },
                  error: (_, __) {
                    if (!bloc.isClosed) {
                      bloc.add(LoadShortMeditationSession([]));
                    }
                  },
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.timer,
            label: 'ai.meditation.deep'.tr(),
            colorScheme: colorScheme,
            onTap: () {
              final bloc = context.read<MeditationBloc>();
              if (!bloc.isClosed) {
                moodEntriesAsync.when(
                  data: (moodEntries) {
                    if (!bloc.isClosed) {
                      bloc.add(LoadLongMeditationSession(moodEntries));
                    }
                  },
                  loading: () {
                    if (!bloc.isClosed) {
                      bloc.add(LoadLongMeditationSession([]));
                    }
                  },
                  error: (_, __) {
                    if (!bloc.isClosed) {
                      bloc.add(LoadLongMeditationSession([]));
                    }
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.self_improvement_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'ai.meditation.no_meditation'.tr(),
              style: AppTypography.h3.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ai.meditation.tap_to_load'.tr(),
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMeditation,
              icon: const Icon(Icons.refresh),
              label: Text('common.refresh'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка медитации
class _MeditationCard extends StatelessWidget {
  final MeditationEntity meditation;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _MeditationCard({
    required this.meditation,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: meditation.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      meditation.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meditation.title,
                        style: AppTypography.h3.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meditation.type.displayName,
                        style: AppTypography.caption.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Description
            Text(
              meditation.description,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // Info Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.timer,
                  label: '${meditation.duration} ${'common.minutes'.tr()}',
                  color: meditation.accentColor,
                  colorScheme: colorScheme,
                ),
                _InfoChip(
                  icon: Icons.speed,
                  label: meditation.difficulty.displayName,
                  color: meditation.difficulty.color,
                  colorScheme: colorScheme,
                ),
                _InfoChip(
                  icon: meditation.type.emoji,
                  label: meditation.type.displayName,
                  color: meditation.accentColor,
                  colorScheme: colorScheme,
                  isEmoji: true,
                ),
              ],
            ),

            if (meditation.instructions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Divider(color: colorScheme.outline.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text(
                'ai.meditation.instructions'.tr(),
                style: AppTypography.h4.copyWith(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              ...meditation.instructions
                  .take(5)
                  .map(
                    (instruction) => _InstructionItem(
                      instruction: instruction,
                      index: meditation.instructions.indexOf(instruction) + 1,
                      color: meditation.accentColor,
                      colorScheme: colorScheme,
                    ),
                  ),
            ],

            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/stats/meditation/timer', extra: meditation);
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  'ai.meditation.start_meditation'.tr(
                    namedArgs: {'duration': meditation.duration.toString()},
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: meditation.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Информационный чип
class _InfoChip extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final ColorScheme colorScheme;
  final bool isEmoji;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.colorScheme,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isEmoji
              ? Text(icon, style: const TextStyle(fontSize: 14))
              : Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Элемент инструкции
class _InstructionItem extends StatelessWidget {
  final String instruction;
  final int index;
  final Color color;
  final ColorScheme colorScheme;

  const _InstructionItem({
    required this.instruction,
    required this.index,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Кнопка быстрого действия
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

/// Виджет загрузки
class _MeditationLoadingWidget extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _MeditationLoadingWidget({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ai.meditation.loading_practices'.tr(),
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Виджет ошибки
class _MeditationErrorWidget extends StatelessWidget {
  final String message;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onRetry;

  const _MeditationErrorWidget({
    required this.message,
    required this.theme,
    required this.colorScheme,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: colorScheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'common.error'.tr(),
              style: AppTypography.h3.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
