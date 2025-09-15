import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Главный экран настроек
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Уведомления
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications,
                title: 'Notification Settings',
                subtitle: 'Manage your notification preferences',
                onTap: () => context.go('/settings/notifications'),
              ),
            ],
          ),

          // Внешний вид
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.palette,
                title: 'Appearance Settings',
                subtitle: 'Customize theme and colors',
                onTap: () => context.go('/settings/appearance'),
              ),
            ],
          ),

          // Данные
          _SettingsSection(
            title: 'Data',
            children: [
              _SettingsTile(
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download your data as PDF or CSV',
                onTap: () => context.go('/settings/export'),
              ),
            ],
          ),

          // Конфиденциальность
          _SettingsSection(
            title: 'Privacy & Security',
            children: [
              _SettingsTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Settings',
                subtitle: 'Manage your privacy preferences',
                onTap: () => context.go('/settings/privacy'),
              ),
            ],
          ),

          // О приложении
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version, terms, and contact',
                onTap: () => context.go('/settings/about'),
              ),
            ],
          ),
        ],
      ),
    );
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

