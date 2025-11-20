import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../app/providers/app_providers.dart';
import '../../domain/entities/sleep_entry.dart';
import '../../services/sleep_reminder_service.dart';
import '../widgets/sleep_background.dart';
import '../widgets/sleep_card.dart';

/// Экран отслеживания сна
class SleepTrackingPage extends ConsumerStatefulWidget {
  const SleepTrackingPage({super.key});

  @override
  ConsumerState<SleepTrackingPage> createState() => _SleepTrackingPageState();
}

class _SleepTrackingPageState extends ConsumerState<SleepTrackingPage> {
  DateTime? _sleepStart;
  DateTime? _sleepEnd;
  int _quality = 3;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedFactors = [];
  int _refreshKey = 0; // Ключ для обновления FutureBuilder

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveSleepEntry() async {
    if (_sleepStart == null || _sleepEnd == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('sleep.enter_sleep_times'.tr())));
      return;
    }

    if (_sleepEnd!.isBefore(_sleepStart!)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('sleep.invalid_times'.tr())));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('sleep.entry_saved'.tr())));
      _resetForm();
      // Обновляем ключ для перестроения FutureBuilder
      setState(() {
        _refreshKey++;
      });
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

  Future<void> _selectSleepStart() async {
    final now = DateTime.now();
    final initialTime = _sleepStart ?? now.subtract(const Duration(hours: 8));
    DateTime selectedTime = initialTime;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B)
                : CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        'common.cancel'.tr(),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.8)
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text(
                        'common.done'.tr(),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.8)
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                      onPressed: () {
                        final date = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        setState(() {
                          _sleepStart = date.isAfter(now)
                              ? date.subtract(const Duration(days: 1))
                              : date;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: initialTime,
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newTime) {
                      selectedTime = newTime;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectSleepEnd() async {
    final now = DateTime.now();
    final initialTime = _sleepEnd ?? now;
    DateTime selectedTime = initialTime;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B)
                : CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        'common.cancel'.tr(),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.8)
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text(
                        'common.done'.tr(),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.8)
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                      onPressed: () {
                        final date = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        setState(() {
                          _sleepEnd = date;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: initialTime,
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newTime) {
                      selectedTime = newTime;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'sleep.title'.tr(),
          style: AppTypography.h3.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      body: SleepBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Карточка с информацией о последнем сне
                _buildLastSleepCard(context, theme, colorScheme, isDark),

                const SizedBox(height: 24),

                // Форма добавления записи сна
                _buildSleepForm(context, theme, colorScheme, isDark),

                const SizedBox(height: 24),

                // Кнопка сохранения с градиентом
                _buildSaveButton(context, theme, colorScheme, isDark),

                const SizedBox(height: 16),

                // Кнопка статистики
                _buildStatsButton(context, theme, colorScheme, isDark),

                const SizedBox(height: 16),

                // Настройки напоминаний
                _buildReminderSettings(context, theme, colorScheme, isDark),

                // Тестовая кнопка (только в debug режиме)
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  _buildTestReminderButton(context, theme, colorScheme, isDark),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLastSleepCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // Используем ключ для принудительного обновления FutureBuilder
    final database = ref.read(appDatabaseProvider);
    return FutureBuilder<Map<String, dynamic>?>(
      key: ValueKey<int>(_refreshKey), // Ключ для обновления
      future: database.getLastSleepEntry(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SleepCard(
            child: Column(
              children: [
                Icon(
                  Icons.bedtime_outlined,
                  size: 56,
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(height: 20),
                Text(
                  'sleep.no_entries'.tr(),
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
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

        return SleepCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sleep.last_sleep'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SleepStatCard(
                      value: '$hoursч $minutesм',
                      label: 'sleep.duration'.tr(),
                      icon: Icons.access_time,
                      color: isDark
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SleepStatCard(
                      value: quality.toString(),
                      label: 'sleep.quality'.tr(),
                      icon: Icons.star_rounded,
                      color: isDark
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF6366F1) : const Color(0xFF475569),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF475569))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveSleepEntry,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'sleep.save_entry'.tr(),
                  style: AppTypography.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return SleepCard(
      onTap: () => context.push('/sleep/stats'),
      child: Row(
        children: [
          Icon(
            Icons.insights_outlined,
            color: isDark
                ? Colors.white.withOpacity(0.8)
                : const Color(0xFF475569),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'sleep.view_stats'.tr(),
              style: AppTypography.bodyLarge.copyWith(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: isDark
                ? Colors.white.withOpacity(0.5)
                : const Color(0xFF94A3B8),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSleepForm(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return SleepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'sleep.add_entry'.tr(),
            style: AppTypography.h4.copyWith(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),

          // Время засыпания
          _buildTimePicker(
            context,
            'sleep.sleep_start'.tr(),
            _sleepStart,
            _selectSleepStart,
            Icons.bedtime_outlined,
            colorScheme,
            isDark,
          ),

          const SizedBox(height: 16),

          // Время пробуждения
          _buildTimePicker(
            context,
            'sleep.sleep_end'.tr(),
            _sleepEnd,
            _selectSleepEnd,
            Icons.wb_sunny_outlined,
            colorScheme,
            isDark,
          ),

          const SizedBox(height: 20),

          // Качество сна
          Text(
            'sleep.quality'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final value = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _quality = value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _quality >= value
                        ? (isDark
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF475569))
                        : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _quality >= value
                          ? (isDark
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF475569))
                          : (isDark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.black.withOpacity(0.1)),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: _quality >= value
                        ? Colors.white
                        : (isDark
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black.withOpacity(0.3)),
                    size: 24,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Факторы
          Text(
            'sleep.factors'.tr(),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SleepFactor.values.map((factor) {
              final isSelected = _selectedFactors.contains(factor.name);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: FilterChip(
                  label: Text(
                    factor.label,
                    style: TextStyle(
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.white)
                          : (isDark
                                ? Colors.white.withOpacity(0.7)
                                : const Color(0xFF475569)),
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFactors.add(factor.name);
                      } else {
                        _selectedFactors.remove(factor.name);
                      }
                    });
                  },
                  selectedColor: isDark
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF475569),
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.03),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? (isDark
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF475569))
                        : (isDark
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.1)),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Заметки
          TextField(
            controller: _noteController,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              labelText: 'sleep.notes'.tr(),
              labelStyle: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF64748B),
              ),
              hintText: 'sleep.notes_hint'.tr(),
              hintStyle: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.4)
                    : const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF475569),
                  width: 1.5,
                ),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    DateTime? time,
    VoidCallback onTap,
    IconData icon,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final accentColor = isDark
        ? const Color(0xFF6366F1)
        : const Color(0xFF475569);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: time != null
                  ? accentColor
                  : (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.08)),
              width: time != null ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: time != null
                    ? accentColor
                    : (isDark
                          ? Colors.white.withOpacity(0.5)
                          : const Color(0xFF94A3B8)),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time != null
                          ? DateFormat('HH:mm').format(time)
                          : 'sleep.select_time'.tr(),
                      style: AppTypography.bodyLarge.copyWith(
                        color: time != null
                            ? (isDark ? Colors.white : const Color(0xFF1E293B))
                            : (isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : const Color(0xFF94A3B8)),
                        fontWeight: time != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.access_time_rounded,
                color: time != null
                    ? accentColor
                    : (isDark
                          ? Colors.white.withOpacity(0.4)
                          : const Color(0xFF94A3B8)),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSettings(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return FutureBuilder<bool>(
      future: SleepReminderService().isReminderScheduled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;
        return SleepCard(
          child: Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: isDark
                    ? Colors.white.withOpacity(0.8)
                    : const Color(0xFF475569),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sleep.reminder.settings'.tr(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled
                          ? 'sleep.reminder.enabled'.tr()
                          : 'sleep.reminder.disabled'.tr(),
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                activeThumbColor: isDark
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF475569),
                activeTrackColor:
                    (isDark ? const Color(0xFF6366F1) : const Color(0xFF475569))
                        .withOpacity(0.3),
                inactiveThumbColor: isDark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                inactiveTrackColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                onChanged: (value) async {
                  final service = SleepReminderService();
                  await service.initialize();
                  if (value) {
                    // Показываем диалог выбора времени
                    DateTime selectedDateTime = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      21,
                      0,
                    );
                    TimeOfDay? selectedTime;

                    await showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => Container(
                        height: 216,
                        padding: const EdgeInsets.only(top: 6.0),
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground.resolveFrom(
                            context,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CupertinoButton(
                                    child: Text('common.cancel'.tr()),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  CupertinoButton(
                                    child: Text('common.done'.tr()),
                                    onPressed: () {
                                      selectedTime = TimeOfDay.fromDateTime(
                                        selectedDateTime,
                                      );
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                              Expanded(
                                child: CupertinoDatePicker(
                                  initialDateTime: selectedDateTime,
                                  mode: CupertinoDatePickerMode.time,
                                  use24hFormat: true,
                                  onDateTimeChanged: (DateTime newTime) {
                                    selectedDateTime = newTime;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    if (selectedTime == null) {
                      // Пользователь отменил выбор времени
                      setState(() {});
                      return;
                    }

                    final time = selectedTime!;
                    try {
                      final hasExactPermission = await service
                          .scheduleSleepReminder(time: time);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'sleep.reminder.scheduled_at'.tr(
                                namedArgs: {
                                  'hour': time.hour.toString().padLeft(2, '0'),
                                  'minute': time.minute.toString().padLeft(
                                    2,
                                    '0',
                                  ),
                                },
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      if (!hasExactPermission && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'sleep.reminder.permission_required'.tr(),
                            ),
                            action: SnackBarAction(
                              label: 'sleep.reminder.open_settings'.tr(),
                              onPressed: () {
                                service.openExactAlarmSettings();
                              },
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Ошибка установки напоминания: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('sleep.reminder.error'.tr()),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'sleep.reminder.open_settings'.tr(),
                              onPressed: () {
                                service.openExactAlarmSettings();
                              },
                            ),
                          ),
                        );
                      }
                      // Отключаем переключатель при ошибке
                      setState(() {});
                      return;
                    }
                  } else {
                    await service.cancelSleepReminder();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('sleep.reminder.cancelled'.tr()),
                        ),
                      );
                    }
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestReminderButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'sleep.reminder.debug_title'.tr(),
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'sleep.reminder.debug_description'.tr(),
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? Colors.white70
                  : colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final service = SleepReminderService();
                    await service.initialize();
                    try {
                      await service.scheduleTestReminder(secondsFromNow: 10);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('sleep.reminder.test_success'.tr()),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'sleep.reminder.test_error'.tr(
                                namedArgs: {'error': e.toString()},
                              ),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.notifications_active, size: 18),
                  label: Text('sleep.reminder.test_button'.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final service = SleepReminderService();
                    await service.cancelTestReminder();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('sleep.reminder.test_cancelled'.tr()),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text('sleep.reminder.test_cancel_button'.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
