import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/mood_entry.dart';
import '../bloc/mood_tracking_bloc.dart';
import '../bloc/mood_tracking_event.dart';
import '../bloc/mood_tracking_state.dart';
import 'add_mood_page.dart';
import 'mood_history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocBuilder<MoodTrackingBloc, MoodTrackingState>(
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
                      'Ошибка',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.inter(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MoodTrackingBloc>().add(LoadMoodEntries());
                      },
                      child: const Text('Попробовать снова'),
                    ),
                  ],
                ),
              );
            }

            if (state is MoodTrackingLoaded) {
              return _buildLoadedState(context, state);
            }

            return const Center(child: Text('Добро пожаловать в MindSpace!'));
          },
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, MoodTrackingLoaded state) {
    final todayEntries = state.entries.where((entry) {
      final now = DateTime.now();
      final entryDate = entry.createdAt;
      return now.year == entryDate.year &&
          now.month == entryDate.month &&
          now.day == entryDate.day;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildQuickMoodSelector(context),
          const SizedBox(height: 32),
          _buildTodaySection(context, todayEntries),
          const SizedBox(height: 24),
          _buildStatisticsSection(context, state.statistics),
          const SizedBox(height: 24),
          _buildRecentEntries(context, state.entries),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Добро пожаловать!',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Как дела сегодня?',
          style: GoogleFonts.inter(
            fontSize: 18,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMoodSelector(BuildContext context) {
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
            'Выберите настроение',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodLevel.values.map((mood) {
              return GestureDetector(
                onTap: () => _navigateToAddMood(context, mood),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getMoodColor(mood).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getMoodColor(mood).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        mood.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getMoodColor(mood),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection(
    BuildContext context,
    List<MoodEntry> todayEntries,
  ) {
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
            'Сегодня',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          if (todayEntries.isEmpty)
            Text(
              'Пока нет записей за сегодня',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            )
          else
            ...todayEntries.map((entry) => _buildMoodEntryCard(context, entry)),
        ],
      ),
    );
  }

  Widget _buildMoodEntryCard(BuildContext context, MoodEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMoodColor(entry.mood).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getMoodColor(entry.mood).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(entry.mood.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.mood.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getMoodColor(entry.mood),
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
              ],
            ),
          ),
          Text(
            '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    Map<MoodLevel, int>? statistics,
  ) {
    if (statistics == null || statistics.isEmpty) {
      return const SizedBox.shrink();
    }

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
            'Статистика за неделю',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ...statistics.entries.map((entry) {
            final total = statistics.values.fold(
              0,
              (sum, count) => sum + count,
            );
            final percentage = (entry.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(entry.key.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: _getMoodColor(
                        entry.key,
                      ).withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getMoodColor(entry.key),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context, List<MoodEntry> entries) {
    final recentEntries = entries.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Последние записи',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () => _navigateToHistory(context),
              child: Text(
                'Все записи',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF007AFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...recentEntries.map((entry) => _buildMoodEntryCard(context, entry)),
      ],
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

  void _navigateToAddMood(BuildContext context, MoodLevel mood) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMoodPage(initialMood: mood)),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoodHistoryPage()),
    );
  }
}
