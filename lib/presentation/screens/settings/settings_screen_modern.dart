import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/app_settings_service.dart' as settings;
import '../../../core/services/user_level_service.dart';
import '../../../app/providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

/// Современный экран настроек для iOS и Android
class SettingsScreenModern extends ConsumerStatefulWidget {
  const SettingsScreenModern({super.key});

  @override
  ConsumerState<SettingsScreenModern> createState() =>
      _SettingsScreenModernState();
}

class _SettingsScreenModernState extends ConsumerState<SettingsScreenModern> {
  final settings.AppSettingsService _settingsService =
      settings.AppSettingsService();
  final UserLevelService _levelService = UserLevelService();
  settings.AppSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.getAllSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('settings.settings_loading_error'.tr());
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Персональные настройки
            _buildSectionHeader('settings.personal_settings'.tr()),
            _buildPersonalSettings(),

            const SizedBox(height: 24),

            // Внешний вид
            _buildSectionHeader('settings.appearance'.tr()),
            _buildAppearanceSettings(),

            const SizedBox(height: 24),

            // Уведомления
            _buildSectionHeader('settings.notifications'.tr()),
            _buildNotificationSettings(),

            const SizedBox(height: 24),

            // Приватность и данные
            _buildSectionHeader('settings.privacy_security'.tr()),
            _buildPrivacySettings(),

            const SizedBox(height: 24),

            // Дополнительно
            _buildSectionHeader('settings.additional'.tr()),
            _buildAdditionalSettings(),

            const SizedBox(height: 24),

            // О приложении
            _buildSectionHeader('settings.about_app'.tr()),
            _buildAboutSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        'settings.title'.tr(),
        style: AppTypography.h4.copyWith(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalSettings() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'settings.profile'.tr(),
                subtitle: 'settings.profile_management'.tr(),
                onTap: () => context.go('/profile'),
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.language,
                title: 'settings.language'.tr(),
                subtitle:
                    _settings?.language.displayName ??
                    settings.AppLanguage.russian.displayName,
                onTap: _showLanguageDialog,
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.emoji_emotions_outlined,
                title: 'settings.mood_tracking_goal'.tr(),
                subtitle:
                    '${_settings?.moodTrackingGoal ?? 7} ${'settings.days_per_week'.tr()}',
                onTap: _showMoodGoalDialog,
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSettings() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
              _buildSettingTile(
                icon: Icons.palette_outlined,
                title: 'settings.theme'.tr(),
                subtitle: _settings?.theme.displayName ?? 'Системная',
                onTap: _showThemeDialog,
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.volume_up_outlined,
                title: 'settings.sounds'.tr(),
                subtitle: 'settings.sound_effects'.tr(),
                value: _settings?.soundEnabled ?? true,
                onChanged: (value) => _updateSetting(
                  () => _settingsService.setSoundEnabled(value),
                  '${'settings.sounds'.tr()} ${value ? 'settings.enabled'.tr() : 'settings.disabled'.tr()}',
                ),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'Тактильная обратная связь',
                subtitle: 'Вибрация при нажатиях',
                value: _settings?.hapticFeedbackEnabled ?? true,
                onChanged: (value) => _updateSetting(
                  () => _settingsService.setHapticFeedbackEnabled(value),
                  'Тактильная обратная связь ${value ? 'включена' : 'выключена'}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationSettings() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Уведомления',
                subtitle: 'Разрешить уведомления от приложения',
                value: _settings?.notificationsEnabled ?? true,
                onChanged: (value) => _updateSetting(
                  () => _settingsService.setNotificationsEnabled(value),
                  'Уведомления ${value ? 'включены' : 'выключены'}',
                ),
              ),
              if (_settings?.notificationsEnabled == true) ...[
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.schedule,
                  title: 'Ежедневные напоминания',
                  subtitle: 'Напоминание о записи настроения',
                  value: _settings?.dailyReminderEnabled ?? true,
                  onChanged: (value) => _updateSetting(
                    () => _settingsService.setDailyReminderEnabled(value),
                    'Ежедневные напоминания ${value ? 'включены' : 'выключены'}',
                  ),
                ),
                if (_settings?.dailyReminderEnabled == true) ...[
                  _buildDivider(),
                  _buildSettingTile(
                    icon: Icons.access_time,
                    title: 'Время напоминания',
                    subtitle: _formatTime(
                      _settings?.reminderTime ??
                          const TimeOfDay(hour: 20, minute: 0),
                    ),
                    onTap: _showTimePicker,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.analytics_outlined,
                  title: 'Еженедельные отчеты',
                  subtitle: 'Отчеты о вашем прогрессе',
                  value: _settings?.weeklyReportEnabled ?? true,
                  onChanged: (value) => _updateSetting(
                    () => _settingsService.setWeeklyReportEnabled(value),
                    'Еженедельные отчеты ${value ? 'включены' : 'выключены'}',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrivacySettings() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
              _buildSwitchTile(
                icon: Icons.analytics_outlined,
                title: 'Аналитика',
                subtitle: 'Помочь улучшить приложение',
                value: _settings?.analyticsEnabled ?? true,
                onChanged: (value) => _updateSetting(
                  () => _settingsService.setAnalyticsEnabled(value),
                  'Аналитика ${value ? 'включена' : 'выключена'}',
                ),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.backup_outlined,
                title: 'Экспорт данных',
                subtitle: 'Возможность экспорта ваших данных',
                value: _settings?.dataExportEnabled ?? true,
                onChanged: (value) => _updateSetting(
                  () => _settingsService.setDataExportEnabled(value),
                  'Экспорт данных ${value ? 'включен' : 'выключен'}',
                ),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.download_outlined,
                title: 'Экспорт данных',
                subtitle: 'Скачать ваши данные',
                onTap: _exportData,
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.delete_outline,
                title: 'Удалить все данные',
                subtitle: 'Очистить все данные приложения',
                onTap: _showDeleteDataDialog,
                trailing: const Icon(Icons.chevron_right),
                textColor: AppColors.error,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdditionalSettings() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Помощь и поддержка',
                subtitle: 'Часто задаваемые вопросы',
                onTap: () => _showHelpDialog(),
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.feedback_outlined,
                title: 'Обратная связь',
                subtitle: 'Сообщить о проблеме или предложении',
                onTap: () => _showFeedbackDialog(),
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.star_outline,
                title: 'Оценить приложение',
                subtitle: 'Оценить в App Store / Google Play',
                onTap: _rateApp,
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
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
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'Версия приложения',
                subtitle: '1.0.0',
                onTap: null,
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Политика конфиденциальности',
                subtitle: 'Как мы используем ваши данные',
                onTap: () => _showPrivacyPolicy(),
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.description_outlined,
                title: 'Условия использования',
                subtitle: 'Правила использования приложения',
                onTap: () => _showTermsOfService(),
                trailing: const Icon(Icons.chevron_right),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.refresh,
                title: 'Сбросить настройки',
                subtitle: 'Вернуть настройки по умолчанию',
                onTap: _showResetSettingsDialog,
                trailing: const Icon(Icons.chevron_right),
                textColor: AppColors.warning,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color:
                  textColor ?? (isDark ? Colors.white : AppColors.textPrimary),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          trailing: trailing,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          trailing: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Divider(
          height: 1,
          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
          indent: 56,
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateSetting(
    Future<void> Function() updateFunction,
    String successMessage,
  ) async {
    try {
      await updateFunction();
      await _loadSettings();
      _showSuccessSnackBar(successMessage);
    } catch (e) {
      _showErrorSnackBar('Ошибка обновления настройки');
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: settings.AppTheme.values.map((theme) {
            return RadioListTile<settings.AppTheme>(
              title: Text(theme.displayName),
              value: theme,
              groupValue: _settings?.theme,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.of(context).pop();
                  await _updateSetting(
                    () => _settingsService.setTheme(value),
                    'Тема изменена на ${value.displayName}',
                  );
                  // Обновляем провайдер темы
                  if (mounted) {
                    ref.read(appThemeProvider.notifier).setTheme(value);
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: settings.AppLanguage.values.map((language) {
            return RadioListTile<settings.AppLanguage>(
              title: Text(language.displayName),
              value: language,
              groupValue: _settings?.language,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.of(context).pop();
                  await _updateSetting(
                    () => _settingsService.setLanguage(value),
                    'Язык изменен на ${value.displayName}',
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showMoodGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Цель отслеживания настроения'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            final days = index + 1;
            return RadioListTile<int>(
              title: Text(
                '$days ${days == 1
                    ? 'день'
                    : days < 5
                    ? 'дня'
                    : 'дней'} в неделю',
              ),
              value: days,
              groupValue: _settings?.moodTrackingGoal,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.of(context).pop();
                  await _updateSetting(
                    () => _settingsService.setMoodTrackingGoal(value),
                    'Цель установлена: $value дней в неделю',
                  );
                }
              },
            );
          }),
        ),
      ),
    );
  }

  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime:
          _settings?.reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
    );

    if (time != null) {
      await _updateSetting(
        () => _settingsService.setReminderTime(time),
        'Время напоминания изменено на ${_formatTime(time)}',
      );
    }
  }

  void _exportData() {
    // TODO: Реализовать экспорт данных
    _showSuccessSnackBar('Экспорт данных будет реализован в следующей версии');
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить все данные?'),
        content: const Text(
          'Это действие нельзя отменить. Все ваши записи настроения и настройки будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteAllData();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    try {
      await _levelService.resetLevelData();
      // TODO: Удалить все данные из базы данных
      _showSuccessSnackBar('Все данные удалены');
    } catch (e) {
      _showErrorSnackBar('Ошибка удаления данных');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Помощь и поддержка'),
        content: const Text(
          'Здесь будет раздел помощи с часто задаваемыми вопросами и инструкциями по использованию приложения.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Обратная связь'),
        content: const Text(
          'Спасибо за использование Mind Space! Ваше мнение очень важно для нас. Вы можете отправить отзыв через App Store или Google Play.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    // TODO: Реализовать переход в магазин приложений
    _showSuccessSnackBar('Спасибо за оценку!');
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Политика конфиденциальности'),
        content: const Text(
          'Здесь будет текст политики конфиденциальности, описывающий как мы собираем, используем и защищаем ваши данные.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Условия использования'),
        content: const Text(
          'Здесь будут условия использования приложения, правила и ограничения.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить настройки?'),
        content: const Text(
          'Все настройки будут возвращены к значениям по умолчанию. Ваши данные настроения не будут затронуты.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetSettings();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    try {
      await _settingsService.resetAllSettings();
      await _loadSettings();
      _showSuccessSnackBar('Настройки сброшены');
    } catch (e) {
      _showErrorSnackBar('Ошибка сброса настроек');
    }
  }
}
