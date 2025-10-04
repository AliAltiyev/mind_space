import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../app/providers/ai_features_provider.dart';

/// Экран списка всех записей настроения - простой и понятный
class EntriesScreenClean extends ConsumerStatefulWidget {
  const EntriesScreenClean({super.key});

  @override
  ConsumerState<EntriesScreenClean> createState() => _EntriesScreenCleanState();
}

class _EntriesScreenCleanState extends ConsumerState<EntriesScreenClean> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';
  

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(allMoodEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Все записи'),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтры
          _buildFilters(),
          
          // Список записей
          Expanded(
            child: entriesAsync.when(
              data: (entries) => _buildEntriesList(entries),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  /// Фильтры
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Все',
              isSelected: _selectedFilter == 'all',
              onTap: () => setState(() => _selectedFilter = 'all'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Отличное',
              isSelected: _selectedFilter == 'excellent',
              onTap: () => setState(() => _selectedFilter = 'excellent'),
              color: AppColors.moodExcellent,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Хорошее',
              isSelected: _selectedFilter == 'good',
              onTap: () => setState(() => _selectedFilter = 'good'),
              color: AppColors.moodGood,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Нормальное',
              isSelected: _selectedFilter == 'okay',
              onTap: () => setState(() => _selectedFilter = 'okay'),
              color: AppColors.moodOkay,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Плохое',
              isSelected: _selectedFilter == 'bad',
              onTap: () => setState(() => _selectedFilter = 'bad'),
              color: AppColors.moodBad,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Ужасное',
              isSelected: _selectedFilter == 'terrible',
              onTap: () => setState(() => _selectedFilter = 'terrible'),
              color: AppColors.moodTerrible,
            ),
          ],
        ),
      ),
    );
  }

  /// Список записей
  Widget _buildEntriesList(List<dynamic> entries) {
    final filteredEntries = _filterEntries(entries);
    
    if (filteredEntries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = filteredEntries[index];
        return _EntryCardClean(
          entry: entry,
          onTap: () => _showEntryDetails(entry),
        );
      },
    );
  }

  /// Фильтрация записей
  List<dynamic> _filterEntries(List<dynamic> entries) {
    if (_selectedFilter == 'all') {
      return entries;
    }

    int moodValue;
    switch (_selectedFilter) {
      case 'excellent':
        moodValue = 5;
        break;
      case 'good':
        moodValue = 4;
        break;
      case 'okay':
        moodValue = 3;
        break;
      case 'bad':
        moodValue = 2;
        break;
      case 'terrible':
        moodValue = 1;
        break;
      default:
        return entries;
    }

    return entries.where((entry) => entry.moodValue == moodValue).toList();
  }

  /// Состояние загрузки
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Состояние ошибки
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки',
            style: AppTypography.h3.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(allMoodEntriesProvider),
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  /// Пустое состояние
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mood_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Записей не найдено',
            style: AppTypography.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all' 
                ? 'Добавьте первую запись настроения'
                : 'Попробуйте другой фильтр',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          if (_selectedFilter == 'all') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/add-entry'),
              child: const Text('Добавить настроение'),
            ),
          ],
        ],
      ),
    );
  }

  /// Диалог поиска
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поиск'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Поиск по заметкам...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement search
            },
            child: const Text('Поиск'),
          ),
        ],
      ),
    );
  }

  /// Показать детали записи
  void _showEntryDetails(dynamic entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getMoodLabel(entry.moodValue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd MMMM yyyy, HH:mm').format(entry.createdAt),
              style: AppTypography.caption,
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Заметка:',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                entry.note!,
                style: AppTypography.bodyMedium,
              ),
            ],
          ],
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

  /// Получить название настроения
  String _getMoodLabel(int mood) {
    switch (mood) {
      case 5:
        return 'Отличное';
      case 4:
        return 'Хорошее';
      case 3:
        return 'Нормальное';
      case 2:
        return 'Плохое';
      case 1:
        return 'Ужасное';
      default:
        return 'Неизвестно';
    }
  }
}

/// Чип фильтра
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (color ?? AppColors.primary)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (color ?? AppColors.primary)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Карточка записи
class _EntryCardClean extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onTap;

  const _EntryCardClean({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final moodValue = entry.moodValue;
    final date = entry.createdAt;
    final note = entry.note;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка настроения
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: getMoodGradient(moodValue),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getMoodIcon(moodValue),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMoodLabel(moodValue),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: getMoodColor(moodValue),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM, HH:mm').format(date),
                      style: AppTypography.caption,
                    ),
                    if (note != null && note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Стрелка
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
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

  /// Получить название настроения
  String _getMoodLabel(int mood) {
    switch (mood) {
      case 5:
        return 'Отличное';
      case 4:
        return 'Хорошее';
      case 3:
        return 'Нормальное';
      case 2:
        return 'Плохое';
      case 1:
        return 'Ужасное';
      default:
        return 'Неизвестно';
    }
  }
}
