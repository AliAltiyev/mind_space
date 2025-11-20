import 'package:flutter/material.dart';
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

/// Экран профиля - строгий и понятный дизайн
class ProfileScreenClean extends ConsumerStatefulWidget {
  const ProfileScreenClean({super.key});

  @override
  ConsumerState<ProfileScreenClean> createState() => _ProfileScreenCleanState();
}

class _ProfileScreenCleanState extends ConsumerState<ProfileScreenClean> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final ProfileImageService _profileImageService = ProfileImageService();
  final UserLevelService _levelService = UserLevelService();
  bool _isLoadingImage = false;
  UserLevelStats? _userStats;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserStats();
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
    final userProfileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        title: Text('profile.title'.tr()),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        elevation: 1,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
            tooltip: 'profile.edit'.tr(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
            tooltip: 'settings.title'.tr(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о пользователе
            _buildUserInfo(context),

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
    );
  }

  /// Информация о пользователе (загрузка)
  Widget _buildUserInfoLoading(BuildContext context) {
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
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Информация о пользователе
  Widget _buildUserInfo(BuildContext context, dynamic profile) {
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
        children: [
          // Аватар с возможностью изменения
          GestureDetector(
            onTap: () => _showImagePicker(context),
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _profileImage == null
                        ? LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(40),
                    border: _profileImage != null
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                    image: _profileImage != null
                        ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _profileImage == null
                      ? _isLoadingImage
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Имя пользователя
          Text(
            profile?.name ?? 'profile.user'.tr(),
            style: AppTypography.h2.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
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
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Уровень прогресса
          _buildProgressLevel(),
        ],
      ),
    );
  }

  /// Уровень прогресса
  Widget _buildProgressLevel() {
    if (_userStats == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.border,
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
            const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_userStats!.levelIcon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
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
            style: AppTypography.h3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          allEntriesAsync.when(
            data: (entries) => _buildStatsGrid(entries),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(),
          ),
        ],
      ),
    );
  }

  /// Сетка статистики
  Widget _buildStatsGrid(List<dynamic> entries) {
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'stats.total_entries'.tr(),
                value: totalEntries.toString(),
                icon: Icons.list_alt,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'stats.streak'.tr(),
                value: '$streak дней',
                icon: Icons.local_fire_department,
                color: AppColors.warning,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'stats.weekly_overview'.tr(),
                value: thisWeek.toString(),
                icon: Icons.calendar_today,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'stats.average_mood'.tr(),
                value: avgMood.toStringAsFixed(1),
                icon: Icons.sentiment_satisfied,
                color: AppColors.success,
              ),
            ),
          ],
        ),

        // Дополнительная информация об уровне, если есть
        if (_userStats != null) ...[
          const SizedBox(height: 12),
          Builder(builder: (context) => _buildLevelProgressCard(context)),
        ],
      ],
    );
  }

  /// Карточка прогресса уровня
  Widget _buildLevelProgressCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_userStats!.levelIcon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_userStats!.experienceToNext} опыта до следующего уровня',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? Colors.white70 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _userStats!.progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
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
            style: AppTypography.h3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          _ActionTile(
            icon: Icons.add_circle_outline,
            title: 'mood.add_mood'.tr(),
            subtitle: 'profile.record_current_state'.tr(),
            onTap: () => context.push('/add-entry'),
            color: AppColors.primary,
          ),

          _ActionTile(
            icon: Icons.analytics_outlined,
            title: 'stats.title'.tr(),
            subtitle: 'profile.view_analytics'.tr(),
            onTap: () => context.go('/stats'),
            color: AppColors.secondary,
          ),

          _ActionTile(
            icon: Icons.psychology_outlined,
            title: 'ai.chat.title'.tr(),
            subtitle: 'profile.chat_with_ai'.tr(),
            onTap: () => context.go('/ai-chat'),
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  /// Дополнительные функции
  Widget _buildAdditionalFeatures(BuildContext context) {
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
            'settings.additional'.tr(),
            style: AppTypography.h3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          _ActionTile(
            icon: Icons.settings_outlined,
            title: 'settings.title'.tr(),
            subtitle: 'profile.app_configuration'.tr(),
            onTap: () => context.go('/settings'),
          ),

          _ActionTile(
            icon: Icons.share_outlined,
            title: 'profile.share'.tr(),
            subtitle: 'profile.tell_friends'.tr(),
            onTap: _shareApp,
          ),

          _ActionTile(
            icon: Icons.help_outline,
            title: 'profile.help'.tr(),
            subtitle: 'profile.support_faq'.tr(),
            onTap: _showHelp,
          ),

          _ActionTile(
            icon: Icons.info_outline,
            title: 'settings.about_app'.tr(),
            subtitle: 'profile.version_1_0_0'.tr(),
            onTap: () => context.go('/settings/about'),
          ),
        ],
      ),
    );
  }

  /// Состояние ошибки
  Widget _buildErrorState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            'database.error_loading'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'profile.select_photo'.tr(),
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'profile.camera'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _ImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'profile.gallery'.tr(),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImage != null)
                  _ImagePickerOption(
                    icon: Icons.delete,
                    label: 'common.delete'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                    isDestructive: true,
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
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
              content: Text('profile.photo_saved'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('profile.photo_save_error'.tr()),
              backgroundColor: AppColors.error,
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
          content: Text(
            success
                ? 'profile.photo_deleted'.tr()
                : 'profile.photo_delete_error'.tr(),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? color.withOpacity(0.5) : color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.h3.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: isDark ? Colors.white70 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Элемент действия
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color ?? AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textHint),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? AppColors.error.withOpacity(0.3)
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isDestructive ? AppColors.error : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
