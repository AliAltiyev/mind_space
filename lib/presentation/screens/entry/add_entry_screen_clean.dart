import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/database/database.dart';
import '../../../app/providers/app_providers.dart';
import '../../../app/providers/ai_features_provider.dart';
import '../../../core/services/user_level_service.dart';

/// Экран добавления записи настроения - простой и понятный
class AddEntryScreenClean extends ConsumerStatefulWidget {
  const AddEntryScreenClean({super.key});

  @override
  ConsumerState<AddEntryScreenClean> createState() => _AddEntryScreenCleanState();
}

class _AddEntryScreenCleanState extends ConsumerState<AddEntryScreenClean> {
  final _noteController = TextEditingController();
  int _selectedMood = 2; // По умолчанию "Нормальное" (3)
  bool _isLoading = false;

  final List<String> _moodLabels = [
    'Ужасное',
    'Плохое', 
    'Нормальное',
    'Хорошее',
    'Отличное',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Добавить настроение'),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBack(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEntry,
            child: Text(
              'Сохранить',
              style: AppTypography.buttonSecondary.copyWith(
                color: _isLoading ? AppColors.textHint : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            _buildHeader(),
            
            const SizedBox(height: 32),
            
            // Выбор настроения
            _buildMoodSelector(),
            
            const SizedBox(height: 32),
            
            // Заметка
            _buildNoteSection(),
            
            const SizedBox(height: 32),
            
            // Кнопка сохранения
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Заголовок
  Widget _buildHeader() {
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
            'Как вы себя чувствуете?',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите свое текущее настроение и добавьте заметку, если хотите.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Селектор настроения
  Widget _buildMoodSelector() {
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
            'Настроение',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isSelected = _selectedMood == index;
              return _buildMoodButton(index, isSelected);
            }),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _moodLabels[_selectedMood],
              style: AppTypography.bodyLarge.copyWith(
                color: getMoodColor(_selectedMood + 1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Кнопка настроения
  Widget _buildMoodButton(int index, bool isSelected) {
    final moodValue = index + 1;
    final color = getMoodColor(moodValue);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: isSelected ? getMoodGradient(moodValue) : null,
          color: isSelected ? null : AppColors.border,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: color, width: 2),
        ),
        child: Icon(
          _getMoodIcon(moodValue),
          color: isSelected ? Colors.white : color,
          size: 28,
        ),
      ),
    );
  }

  /// Секция заметки
  Widget _buildNoteSection() {
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
            'Заметка (необязательно)',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Опишите, что влияет на ваше настроение...',
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Кнопка сохранения
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.textHint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Сохранить настроение',
                style: AppTypography.button,
              ),
      ),
    );
  }

  /// Сохранение записи
  Future<void> _saveEntry() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final database = ref.read(appDatabaseProvider);
      
      final entry = MoodEntry(
        moodValue: _selectedMood + 1,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Настроение сохранено: ${_moodLabels[_selectedMood]}'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Возвращаемся назад
        _handleBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: AppColors.error,
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
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  /// Получить иконку настроения
  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 5:
        return Icons.sentiment_very_satisfied;
      case 4:
        return Icons.sentiment_satisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 1:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
