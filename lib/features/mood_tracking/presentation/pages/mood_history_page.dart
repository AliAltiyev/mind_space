import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/mood_tracking_bloc.dart';
import '../bloc/mood_tracking_event.dart';
import '../bloc/mood_tracking_state.dart';
import '../../domain/entities/mood_entry.dart';

class MoodHistoryPage extends StatefulWidget {
  const MoodHistoryPage({super.key});

  @override
  State<MoodHistoryPage> createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<MoodHistoryPage> {
  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _selectedEndDate = DateTime.now();
  MoodLevel? _selectedMoodFilter;

  @override
  void initState() {
    super.initState();
    context.read<MoodTrackingBloc>().add(LoadMoodEntries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'История настроений',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1A1A1A)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocBuilder<MoodTrackingBloc, MoodTrackingState>(
        builder: (context, state) {
          if (state is MoodTrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoodTrackingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: GoogleFonts.inter(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is MoodTrackingLoaded) {
            return _buildLoadedState(context, state);
          }

          return const Center(child: Text('Загрузка...'));
        },
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, MoodTrackingLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartSection(state.entries),
          const SizedBox(height: 24),
          _buildStatisticsSection(state.statistics),
          const SizedBox(height: 24),
          _buildEntriesList(state.entries),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<MoodEntry> entries) {
    final chartData = _prepareChartData(entries);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'График настроений',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 2 == 0) {
                          final date = DateTime.now().subtract(
                            Duration(days: 6 - value.toInt()),
                          );
                          return Text(
                            '${date.day}/${date.month}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF666666),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: const Color(0xFF007AFF),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF007AFF).withOpacity(0.1),
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

  List<FlSpot> _prepareChartData(List<MoodEntry> entries) {
    final Map<int, double> dailyAverages = {};
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dayEntries = entries.where((entry) {
        return entry.createdAt.year == date.year &&
            entry.createdAt.month == date.month &&
            entry.createdAt.day == date.day;
      }).toList();
      
      if (dayEntries.isNotEmpty) {
        final average = dayEntries.map((e) => e.mood.value).reduce((a, b) => a + b) / dayEntries.length;
        dailyAverages[i] = average;
      } else {
        dailyAverages[i] = 3.0; // Нейтральное значение
      }
    }
    
    return dailyAverages.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  Widget _buildStatisticsSection(Map<MoodLevel, int>? statistics) {
    if (statistics == null || statistics.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = statistics.values.fold(0, (sum, count) => sum + count);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ...statistics.entries.map((entry) {
            final percentage = (entry.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    entry.key.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key.label,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: entry.value / total,
                          backgroundColor: _getMoodColor(entry.key).withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getMoodColor(entry.key),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.sentiment_neutral,
              size: 64,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 16),
            Text(
              'Пока нет записей',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Начните записывать свое настроение',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF999999),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Записи',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        ...entries.map((entry) => _buildMoodEntryCard(entry)),
      ],
    );
  }

  Widget _buildMoodEntryCard(MoodEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getMoodColor(entry.mood).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.mood.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.mood.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                if (entry.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.note,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatDate(entry.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.verySad:
        return const Color(0xFF6B46C1);
      case MoodLevel.sad:
        return const Color(0xFF3B82F6);
      case MoodLevel.neutral:
        return const Color(0xFF6B7280);
      case MoodLevel.happy:
        return const Color(0xFF10B981);
      case MoodLevel.veryHappy:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Сегодня в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Вчера в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Фильтры',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'По дате',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${_selectedStartDate.day}.${_selectedStartDate.month} - ${_selectedEndDate.day}.${_selectedEndDate.month}',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              onTap: _selectDateRange,
            ),
            const Divider(),
            ListTile(
              title: Text(
                'По настроению',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _selectedMoodFilter?.label ?? 'Все',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              onTap: _selectMoodFilter,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMoodFilter = null;
                _selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
                _selectedEndDate = DateTime.now();
              });
              context.read<MoodTrackingBloc>().add(ClearFilters());
              Navigator.pop(context);
            },
            child: const Text('Сбросить'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );
    
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      context.read<MoodTrackingBloc>().add(
        FilterMoodEntriesByDate(_selectedStartDate, _selectedEndDate),
      );
      Navigator.pop(context);
    }
  }

  void _selectMoodFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Выберите настроение',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Все', style: GoogleFonts.inter()),
              onTap: () {
                setState(() => _selectedMoodFilter = null);
                context.read<MoodTrackingBloc>().add(ClearFilters());
                Navigator.pop(context);
              },
            ),
            ...MoodLevel.values.map((mood) => ListTile(
              leading: Text(mood.emoji, style: const TextStyle(fontSize: 20)),
              title: Text(mood.label, style: GoogleFonts.inter()),
              onTap: () {
                setState(() => _selectedMoodFilter = mood);
                context.read<MoodTrackingBloc>().add(
                  FilterMoodEntriesByMood(mood),
                );
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}

