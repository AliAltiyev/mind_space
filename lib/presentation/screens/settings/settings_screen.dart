import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../app/providers/app_providers.dart';

/// Главный экран настроек
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        children: [
          // Уведомления
          _SettingsSection(
            title: 'settings.notifications'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.notifications,
                title: 'settings.notification_settings'.tr(),
                subtitle: 'settings.manage_notifications'.tr(),
                onTap: () => context.go('/settings/notifications'),
              ),
            ],
          ),

          // Внешний вид
          _SettingsSection(
            title: 'settings.appearance'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.palette,
                title: 'settings.appearance_settings'.tr(),
                subtitle: 'settings.customize_theme'.tr(),
                onTap: () => context.go('/settings/appearance'),
              ),
            ],
          ),

          // Данные
          _SettingsSection(
            title: 'settings.data'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.download,
                title: 'settings.export_data'.tr(),
                subtitle: 'settings.download_data'.tr(),
                onTap: () => context.go('/settings/export'),
              ),
            ],
          ),

          // Конфиденциальность
          _SettingsSection(
            title: 'settings.privacy_security'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.privacy_tip,
                title: 'settings.privacy_settings'.tr(),
                subtitle: 'settings.manage_privacy'.tr(),
                onTap: () => context.go('/settings/privacy'),
              ),
            ],
          ),

          // Управление данными
          _SettingsSection(
            title: 'Управление данными',
            children: [
              _SettingsTile(
                icon: Icons.delete_forever,
                title: 'Очистить все данные',
                subtitle: 'Удалить все записи настроения и AI инсайты',
                onTap: () => _showClearDataDialog(context, ref),
              ),
            ],
          ),

          // О приложении
          _SettingsSection(
            title: 'settings.about'.tr(),
            children: [
              _SettingsTile(
                icon: Icons.info,
                title: 'settings.about_app'.tr(),
                subtitle: 'settings.app_version'.tr(),
                onTap: () => context.go('/settings/about'),
              ),
            ],
          ),
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
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      elevation: 0,
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

