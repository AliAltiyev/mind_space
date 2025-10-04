import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../app/providers/ai_features_provider.dart';

/// Экран профиля - строгий и понятный дизайн
class ProfileScreenClean extends ConsumerStatefulWidget {
  const ProfileScreenClean({super.key});

  @override
  ConsumerState<ProfileScreenClean> createState() => _ProfileScreenCleanState();
}

class _ProfileScreenCleanState extends ConsumerState<ProfileScreenClean> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final allEntriesAsync = ref.watch(allMoodEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: AppColors.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
            tooltip: 'Настройки',
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

  /// Информация о пользователе
  Widget _buildUserInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
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
                      ? const Icon(
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
            'Пользователь',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          
          const SizedBox(height: 8),
          
          // Дата регистрации
          Text(
            'Участник с ${DateFormat('MMMM yyyy').format(DateTime.now())}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
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
          Icon(
            Icons.star,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Уровень 1 - Новичок',
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
  Widget _buildStatsSection(BuildContext context, AsyncValue<List<dynamic>> allEntriesAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
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
    final thisWeek = entries.where((e) => 
        e.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;
    final avgMood = entries.isEmpty 
        ? 0.0 
        : entries.map((e) => e.moodValue).reduce((a, b) => a + b) / entries.length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Всего записей',
                value: totalEntries.toString(),
                icon: Icons.list_alt,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Серия дней',
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
                title: 'За неделю',
                value: thisWeek.toString(),
                icon: Icons.calendar_today,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Среднее настроение',
                value: avgMood.toStringAsFixed(1),
                icon: Icons.sentiment_satisfied,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрые действия',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          
          const SizedBox(height: 16),
          
          _ActionTile(
            icon: Icons.add_circle_outline,
            title: 'Добавить настроение',
            subtitle: 'Записать текущее состояние',
            onTap: () => context.push('/add-entry'),
            color: AppColors.primary,
          ),
          
          _ActionTile(
            icon: Icons.analytics_outlined,
            title: 'Статистика',
            subtitle: 'Посмотреть аналитику',
            onTap: () => context.go('/stats'),
            color: AppColors.secondary,
          ),
          
          _ActionTile(
            icon: Icons.psychology_outlined,
            title: 'AI Помощник',
            subtitle: 'Поговорить с AI',
            onTap: () => context.go('/ai-chat'),
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  /// Дополнительные функции
  Widget _buildAdditionalFeatures(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Дополнительно',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          
          const SizedBox(height: 16),
          
          _ActionTile(
            icon: Icons.settings_outlined,
            title: 'Настройки',
            subtitle: 'Конфигурация приложения',
            onTap: () => context.go('/settings'),
          ),
          
          _ActionTile(
            icon: Icons.share_outlined,
            title: 'Поделиться',
            subtitle: 'Рассказать друзьям о приложении',
            onTap: _shareApp,
          ),
          
          _ActionTile(
            icon: Icons.help_outline,
            title: 'Помощь',
            subtitle: 'Поддержка и FAQ',
            onTap: _showHelp,
          ),
          
          _ActionTile(
            icon: Icons.info_outline,
            title: 'О приложении',
            subtitle: 'Версия 1.0.0',
            onTap: () => context.go('/settings/about'),
          ),
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
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Ошибка загрузки данных',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
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
              'Выберите фото профиля',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Камера',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _ImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Галерея',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImage != null)
                  _ImagePickerOption(
                    icon: Icons.delete,
                    label: 'Удалить',
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
        setState(() {
          _profileImage = File(image.path);
        });

        // TODO: Сохранить изображение в локальное хранилище
        // await _saveProfileImage(_profileImage!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Удалить изображение
  void _removeImage() {
    setState(() {
      _profileImage = null;
    });

    // TODO: Удалить изображение из локального хранилища
    // await _removeProfileImage();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото профиля удалено'),
          backgroundColor: AppColors.success,
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
          Text(
            value,
            style: AppTypography.h3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.caption,
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
              child: Icon(
                icon,
                color: color ?? AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
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
