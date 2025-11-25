import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/providers/app_providers.dart';
import '../../domain/entities/sleep_entry.dart' show SleepEntry, SleepFactor;
import '../../services/sleep_reminder_service.dart';
import '../../../../core/services/app_settings_service.dart';

/// Экран отслеживания сна - Профессиональный дизайн
class SleepTrackingPage extends ConsumerStatefulWidget {
  const SleepTrackingPage({super.key});

  @override
  ConsumerState<SleepTrackingPage> createState() => _SleepTrackingPageState();
}

class _SleepTrackingPageState extends ConsumerState<SleepTrackingPage>
    with TickerProviderStateMixin {
  DateTime? _sleepStart;
  DateTime? _sleepEnd;
  int _quality = 3;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedFactors = [];

  final SleepReminderService _reminderService = SleepReminderService();
  final AppSettingsService _settingsService = AppSettingsService();
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 22, minute: 0);

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final enabled = await _settingsService.isDailyReminderEnabled();
    final time = await _settingsService.getReminderTime();

    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderTime = time;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveSleepEntry() async {
    if (_sleepStart == null || _sleepEnd == null) {
      _showErrorSnackBar('sleep.enter_sleep_times'.tr());
      return;
    }

    if (_sleepEnd!.isBefore(_sleepStart!)) {
      _showErrorSnackBar('sleep.invalid_times'.tr());
      return;
    }

    final database = ref.read(appDatabaseProvider);
    final entry = SleepEntry.create(
      sleepStart: _sleepStart!,
      sleepEnd: _sleepEnd!,
      quality: _quality,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      factors: _selectedFactors,
    );

    await database.addSleepEntry(entry.toMap());

    if (mounted) {
      _showSuccessSnackBar('sleep.entry_saved'.tr());
      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _sleepStart = null;
      _sleepEnd = null;
      _quality = 3;
      _noteController.clear();
      _selectedFactors.clear();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectSleepStart() async {
    final now = DateTime.now();
    final initialTime = _sleepStart ?? now.subtract(const Duration(hours: 8));

    await _showTimePicker(
      context: context,
      initialTime: initialTime,
      onTimeSelected: (time) {
        final date = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _sleepStart = date.isAfter(now)
              ? date.subtract(const Duration(days: 1))
              : date;
        });
      },
    );
  }

  Future<void> _selectSleepEnd() async {
    final now = DateTime.now();
    final initialTime = _sleepEnd ?? now;

    await _showTimePicker(
      context: context,
      initialTime: initialTime,
      onTimeSelected: (time) {
        final date = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _sleepEnd = date;
        });
      },
    );
  }

  Future<void> _showTimePicker({
    required BuildContext context,
    required DateTime initialTime,
    required Function(DateTime) onTimeSelected,
  }) async {
    DateTime selectedTime = initialTime;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'common.cancel'.tr(),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onTimeSelected(selectedTime);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'common.done'.tr(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: initialTime,
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                onDateTimeChanged: (time) => selectedTime = time,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // Карточка последнего сна
                      _buildLastSleepCard(isDark),

                      const SizedBox(height: 24),

                      // Круговая визуализация времени сна
                      _buildSleepVisualization(isDark),

                      const SizedBox(height: 32),

                      // Форма ввода
                      _buildInputForm(isDark),

                      const SizedBox(height: 24),

                      // Кнопка сохранения
                      _buildSaveButton(isDark),

                      const SizedBox(height: 16),

                      // Быстрые действия
                      _buildQuickActions(isDark),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.arrow_left,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sleep.title'.tr(),
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
                  DateFormat('EEEE, d MMMM', 'ru').format(DateTime.now()),
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/sleep/stats'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.chart_bar_fill,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepVisualization(bool isDark) {
    final hasData = _sleepStart != null && _sleepEnd != null;
    final duration = hasData
        ? _sleepEnd!.difference(_sleepStart!)
        : const Duration(hours: 8);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Фоновый круг
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Круг прогресса
          ScaleTransition(
            scale: _pulseAnimation,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _SleepProgressPainter(
                progress: hasData
                    ? (duration.inMinutes / 480).clamp(0.0, 1.0)
                    : 0.0,
                isDark: isDark,
              ),
            ),
          ),

          // Центральный контент
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasData ? '$hoursч $minutesм' : '--:--',
                style: AppTypography.h1.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'sleep.duration'.tr(),
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'sleep.add_entry'.tr(),
            style: AppTypography.h4.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),

        // Время засыпания и пробуждения
        Row(
          children: [
            Expanded(
              child: _buildTimeCard(
                label: 'sleep.sleep_start'.tr(),
                time: _sleepStart,
                icon: CupertinoIcons.moon_fill,
                onTap: _selectSleepStart,
                isDark: isDark,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeCard(
                label: 'sleep.sleep_end'.tr(),
                time: _sleepEnd,
                icon: CupertinoIcons.sun_max_fill,
                onTap: _selectSleepEnd,
                isDark: isDark,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Качество сна
        _buildQualitySelector(isDark),

        const SizedBox(height: 20),

        // Факторы
        if (SleepFactor.values.isNotEmpty) _buildFactorsSelector(isDark),

        const SizedBox(height: 20),

        // Заметки
        _buildNotesField(isDark),
      ],
    );
  }

  Widget _buildTimeCard({
    required String label,
    required DateTime? time,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: time != null
                ? color.withOpacity(0.3)
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: time != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: time != null
                  ? color.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time != null
                  ? DateFormat('HH:mm').format(time)
                  : 'sleep.select_time'.tr(),
              style: AppTypography.h3.copyWith(
                color: time != null
                    ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sleep.quality'.tr(),
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = _quality >= value;
            return GestureDetector(
              onTap: () => setState(() => _quality = value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.surfaceVariant),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkBorder : AppColors.border),
                    width: isSelected ? 0 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  CupertinoIcons.star_fill,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  size: 24,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFactorsSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sleep.factors'.tr(),
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: SleepFactor.values.map((factor) {
            final isSelected = _selectedFactors.contains(factor.name);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFactors.remove(factor.name);
                  } else {
                    _selectedFactors.add(factor.name);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.surfaceVariant),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkBorder : AppColors.border),
                    width: isSelected ? 0 : 1,
                  ),
                ),
                child: Text(
                  factor.label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sleep.notes'.tr(),
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: TextField(
            controller: _noteController,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'sleep.notes_hint'.tr(),
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    final isEnabled = _sleepStart != null && _sleepEnd != null;

    return GestureDetector(
      onTap: isEnabled ? _saveSleepEntry : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled
              ? null
              : (isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: isEnabled
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'sleep.save_entry'.tr(),
                style: AppTypography.button.copyWith(
                  color: isEnabled
                      ? Colors.white
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: CupertinoIcons.chart_bar_fill,
            title: 'sleep.view_stats'.tr(),
            onTap: () => context.push('/sleep/stats'),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: CupertinoIcons.bell,
            title: 'sleep.reminder.settings'.tr(),
            onTap: () => _showReminderSettings(isDark),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReminderSettings(bool isDark) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ReminderSettingsSheet(
        isDark: isDark,
        reminderEnabled: _reminderEnabled,
        reminderTime: _reminderTime,
        onEnabledChanged: (enabled) async {
          setState(() => _reminderEnabled = enabled);
          await _settingsService.setDailyReminderEnabled(enabled);
          if (enabled) {
            try {
              await _reminderService.scheduleSleepReminder(
                time: _reminderTime,
                enabled: true,
              );
              // Проверяем, что напоминание действительно установлено
              final isScheduled = await _reminderService.isReminderScheduled();
              if (mounted) {
                if (isScheduled) {
                  _showSuccessSnackBar('sleep.reminder.enabled'.tr());
                } else {
                  _showErrorSnackBar('sleep.reminder.error'.tr());
                }
              }
            } catch (e) {
              if (mounted) {
                _showErrorSnackBar('sleep.reminder.error'.tr());
              }
            }
          } else {
            await _reminderService.cancelSleepReminder();
            if (mounted) {
              _showSuccessSnackBar('sleep.reminder.disabled'.tr());
            }
          }
        },
        onTimeChanged: (time) async {
          setState(() => _reminderTime = time);
          await _settingsService.setReminderTime(time);
          if (_reminderEnabled) {
            await _reminderService.scheduleSleepReminder(
              time: time,
              enabled: true,
            );
            if (mounted) {
              _showSuccessSnackBar(
                'sleep.reminder.scheduled_at'.tr(
                  args: [
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  ],
                ),
              );
            }
          }
        },
        onTestReminder: () async {
          try {
            // Отправляем немедленное уведомление для теста
            await _reminderService.scheduleTestReminder(secondsFromNow: 0);
            if (mounted) {
              _showSuccessSnackBar('sleep.reminder.test_success'.tr());
            }
          } catch (e) {
            if (mounted) {
              final errorMessage = e.toString().contains('permission')
                  ? 'sleep.reminder.permission_required'.tr()
                  : 'sleep.reminder.test_error'.tr(args: [e.toString()]);
              _showErrorSnackBar(errorMessage);
            }
          }
        },
      ),
    );
  }

  Widget _buildLastSleepCard(bool isDark) {
    final database = ref.read(appDatabaseProvider);

    return FutureBuilder<Map<String, dynamic>?>(
      future: database.getLastSleepEntry(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.bed_double,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'sleep.no_entries'.tr(),
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sleep.stats.no_data_description'.tr(),
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
          );
        }

        final entry = snapshot.data!;
        final sleepStart = DateTime.parse(entry['sleepStart']);
        final sleepEnd = DateTime.parse(entry['sleepEnd']);
        final duration = sleepEnd.difference(sleepStart);
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        final quality = entry['quality'] ?? 3;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primaryLight.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.bed_double_fill,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sleep.last_sleep'.tr(),
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '$hoursч $minutesм',
                          style: AppTypography.h3.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.star_fill,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                quality.toString(),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Кастомный painter для круга прогресса сна
class _SleepProgressPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SleepProgressPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Фоновый круг
    final backgroundPaint = Paint()
      ..color = isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Прогресс
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Виджет настроек напоминания о сне
class _ReminderSettingsSheet extends StatefulWidget {
  final bool isDark;
  final bool reminderEnabled;
  final TimeOfDay reminderTime;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final VoidCallback onTestReminder;

  const _ReminderSettingsSheet({
    required this.isDark,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.onEnabledChanged,
    required this.onTimeChanged,
    required this.onTestReminder,
  });

  @override
  State<_ReminderSettingsSheet> createState() => _ReminderSettingsSheetState();
}

class _ReminderSettingsSheetState extends State<_ReminderSettingsSheet> {
  late bool _enabled;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _enabled = widget.reminderEnabled;
    _time = widget.reminderTime;
  }

  Future<void> _selectTime() async {
    DateTime selectedTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _time.hour,
      _time.minute,
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'common.cancel'.tr(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: widget.isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      final picked = TimeOfDay(
                        hour: selectedTime.hour,
                        minute: selectedTime.minute,
                      );
                      if (picked != _time) {
                        setState(() => _time = picked);
                        widget.onTimeChanged(picked);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'common.done'.tr(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: selectedTime,
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                onDateTimeChanged: (time) => selectedTime = time,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Заголовок
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.bell,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'sleep.reminder.settings'.tr(),
                          style: AppTypography.h4.copyWith(
                            color: widget.isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Переключатель включения/выключения
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'sleep.reminder.enabled'.tr(),
                                style: AppTypography.bodyLarge.copyWith(
                                  color: widget.isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _enabled
                                    ? 'sleep.reminder.scheduled_at'.tr(
                                        args: [
                                          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                                        ],
                                      )
                                    : 'sleep.reminder.disabled'.tr(),
                                style: AppTypography.caption.copyWith(
                                  color: widget.isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: _enabled,
                          onChanged: (value) {
                            setState(() => _enabled = value);
                            widget.onEnabledChanged(value);
                          },
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  if (_enabled) ...[
                    const SizedBox(height: 16),

                    // Выбор времени
                    GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'sleep.reminder.time'.tr(),
                                    style: AppTypography.caption.copyWith(
                                      color: widget.isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                                    style: AppTypography.h3.copyWith(
                                      color: widget.isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_right,
                              color: widget.isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Кнопка тестового напоминания
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onTestReminder,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.bell_fill,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'sleep.reminder.test_button'.tr(),
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
