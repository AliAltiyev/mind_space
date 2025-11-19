import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/ai_features_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../blocs/meditation_bloc.dart';
import '../widgets/meditation_suggestion_card.dart';

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
      if (!context.read<MeditationBloc>().isClosed) {
        context.read<MeditationBloc>().add(LoadMeditationSession([]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        title: Text(
          'ai.meditation.title'.tr(),
          style: AppTypography.h3.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.textPrimary,
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
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () {
              if (!context.read<MeditationBloc>().isClosed) {
                context.read<MeditationBloc>().add(LoadMeditationSession([]));
              }
            },
          ),
        ],
      ),
      body: BlocProvider<MeditationBloc>(
        create: (context) => ref.read(meditationBlocProvider),
        child: RefreshIndicator(
          onRefresh: () async {
            if (!context.read<MeditationBloc>().isClosed) {
              context.read<MeditationBloc>().add(LoadMeditationSession([]));
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _buildHeroSection(context, isDark),

                const SizedBox(height: 24),

                // Meditation Content
                BlocBuilder<MeditationBloc, MeditationState>(
                  builder: (context, state) {
                    if (state is MeditationLoading) {
                      return _MeditationLoadingWidget(isDark: isDark);
                    } else if (state is MeditationLoaded) {
                      return MeditationSuggestionCard(
                        meditation: state.meditation,
                      );
                    } else if (state is MeditationError) {
                      return _MeditationErrorWidget(
                        message: state.message,
                        isDark: isDark,
                        onRetry: () {
                          if (!context.read<MeditationBloc>().isClosed) {
                            context.read<MeditationBloc>().add(
                              LoadMeditationSession([]),
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
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.border.withOpacity(0.5),
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
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: const Icon(
              Icons.self_improvement,
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
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ai.meditation.personal_practices'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeditationLoadingWidget extends StatelessWidget {
  final bool isDark;

  const _MeditationLoadingWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ai.meditation.loading_practices'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MeditationErrorWidget extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  const _MeditationErrorWidget({
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.error.withOpacity(0.2),
        ),
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
            child: Icon(Icons.error_outline, color: AppColors.error, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            'common.error'.tr(),
            style: AppTypography.h3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
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
