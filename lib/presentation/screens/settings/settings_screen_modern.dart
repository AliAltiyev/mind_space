import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/app_settings_service.dart' as settings;
import '../../../core/services/user_level_service.dart';
import '../../../app/providers/theme_provider.dart';
import '../../../main.dart';

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
            ? AppColors.darkBackground
            : AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
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
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: isDark ? AppColors.darkSurface : AppColors.surface,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      leading: IconButton(
        icon: Icon(CupertinoIcons.chevron_left, color: AppColors.textPrimary),
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
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalSettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: CupertinoIcons.person,
            title: 'settings.profile'.tr(),
            subtitle: 'settings.profile_management'.tr(),
            onTap: () => context.go('/profile'),
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.globe,
            title: 'settings.language'.tr(),
            subtitle: _getLanguageName(
              context,
              _settings?.language ?? settings.AppLanguage.russian,
            ),
            onTap: _showLanguageDialog,
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.smiley,
            title: 'settings.mood_tracking_goal'.tr(),
            subtitle:
                '${_settings?.moodTrackingGoal ?? 7} ${'settings.days_per_week'.tr()}',
            onTap: _showMoodGoalDialog,
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(BuildContext context, settings.AppLanguage language) {
    switch (language.code) {
      case 'ru':
        return 'settings.languages.russian'.tr();
      case 'en':
        return 'settings.languages.english'.tr();
      default:
        return language.code;
    }
  }

  Widget _buildAppearanceSettings() {
    final themeName = _getThemeName(
      context,
      _settings?.theme ?? settings.AppTheme.system,
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: CupertinoIcons.paintbrush,
            title: 'settings.theme'.tr(),
            subtitle: themeName,
            onTap: _showThemeDialog,
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: CupertinoIcons.speaker_2,
            title: 'settings.sounds'.tr(),
            subtitle: 'settings.sound_effects'.tr(),
            value: _settings?.soundEnabled ?? true,
            onChanged: (value) {
              final enabledText = value
                  ? 'settings.enabled'.tr()
                  : 'settings.disabled'.tr();
              _updateSetting(
                () => _settingsService.setSoundEnabled(value),
                '${'settings.sounds'.tr()} $enabledText',
              );
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: CupertinoIcons.waveform,
            title: 'settings.haptic_feedback'.tr(),
            subtitle: 'settings.haptic_feedback_desc'.tr(),
            value: _settings?.hapticFeedbackEnabled ?? true,
            onChanged: (value) => _updateSetting(
              () => _settingsService.setHapticFeedbackEnabled(value),
              '${'settings.haptic_feedback'.tr()} ${value ? 'settings.enabled_single'.tr() : 'settings.disabled_single'.tr()}',
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(BuildContext context, settings.AppTheme theme) {
    switch (theme) {
      case settings.AppTheme.light:
        return 'settings.themes.light'.tr();
      case settings.AppTheme.dark:
        return 'settings.themes.dark'.tr();
      case settings.AppTheme.system:
        return 'settings.themes.system'.tr();
    }
  }

  Widget _buildNotificationSettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: CupertinoIcons.bell,
            title: 'settings.notifications'.tr(),
            subtitle: 'settings.notifications_desc'.tr(),
            value: _settings?.notificationsEnabled ?? true,
            onChanged: (value) => _updateSetting(
              () => _settingsService.setNotificationsEnabled(value),
              '${'settings.notifications'.tr()} ${value ? 'settings.enabled'.tr() : 'settings.disabled'.tr()}',
            ),
          ),
          if (_settings?.notificationsEnabled == true) ...[
            _buildDivider(),
            _buildSwitchTile(
              icon: CupertinoIcons.clock,
              title: 'settings.daily_reminders'.tr(),
              subtitle: 'settings.daily_reminders_desc'.tr(),
              value: _settings?.dailyReminderEnabled ?? true,
              onChanged: (value) => _updateSetting(
                () => _settingsService.setDailyReminderEnabled(value),
                '${'settings.daily_reminders'.tr()} ${value ? 'settings.enabled'.tr() : 'settings.disabled'.tr()}',
              ),
            ),
            if (_settings?.dailyReminderEnabled == true) ...[
              _buildDivider(),
              _buildSettingTile(
                icon: CupertinoIcons.time,
                title: 'settings.reminder_time'.tr(),
                subtitle: _formatTime(
                  _settings?.reminderTime ??
                      const TimeOfDay(hour: 20, minute: 0),
                ),
                onTap: _showTimePicker,
                trailing: const Icon(CupertinoIcons.chevron_right),
              ),
            ],
            _buildDivider(),
            _buildSwitchTile(
              icon: CupertinoIcons.chart_bar,
              title: 'settings.weekly_reports'.tr(),
              subtitle: 'settings.weekly_reports_desc'.tr(),
              value: _settings?.weeklyReportEnabled ?? true,
              onChanged: (value) => _updateSetting(
                () => _settingsService.setWeeklyReportEnabled(value),
                '${'settings.weekly_reports'.tr()} ${value ? 'settings.enabled'.tr() : 'settings.disabled'.tr()}',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.analytics_outlined,
            title: 'settings.analytics'.tr(),
            subtitle: 'settings.analytics_desc'.tr(),
            value: _settings?.analyticsEnabled ?? true,
            onChanged: (value) => _updateSetting(
              () => _settingsService.setAnalyticsEnabled(value),
              '${'settings.analytics'.tr()} ${value ? 'settings.enabled_single'.tr() : 'settings.disabled_single'.tr()}',
            ),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: CupertinoIcons.cloud,
            title: 'settings.export_data'.tr(),
            subtitle: 'settings.export_data_desc'.tr(),
            value: _settings?.dataExportEnabled ?? true,
            onChanged: (value) => _updateSetting(
              () => _settingsService.setDataExportEnabled(value),
              '${'settings.export_data'.tr()} ${value ? 'settings.enabled_export'.tr() : 'settings.disabled_export'.tr()}',
            ),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.arrow_down_circle,
            title: 'settings.download_data'.tr(),
            subtitle: 'settings.download_data'.tr(),
            onTap: _exportData,
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.delete,
            title: 'settings.delete_all_data'.tr(),
            subtitle: 'settings.delete_all_data_desc'.tr(),
            onTap: _showDeleteDataDialog,
            trailing: const Icon(CupertinoIcons.chevron_right),
            textColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: CupertinoIcons.question_circle,
            title: 'settings.help_support'.tr(),
            subtitle: 'settings.help_support_desc'.tr(),
            onTap: () => _showHelpDialog(),
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.chat_bubble,
            title: 'settings.feedback'.tr(),
            subtitle: 'settings.feedback_desc'.tr(),
            onTap: () => _showFeedbackDialog(),
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.star,
            title: 'settings.rate_app'.tr(),
            subtitle: 'settings.rate_app_desc'.tr(),
            onTap: _rateApp,
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: CupertinoIcons.info,
            title: 'settings.app_version'.tr(),
            subtitle: '1.0.0',
            onTap: null,
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.lock,
            title: 'settings.privacy_policy'.tr(),
            subtitle: 'settings.privacy_policy_desc'.tr(),
            onTap: () => _showPrivacyPolicy(),
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.doc_text,
            title: 'settings.terms_of_service'.tr(),
            subtitle: 'settings.terms_of_service_desc'.tr(),
            onTap: () => _showTermsOfService(),
            trailing: const Icon(CupertinoIcons.chevron_right),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: CupertinoIcons.arrow_clockwise,
            title: 'settings.reset_settings'.tr(),
            subtitle: 'settings.reset_settings_desc'.tr(),
            onTap: _showResetSettingsDialog,
            trailing: const Icon(CupertinoIcons.chevron_right),
            textColor: AppColors.warning,
          ),
        ],
      ),
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
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.border, indent: 56);
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
      _showErrorSnackBar('settings.settings_update_error'.tr());
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.select_theme'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: settings.AppTheme.values.map((theme) {
            return RadioListTile<settings.AppTheme>(
              title: Text(_getThemeName(context, theme)),
              value: theme,
              groupValue: _settings?.theme,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.of(context).pop();
                  final themeName = _getThemeName(context, value);
                  await _updateSetting(
                    () => _settingsService.setTheme(value),
                    'settings.theme_changed'.tr(
                      namedArgs: {'theme': themeName},
                    ),
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
              title: Text(_getLanguageName(context, language)),
              value: language,
              groupValue: _settings?.language,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.of(context).pop();
                  final langName = _getLanguageName(context, value);

                  // Сохраняем язык
                  await _settingsService.setLanguage(value);

                  // Обновляем локаль в EasyLocalization
                  final newLocale = Locale(value.code);
                  if (context.mounted) {
                    context.setLocale(newLocale);
                  }

                  // Инвалидируем провайдер для обновления локали в main.dart
                  ref.invalidate(savedLocaleProvider);

                  // Показываем сообщение об успехе
                  if (mounted) {
                    _showSuccessSnackBar(
                      'settings.language_changed'.tr(
                        namedArgs: {'language': langName},
                      ),
                    );
                  }

                  // Перезагружаем настройки
                  await _loadSettings();
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
        title: Text('settings.mood_tracking_goal_dialog'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            final days = index + 1;
            final dayText = days == 1
                ? 'settings.day'.tr()
                : days < 5
                ? 'settings.days'.tr()
                : 'settings.days_many'.tr();
            return RadioListTile<int>(
              title: Text('$days $dayText ${'settings.days_per_week'.tr()}'),
              value: days,
              groupValue: _settings?.moodTrackingGoal,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.of(context).pop();
                  await _updateSetting(
                    () => _settingsService.setMoodTrackingGoal(value),
                    'settings.goal_set'.tr(
                      namedArgs: {'goal': value.toString()},
                    ),
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
        'settings.reminder_time_updated'.tr(
          namedArgs: {'time': _formatTime(time)},
        ),
      );
    }
  }

  void _exportData() {
    // TODO: Реализовать экспорт данных
    _showSuccessSnackBar('settings.export_data_message'.tr());
  }

  void _showDeleteDataDialog() {
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
              await _deleteAllData();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    try {
      await _levelService.resetLevelData();
      // TODO: Удалить все данные из базы данных
      _showSuccessSnackBar('settings.all_data_deleted'.tr());
    } catch (e) {
      _showErrorSnackBar('settings.delete_data_error'.tr());
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.help_support'.tr()),
        content: Text('settings.help_support_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.feedback_dialog'.tr()),
        content: Text('settings.feedback_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    // TODO: Реализовать переход в магазин приложений
    _showSuccessSnackBar('settings.thank_you_rating'.tr());
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.privacy_policy'.tr()),
        content: Text('settings.privacy_policy_content'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.terms_of_service'.tr()),
        content: Text('settings.terms_of_service_content'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings.reset_settings_dialog_title'.tr()),
        content: Text('settings.reset_settings_warning'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetSettings();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: Text('common.reset'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    try {
      await _settingsService.resetAllSettings();
      await _loadSettings();
      _showSuccessSnackBar('settings.settings_reset_success'.tr());
    } catch (e) {
      _showErrorSnackBar('settings.settings_reset_error'.tr());
    }
  }
}
