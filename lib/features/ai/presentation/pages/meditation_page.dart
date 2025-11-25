import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../app/providers/ai_features_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text('ai.meditation.title'.tr()),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left),
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
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            onPressed: () {
              if (!context.read<MeditationBloc>().isClosed) {
                context.read<MeditationBloc>().add(LoadMeditationSession([]));
              }
            },
            tooltip: 'common.refresh'.tr(),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Приветственный заголовок
                _buildWelcomeSection(),

                const SizedBox(height: 24),

                // Контент медитации
                BlocBuilder<MeditationBloc, MeditationState>(
                  builder: (context, state) {
                    if (state is MeditationLoading) {
                      return _MeditationLoadingWidget(
                        theme: theme,
                        colorScheme: colorScheme,
                      );
                    } else if (state is MeditationLoaded) {
                      return _buildMeditationContent(state.meditation);
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

  /// Приветственная секция
  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: const Icon(
              CupertinoIcons.star,
              color: Colors.white,
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
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ai.meditation.personal_practices'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Контент медитации
  Widget _buildMeditationContent(MeditationEntity meditation) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок медитации
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
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
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${meditation.duration} ${'common.minutes'.tr()}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Описание
              Text(
                meditation.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 24),

              // Инструкции
              if (meditation.instructions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.sparkles,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ai.meditation.instructions'.tr(),
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...meditation.instructions.map(
                        (instruction) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(
                                  top: 6,
                                  right: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  instruction,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Кнопка начала медитации
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Навигация к экрану таймера медитации
                    context.push('/stats/meditation/timer', extra: meditation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.play_fill, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'ai.meditation.start_meditation'.tr(
                          namedArgs: {
                            'duration': meditation.duration.toString(),
                          },
                        ),
                        style: AppTypography.button.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Пустое состояние
  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.star,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'ai.meditation.no_meditation'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'ai.meditation.loading_practices'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.exclamationmark_circle,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'common.error'.tr(),
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(CupertinoIcons.arrow_clockwise, size: 20),
            label: Text('common.retry'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
