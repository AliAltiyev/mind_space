import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

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
        title: Text('settings.title'.tr()),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Профиль
          _SettingsSection(
            title: 'settings.profile'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'profile.title'.tr(),
                subtitle: 'profile.edit'.tr(),
                onTap: () => context.go('/settings/profile'),
              ),
              _SettingsTile(
                icon: Icons.emoji_events_outlined,
                title: 'profile.achievements'.tr(),
                subtitle: 'achievements.title'.tr(),
                onTap: () => context.go('/settings/achievements'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Уведомления
          _SettingsSection(
            title: 'settings.notifications'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'notifications.daily_reminders'.tr(),
                subtitle: 'settings.manage_notifications'.tr(),
                onTap: () => context.go('/settings/notifications'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Внешний вид
          _SettingsSection(
            title: 'settings.appearance'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'settings.theme'.tr(),
                subtitle: 'settings.themes.light'.tr(),
                onTap: () => context.go('/settings/appearance'),
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: 'settings.language'.tr(),
                subtitle: 'settings.languages.russian'.tr(),
                onTap: () => context.go('/settings/language'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Данные
          _SettingsSection(
            title: 'settings.data'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'settings.export_data'.tr(),
                subtitle: 'settings.download_data'.tr(),
                onTap: () => context.go('/settings/export'),
              ),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'settings.delete_all_data'.tr(),
                subtitle: 'settings.delete_all_data_desc'.tr(),
                onTap: () => _showClearDataDialog(context, ref),
                isDestructive: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // О приложении
          _SettingsSection(
            title: 'settings.about'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'settings.about_app'.tr(),
                subtitle: 'profile.version_1_0_0'.tr(),
                onTap: () => context.go('/settings/about'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'settings.privacy_policy'.tr(),
                subtitle: 'settings.privacy_policy_desc'.tr(),
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
        title: Text('settings.delete_all_data_dialog'.tr()),
        content: Text('settings.delete_all_data_warning'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('settings.all_data_deleted'.tr()),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('common.delete'.tr()),
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

  const _SettingsSection({required this.title, required this.children});

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
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
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
