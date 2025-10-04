import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../app/providers/app_providers.dart';

/// Главный экран настроек - строгий и понятный дизайн
class SettingsScreenClean extends ConsumerWidget {
  const SettingsScreenClean({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Профиль
          _SettingsSection(
            title: 'Профиль',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Мой профиль',
                subtitle: 'Редактировать информацию',
                onTap: () => context.go('/settings/profile'),
              ),
              _SettingsTile(
                icon: Icons.emoji_events_outlined,
                title: 'Достижения',
                subtitle: 'Ваши успехи',
                onTap: () => context.go('/settings/achievements'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Уведомления
          _SettingsSection(
            title: 'Уведомления',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Напоминания',
                subtitle: 'Управление уведомлениями',
                onTap: () => context.go('/settings/notifications'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Внешний вид
          _SettingsSection(
            title: 'Внешний вид',
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Тема',
                subtitle: 'Светлая тема',
                onTap: () => context.go('/settings/appearance'),
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: 'Язык',
                subtitle: 'Русский',
                onTap: () => context.go('/settings/language'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Данные
          _SettingsSection(
            title: 'Данные',
            children: [
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Экспорт данных',
                subtitle: 'Скачать ваши записи',
                onTap: () => context.go('/settings/export'),
              ),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Очистить данные',
                subtitle: 'Удалить все записи',
                onTap: () => _showClearDataDialog(context, ref),
                isDestructive: true,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // О приложении
          _SettingsSection(
            title: 'О приложении',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'О приложении',
                subtitle: 'Версия 1.0.0',
                onTap: () => context.go('/settings/about'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Конфиденциальность',
                subtitle: 'Политика конфиденциальности',
                onTap: () => context.go('/settings/privacy'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Показать диалог подтверждения очистки данных
  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить данные'),
        content: const Text(
          'Вы уверены, что хотите удалить все записи настроения и AI инсайты? Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Все данные очищены'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  /// Очистка всех данных
  Future<void> _clearAllData(WidgetRef ref) async {
    final database = ref.read(appDatabaseProvider);
    await database.clearAllData();
  }
}

/// Секция настроек
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Элемент настроек
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive 
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
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
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
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
