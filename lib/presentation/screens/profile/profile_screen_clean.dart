import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../app/providers/ai_features_provider.dart';
import '../../../app/providers/profile_providers.dart';
import '../../../core/services/profile_image_service.dart';
import '../../../core/services/user_level_service.dart';
import '../../../features/profile/domain/entities/user_profile_entity.dart';

/// Экран профиля - Профессиональный дизайн в стиле отслеживания сна
class ProfileScreenClean extends ConsumerStatefulWidget {
  const ProfileScreenClean({super.key});

  @override
  ConsumerState<ProfileScreenClean> createState() => _ProfileScreenCleanState();
}

class _ProfileScreenCleanState extends ConsumerState<ProfileScreenClean>
    with TickerProviderStateMixin {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final ProfileImageService _profileImageService = ProfileImageService();
  final UserLevelService _levelService = UserLevelService();
  bool _isLoadingImage = false;
  UserLevelStats? _userStats;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Анимации для экрана
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _loadProfileImage();
    _loadUserStats();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Загрузить статистику пользователя
  Future<void> _loadUserStats() async {
    try {
      final stats = await _levelService.getUserStats();
      if (mounted) {
        setState(() {
          _userStats = stats;
        });
      }
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  /// Загрузить фото профиля
  Future<void> _loadProfileImage() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final imageFile = await _profileImageService.getProfileImage();
      if (mounted) {
        setState(() {
          _profileImage = imageFile;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEntriesAsync = ref.watch(allMoodEntriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Современный AppBar
            _buildModernAppBar(isDark),

            // Основной контент
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // Информация о пользователе
                        _buildUserInfo(context, ref.watch(userProfileProvider)),

                        const SizedBox(height: 24),

                        // Статистика
                        _buildStatsSection(context, allEntriesAsync),

                        const SizedBox(height: 24),

                        // Быстрые действия
                        _buildQuickActions(context),

                        const SizedBox(height: 24),

                        // Дополнительные функции
                        _buildAdditionalFeatures(context),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Современный AppBar в стиле sleep tracking
  Widget _buildModernAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile.title'.tr(),
                  style: AppTypography.h3.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'profile.subtitle'.tr(),
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => context.push('/profile/edit'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.pencil,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => context.go('/settings'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.settings,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Информация о пользователе
  Widget _buildUserInfo(
    BuildContext context,
    AsyncValue<UserProfileEntity> profileAsync,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return profileAsync.when(
      data: (profile) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
                  : [AppColors.surface, AppColors.surfaceVariant],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Аватар с анимацией
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: GestureDetector(
                      onTap: () => _showImagePicker(context),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: _profileImage == null
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(50),
                              border: _profileImage != null
                                  ? Border.all(
                                      color: AppColors.primary,
                                      width: 3,
                                    )
                                  : null,
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: _profileImage == null
                                ? _isLoadingImage
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.textOnPrimary,
                                              ),
                                        )
                                      : const Icon(
                                          CupertinoIcons.person_fill,
                                          color: AppColors.textOnPrimary,
                                          size: 50,
                                        )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.textOnPrimary,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                CupertinoIcons.camera_fill,
                                color: AppColors.textOnPrimary,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Имя пользователя
              Text(
                profile.name,
                style: AppTypography.h2.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Дата регистрации
              Text(
                'profile.member_since'.tr(
                  namedArgs: {
                    'date': DateFormat('MMMM yyyy').format(DateTime.now()),
                  },
                ),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // Уровень прогресса
              _buildProgressLevel(),
            ],
          ),
        ),
      ),
      loading: () => _buildUserInfoLoading(context),
      error: (error, stack) => _buildUserInfoError(context, isDark),
    );
  }

  /// Информация о пользователе (загрузка)
  Widget _buildUserInfoLoading(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Информация о пользователе (ошибка)
  Widget _buildUserInfoError(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'profile.loading_error_full'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Уровень прогресса
  Widget _buildProgressLevel() {
    if (_userStats == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'common.loading'.tr(),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_userStats!.levelIcon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(
            'user_level.level'.tr(
              namedArgs: {
                'level': _userStats!.level.toString(),
                'name': _userStats!.levelName,
              },
            ),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Секция статистики
  Widget _buildStatsSection(
    BuildContext context,
    AsyncValue<List<dynamic>> allEntriesAsync,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
              : [AppColors.surface, AppColors.surfaceVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.chart_bar_fill,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'stats.title'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          allEntriesAsync.when(
            data: (entries) => _buildStatsGrid(entries, isDark),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(),
          ),
        ],
      ),
    );
  }

  /// Сетка статистики с анимациями
  Widget _buildStatsGrid(List<dynamic> entries, bool isDark) {
    final totalEntries = entries.length;
    final streak = _calculateStreak(entries);
    final thisWeek = entries
        .where(
          (e) => e.createdAt.isAfter(
            DateTime.now().subtract(const Duration(days: 7)),
          ),
        )
        .length;
    final avgMood = entries.isEmpty
        ? 0.0
        : entries.map((e) => e.moodValue).reduce((a, b) => a + b) /
              entries.length;

    final stats = [
      {
        'title': 'stats.total_entries'.tr(),
        'value': totalEntries.toString(),
        'icon': CupertinoIcons.list_bullet,
        'color': AppColors.primary,
      },
      {
        'title': 'stats.streak'.tr(),
        'value': '$streak ${'common.days'.tr()}',
        'icon': CupertinoIcons.flame_fill,
        'color': AppColors.warning,
      },
      {
        'title': 'stats.weekly_overview'.tr(),
        'value': thisWeek.toString(),
        'icon': CupertinoIcons.calendar,
        'color': AppColors.info,
      },
      {
        'title': 'stats.average_mood'.tr(),
        'value': avgMood.toStringAsFixed(1),
        'icon': CupertinoIcons.smiley_fill,
        'color': AppColors.success,
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnimatedStatCard(
                title: stats[0]['title'] as String,
                value: stats[0]['value'] as String,
                icon: stats[0]['icon'] as IconData,
                color: stats[0]['color'] as Color,
                isDark: isDark,
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnimatedStatCard(
                title: stats[1]['title'] as String,
                value: stats[1]['value'] as String,
                icon: stats[1]['icon'] as IconData,
                color: stats[1]['color'] as Color,
                isDark: isDark,
                delay: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedStatCard(
                title: stats[2]['title'] as String,
                value: stats[2]['value'] as String,
                icon: stats[2]['icon'] as IconData,
                color: stats[2]['color'] as Color,
                isDark: isDark,
                delay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnimatedStatCard(
                title: stats[3]['title'] as String,
                value: stats[3]['value'] as String,
                icon: stats[3]['icon'] as IconData,
                color: stats[3]['color'] as Color,
                isDark: isDark,
                delay: 300,
              ),
            ),
          ],
        ),
        if (_userStats != null) ...[
          const SizedBox(height: 16),
          _buildLevelProgressCard(isDark),
        ],
      ],
    );
  }

  /// Анимированная карточка статистики
  Widget _buildAnimatedStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: scale.clamp(0.0, 1.0), child: child),
        );
      },
      child: _StatCard(
        title: title,
        value: value,
        icon: icon,
        color: color,
        isDark: isDark,
      ),
    );
  }

  /// Карточка прогресса уровня
  Widget _buildLevelProgressCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_userStats!.levelIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'user_level.level'.tr(
                        namedArgs: {
                          'level': _userStats!.level.toString(),
                          'name': _userStats!.levelName,
                        },
                      ),
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_userStats!.experienceToNext} ${'profile.exp_to_next'.tr()}',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _userStats!.progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actions = [
      {
        'icon': CupertinoIcons.add_circled_solid,
        'title': 'mood.add_mood'.tr(),
        'subtitle': 'profile.record_current_state'.tr(),
        'onTap': () => context.push('/add-entry'),
        'color': AppColors.primary,
      },
      {
        'icon': CupertinoIcons.chart_bar_alt_fill,
        'title': 'stats.title'.tr(),
        'subtitle': 'profile.view_analytics'.tr(),
        'onTap': () => context.go('/stats'),
        'color': AppColors.secondary,
      },
      {
        'icon': CupertinoIcons.sparkles,
        'title': 'ai.chat.title'.tr(),
        'subtitle': 'profile.chat_with_ai'.tr(),
        'onTap': () => context.go('/ai-chat'),
        'color': AppColors.primaryLight,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
              : [AppColors.surface, AppColors.surfaceVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.bolt_fill,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'home.quick_actions'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final clampedValue = value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - clampedValue)),
                  child: Opacity(opacity: clampedValue, child: child),
                );
              },
              child: _ActionTile(
                icon: action['icon'] as IconData,
                title: action['title'] as String,
                subtitle: action['subtitle'] as String,
                onTap: action['onTap'] as VoidCallback,
                color: action['color'] as Color,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Дополнительные функции
  Widget _buildAdditionalFeatures(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final features = [
      {
        'icon': CupertinoIcons.settings,
        'title': 'settings.title'.tr(),
        'subtitle': 'profile.app_configuration'.tr(),
        'onTap': () => context.go('/settings'),
      },
      {
        'icon': CupertinoIcons.share,
        'title': 'profile.share'.tr(),
        'subtitle': 'profile.tell_friends'.tr(),
        'onTap': _shareApp,
      },
      {
        'icon': CupertinoIcons.question_circle,
        'title': 'profile.help'.tr(),
        'subtitle': 'profile.support_faq'.tr(),
        'onTap': _showHelp,
      },
      {
        'icon': CupertinoIcons.info,
        'title': 'settings.about_app'.tr(),
        'subtitle': 'profile.version_1_0_0'.tr(),
        'onTap': () => context.go('/settings/about'),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
              : [AppColors.surface, AppColors.surfaceVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.square_grid_2x2_fill,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'settings.additional'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final clampedValue = value.clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - clampedValue)),
                  child: Opacity(opacity: clampedValue, child: child),
                );
              },
              child: _ActionTile(
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                subtitle: feature['subtitle'] as String,
                onTap: feature['onTap'] as VoidCallback,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Состояние ошибки
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'database.error_loading'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Расчет серии дней
  int _calculateStreak(List<dynamic> entries) {
    if (entries.isEmpty) return 0;

    final sortedEntries = List.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < sortedEntries.length; i++) {
      final entryDate = sortedEntries[i].createdAt;
      final daysDiff = today.difference(entryDate).inDays;

      if (daysDiff == streak) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Поделиться приложением
  void _shareApp() {
    // TODO: Реализовать функциональность "Поделиться"
    print('Share app functionality');
  }

  /// Показать помощь
  void _showHelp() {
    // TODO: Реализовать экран помощи
    print('Show help functionality');
  }

  /// Показать диалог выбора изображения
  void _showImagePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'profile.select_photo'.tr(),
                      style: AppTypography.h3.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ImagePickerOption(
                          icon: CupertinoIcons.camera_fill,
                          label: 'profile.camera'.tr(),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        _ImagePickerOption(
                          icon: CupertinoIcons.photo_fill,
                          label: 'profile.gallery'.tr(),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                        if (_profileImage != null)
                          _ImagePickerOption(
                            icon: CupertinoIcons.delete,
                            label: 'common.delete'.tr(),
                            onTap: () {
                              Navigator.pop(context);
                              _removeImage();
                            },
                            isDestructive: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Выбор изображения
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );

      if (image != null) {
        final imageFile = File(image.path);
        setState(() {
          _profileImage = imageFile;
        });

        // Сохранить изображение в локальное хранилище
        final success = await _profileImageService.saveProfileImage(imageFile);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: 10),
                  Text('profile.photo_saved'.tr()),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: 10),
                  Text('profile.photo_save_error'.tr()),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'profile.image_selection_error'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Удалить изображение
  Future<void> _removeImage() async {
    setState(() {
      _profileImage = null;
    });

    // Удалить изображение из локального хранилища
    final success = await _profileImageService.removeProfileImage();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.exclamationmark_circle_fill,
                color: AppColors.textOnPrimary,
              ),
              const SizedBox(width: 10),
              Text(
                success
                    ? 'profile.photo_deleted'.tr()
                    : 'profile.photo_delete_error'.tr(),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

/// Карточка статистики в современном стиле
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.2 : 0.15),
            color.withOpacity(isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Элемент действия в современном стиле
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  final bool isDark;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final actionColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    actionColor.withOpacity(0.2),
                    actionColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: actionColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Опция выбора изображения
class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
