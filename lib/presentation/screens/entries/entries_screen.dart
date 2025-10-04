import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../../../app/providers/ai_features_provider.dart';
import '../../../core/database/database.dart';
import '../../widgets/core/amazing_background.dart' as amazing;
import '../../widgets/core/amazing_glass_surface.dart' as amazing;

/// Экран со списком всех записей настроения
class EntriesScreen extends ConsumerStatefulWidget {
  const EntriesScreen({super.key});

  @override
  ConsumerState<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends ConsumerState<EntriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedMoodFilter;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodEntriesAsync = ref.watch(allMoodEntriesProvider);
    
    return moodEntriesAsync.when(
      data: (moodEntries) {
        final filteredEntries = _getFilteredEntries(moodEntries);
        return _buildContent(context, filteredEntries);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildContent(BuildContext context, List<Map<String, dynamic>> filteredEntries) {

    return amazing.AmazingBackground(
      type: amazing.BackgroundType.cosmic,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'entries.title'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 10)],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // Поиск
            Padding(
              padding: const EdgeInsets.all(16),
              child: amazing.AmazingGlassSurface(
                effectType: amazing.GlassEffectType.neon,
                colorScheme: amazing.ColorScheme.neon,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'entries.search_entries'.tr(),
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFB9E3A)),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ),

            // Активные фильтры
            if (_hasActiveFilters())
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (_selectedMoodFilter != null)
                      _FilterChip(
                        label: 'Mood: ${_moodLabel(_selectedMoodFilter!)}',
                        onDeleted: () => setState(() => _selectedMoodFilter = null),
                      ),
                    if (_selectedDateRange != null)
                      _FilterChip(
                        label: 'Date Range',
                        onDeleted: () => setState(() => _selectedDateRange = null),
                      ),
                  ],
                ),
              ),

            // Список записей
            Expanded(
              child: filteredEntries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        return _EntryCard(
                          entry: entry,
                          onTap: () => _showEntryDetails(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredEntries(List<MoodEntry> moodEntries) {
    // Конвертируем MoodEntry в Map для совместимости с существующим кодом
    final entries = moodEntries.map((entry) => {
      'id': entry.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'mood': entry.moodValue,
      'note': entry.note ?? '',
      'date': entry.createdAt,
      'tags': [], // TODO: Добавить теги в модель MoodEntry
    }).toList();
    
    var filtered = List<Map<String, dynamic>>.from(entries);

    // Поиск
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((entry) {
        return entry['note'].toString().toLowerCase().contains(searchQuery) ||
            entry['tags'].toString().toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Фильтр по настроению
    if (_selectedMoodFilter != null) {
      filtered = filtered.where((entry) => entry['mood'] == _selectedMoodFilter).toList();
    }

    // Фильтр по дате
    if (_selectedDateRange != null) {
      filtered = filtered.where((entry) {
        final entryDate = entry['date'] as DateTime;
        return entryDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            entryDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Сортировка по дате (новые сверху)
    filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return filtered;
  }

  bool _hasActiveFilters() {
    return _selectedMoodFilter != null || _selectedDateRange != null;
  }

  String _moodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'entries.very_bad'.tr();
      case 2:
        return 'entries.bad'.tr();
      case 3:
        return 'entries.okay'.tr();
      case 4:
        return 'entries.good'.tr();
      case 5:
        return 'entries.excellent'.tr();
      default:
        return 'Unknown';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: amazing.AmazingGlassSurface(
        effectType: amazing.GlassEffectType.cosmic,
        colorScheme: amazing.ColorScheme.cosmic,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.psychology_outlined,
                size: 64,
                color: Color(0xFFFB9E3A),
              ),
              const SizedBox(height: 16),
              Text(
                'entries.no_entries'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'entries.start_tracking'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/add-entry'),
                icon: const Icon(Icons.add),
                label: Text('common.add'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB9E3A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedMoodFilter: _selectedMoodFilter,
        selectedDateRange: _selectedDateRange,
        onApplyFilters: (moodFilter, dateRange) {
          setState(() {
            _selectedMoodFilter = moodFilter;
            _selectedDateRange = dateRange;
          });
        },
      ),
    );
  }

  void _showEntryDetails(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EntryDetailsSheet(entry: entry),
    );
  }

  Widget _buildLoadingState() {
    return amazing.AmazingBackground(
      type: amazing.BackgroundType.cosmic,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'entries.title'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 10)],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFB9E3A)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return amazing.AmazingBackground(
      type: amazing.BackgroundType.cosmic,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'entries.title'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 10)],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        body: Center(
          child: amazing.AmazingGlassSurface(
            effectType: amazing.GlassEffectType.cosmic,
            colorScheme: amazing.ColorScheme.cosmic,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEA2F14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading entries',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(allMoodEntriesProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA2F14),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        backgroundColor: const Color(0xFFFB9E3A).withOpacity(0.3),
        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
        onDeleted: onDeleted,
        side: BorderSide.none,
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onTap;

  const _EntryCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mood = entry['mood'] as int;
    final note = entry['note'] as String;
    final date = entry['date'] as DateTime;
    final tags = (entry['tags'] as List<dynamic>).cast<String>();
    
    // Отладочная информация (можно убрать после тестирования)
    // print('🔍 Отображение записи: mood=$mood, date=$date, note=$note');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: amazing.AmazingGlassSurface(
        effectType: amazing.GlassEffectType.neon,
        colorScheme: amazing.ColorScheme.neon,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MoodIndicator(mood: mood),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _moodLabel(mood),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white60,
                    ),
                  ],
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: tags.take(3).map((tag) => _TagChip(tag: tag)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _moodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Very Bad';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unknown';
    }
  }
}

class _MoodIndicator extends StatelessWidget {
  final int mood;

  const _MoodIndicator({required this.mood});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFEA2F14), // Very Bad
      const Color(0xFFE6521F), // Bad
      const Color(0xFFFB9E3A), // Okay
      const Color(0xFFFCEF91), // Good
      const Color(0xFF6D67E4), // Excellent
    ];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors[mood - 1],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors[mood - 1].withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          mood.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFB9E3A).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFB9E3A).withOpacity(0.3),
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFFB9E3A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final int? selectedMoodFilter;
  final DateTimeRange? selectedDateRange;
  final Function(int?, DateTimeRange?) onApplyFilters;

  const _FilterDialog({
    required this.selectedMoodFilter,
    required this.selectedDateRange,
    required this.onApplyFilters,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  int? _moodFilter;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _moodFilter = widget.selectedMoodFilter;
    _dateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: amazing.AmazingGlassSurface(
        effectType: amazing.GlassEffectType.cosmic,
        colorScheme: amazing.ColorScheme.cosmic,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Entries',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Mood Filter
              Text(
                'entries.filter_by_mood'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: List.generate(5, (index) {
                  final mood = index + 1;
                  final isSelected = _moodFilter == mood;
                  return _MoodFilterChip(
                    mood: mood,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _moodFilter = isSelected ? null : mood;
                      });
                    },
                  );
                }),
              ),
              
              const SizedBox(height: 20),
              
              // Date Range Filter
              Text(
                'entries.filter_by_date'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(_dateRange != null 
                    ? '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd').format(_dateRange!.end)}'
                    : 'Select Date Range'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB9E3A).withOpacity(0.2),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: const Color(0xFFFB9E3A).withOpacity(0.3)),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(_moodFilter, _dateRange);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB9E3A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFB9E3A),
              onPrimary: Colors.white,
              surface: Color(0xFF121212),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (range != null) {
      setState(() {
        _dateRange = range;
      });
    }
  }
}

class _MoodFilterChip extends StatelessWidget {
  final int mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodFilterChip({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFEA2F14), // Very Bad
      const Color(0xFFE6521F), // Bad
      const Color(0xFFFB9E3A), // Okay
      const Color(0xFFFCEF91), // Good
      const Color(0xFF6D67E4), // Excellent
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? colors[mood - 1] : colors[mood - 1].withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : colors[mood - 1],
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            mood.toString(),
            style: TextStyle(
              color: isSelected ? Colors.white : colors[mood - 1],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _EntryDetailsSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final mood = entry['mood'] as int;
    final note = entry['note'] as String;
    final date = entry['date'] as DateTime;
    final tags = (entry['tags'] as List<dynamic>).cast<String>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      _MoodIndicator(mood: mood),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _moodLabel(mood),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMMM dd, yyyy • HH:mm').format(date),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white60),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Note
                  if (note.isNotEmpty) ...[
                    Text(
                      'Note',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        note,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Tags
                  if (tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((tag) => _TagChip(tag: tag)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _moodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Very Bad';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unknown';
    }
  }
}
