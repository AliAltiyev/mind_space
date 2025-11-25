import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/database.dart';
import '../../../app/providers/app_providers.dart';
import '../../../app/providers/ai_features_provider.dart';
import '../../../core/services/user_level_service.dart';

/// Экран добавления записи настроения - Профессиональный дизайн в стиле отслеживания сна
class AddEntryScreenClean extends ConsumerStatefulWidget {
  const AddEntryScreenClean({super.key});

  @override
  ConsumerState<AddEntryScreenClean> createState() =>
      _AddEntryScreenCleanState();
}

class _AddEntryScreenCleanState extends ConsumerState<AddEntryScreenClean>
    with TickerProviderStateMixin {
  final _noteController = TextEditingController();
  int _selectedMood = 2; // По умолчанию "Нормальное" (3)
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  List<String> _getMoodLabels() => [
    'mood.moods.very_sad'.tr(),
    'mood.moods.sad'.tr(),
    'mood.moods.neutral'.tr(),
    'mood.moods.happy'.tr(),
    'mood.moods.very_happy'.tr(),
  ];

  @override
  void initState() {
    super.initState();

    // Анимации для экрана
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // Приветствие
                        _buildWelcomeSection(isDark),

                        const SizedBox(height: 24),

                        // Селектор настроения
                        _buildMoodSelector(isDark),

                        const SizedBox(height: 24),

                        // Поле заметки
                        _buildNoteSection(isDark),

                        const SizedBox(height: 24),

                        // Кнопка сохранения
                        _buildSaveButton(isDark),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Современный AppBar в стиле sleep tracking
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
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _handleBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.xmark,
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
                  'mood.add_mood'.tr(),
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
                  DateFormat('dd MMMM yyyy').format(DateTime.now()),
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
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isLoading ? null : _saveEntry,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: _isLoading
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: _isLoading
                    ? (isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant)
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.check_mark_circled_solid,
                          color: AppColors.textOnPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'common.save'.tr(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Секция приветствия
  Widget _buildWelcomeSection(bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
                : [AppColors.surface, AppColors.surfaceVariant],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.smiley_fill,
                    color: AppColors.textOnPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'mood.title'.tr(),
                        style: AppTypography.h3.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'mood.note_hint'.tr(),
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
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
    );
  }

  /// Селектор настроения
  Widget _buildMoodSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
              : [AppColors.surface, AppColors.surfaceVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.heart_fill,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'mood.select_mood'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final moodValue = index + 1;
              final isSelected = _selectedMood == index;
              return Flexible(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 200 + (index * 100)),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildMoodButton(index, moodValue, isSelected, isDark),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Анимированная метка выбранного настроения
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Center(
              key: ValueKey<int>(_selectedMood),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      getMoodColor(_selectedMood + 1).withOpacity(0.2),
                      getMoodColor(_selectedMood + 1).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: getMoodColor(_selectedMood + 1).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _getMoodLabels()[_selectedMood],
                  style: AppTypography.bodyLarge.copyWith(
                    color: getMoodColor(_selectedMood + 1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Кнопка настроения с анимацией
  Widget _buildMoodButton(
    int index,
    int moodValue,
    bool isSelected,
    bool isDark,
  ) {
    final color = getMoodColor(moodValue);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedMood = index);
        HapticFeedback.selectionClick();
      },
      child: AnimatedBuilder(
        animation: isSelected ? _pulseController : AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _pulseAnimation.value : 1.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final buttonSize = (constraints.maxWidth / 5) - 8;
                final minSize = 50.0;
                final maxSize = 64.0;
                final size = buttonSize.clamp(minSize, maxSize);

                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: isSelected ? getMoodGradient(moodValue) : null,
                    color: isSelected
                        ? null
                        : (isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(size / 2),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : color.withOpacity(0.4),
                      width: isSelected ? 0 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    _getMoodIcon(moodValue),
                    color: isSelected ? AppColors.textOnPrimary : color,
                    size: size * 0.5,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Секция заметки
  Widget _buildNoteSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
              : [AppColors.surface, AppColors.surfaceVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.doc_text,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'mood.note_optional'.tr(),
                style: AppTypography.h4.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _noteController,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'mood.note_placeholder'.tr(),
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textHint,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Кнопка сохранения
  Widget _buildSaveButton(bool isDark) {
    final bool canSave = !_isLoading;

    return GestureDetector(
      onTap: canSave ? _saveEntry : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: canSave
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceVariant),
                    (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceVariant),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSave
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textOnPrimary,
                      ),
                    ),
                  )
                : const Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: AppColors.textOnPrimary,
                    size: 24,
                  ),
            const SizedBox(width: 12),
            Text(
              'mood.add_mood'.tr(),
              style: AppTypography.button.copyWith(
                color: canSave
                    ? AppColors.textOnPrimary
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Сохранение записи
  Future<void> _saveEntry() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final database = ref.read(appDatabaseProvider);

      final entry = MoodEntry(
        moodValue: _selectedMood + 1,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await database.addMoodEntry(entry);

      // Начисляем опыт за запись настроения
      final levelService = UserLevelService();
      await levelService.addExperienceForMoodEntry();

      // Инвалидируем провайдеры для обновления данных
      ref.invalidate(allMoodEntriesProvider);
      ref.invalidate(moodEntriesProvider);
      ref.invalidate(recentMoodEntriesProvider);
      ref.invalidate(lastMoodProvider);

      if (mounted) {
        final moodText = _getMoodLabels()[_selectedMood];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: AppColors.textOnPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text('${'common.success'.tr()}: $moodText')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Возвращаемся назад после небольшой задержки
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _handleBack();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle_fill,
                  color: AppColors.textOnPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'errors.save_error'.tr(namedArgs: {'error': e.toString()}),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Обработка кнопки "Назад"
  void _handleBack() {
    HapticFeedback.lightImpact();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  /// Получить иконку настроения (Cupertino)
  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 5:
        return CupertinoIcons.smiley;
      case 4:
        return CupertinoIcons.smiley;
      case 3:
        return CupertinoIcons.smiley;
      case 2:
        return CupertinoIcons.smiley;
      case 1:
        return CupertinoIcons.smiley;
      default:
        return CupertinoIcons.smiley;
    }
  }
}
