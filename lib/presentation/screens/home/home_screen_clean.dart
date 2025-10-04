import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../app/providers/ai_features_provider.dart';

/// Главный экран приложения - строгий и понятный дизайн
class HomeScreenClean extends ConsumerWidget {
  const HomeScreenClean({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastMoodAsync = ref.watch(lastMoodProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mind Space',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/settings/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            _buildWelcomeSection(),
            
            const SizedBox(height: 24),
            
            // Текущее настроение
            _buildCurrentMoodSection(context, lastMoodAsync),
            
            const SizedBox(height: 24),
            
            // Быстрая статистика
            _buildQuickStats(),
            
            const SizedBox(height: 24),
            
            // Быстрые действия
            _buildQuickActions(context),
            
            const SizedBox(height: 24),
            
            // Последние записи
            _buildRecentEntries(context, ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-entry'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Секция приветствия
  Widget _buildWelcomeSection() {
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
            'Добро пожаловать!',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Как дела сегодня? Поделитесь своим настроением.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Секция текущего настроения
  Widget _buildCurrentMoodSection(BuildContext context, AsyncValue lastMoodAsync) {
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
            'Текущее настроение',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          lastMoodAsync.when(
            data: (lastMood) {
              if (lastMood != null) {
                return _buildMoodDisplay(lastMood);
              } else {
                return _buildNoMoodState(context);
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildErrorState(context),
          ),
        ],
      ),
    );
  }

  /// Отображение настроения
  Widget _buildMoodDisplay(dynamic lastMood) {
    final moodValue = lastMood.moodValue;
    final date = lastMood.createdAt;
    
    return Row(
      children: [
        // Иконка настроения
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: getMoodGradient(moodValue),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            _getMoodIcon(moodValue),
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        // Информация о настроении
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getMoodLabel(moodValue),
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMMM, HH:mm').format(date),
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        // Кнопка обновить
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh),
          color: AppColors.primary,
        ),
      ],
    );
  }

  /// Состояние без настроения
  Widget _buildNoMoodState(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.mood_outlined,
            size: 40,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Пока нет записей',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => context.push('/add-entry'),
          child: const Text('Добавить настроение'),
        ),
      ],
    );
  }

  /// Состояние ошибки
  Widget _buildErrorState(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 40,
          color: AppColors.error,
        ),
        const SizedBox(height: 8),
        Text(
          'Ошибка загрузки',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Попробовать снова'),
        ),
      ],
    );
  }

  /// Быстрая статистика
  Widget _buildQuickStats() {
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
            'Статистика',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Всего записей',
                  value: '12',
                  icon: Icons.list_alt,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Сегодня',
                  value: '1',
                  icon: Icons.today,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
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
            'Быстрые действия',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _ActionCard(
                title: 'Статистика',
                icon: Icons.analytics,
                color: AppColors.primary,
                onTap: () => context.go('/stats'),
              ),
              _ActionCard(
                title: 'Все записи',
                icon: Icons.list,
                color: AppColors.secondary,
                onTap: () => context.go('/home/entries'),
              ),
              _ActionCard(
                title: 'AI Инсайты',
                icon: Icons.psychology,
                color: AppColors.info,
                onTap: () => context.go('/stats/insights'),
              ),
              _ActionCard(
                title: 'Медитация',
                icon: Icons.self_improvement,
                color: AppColors.success,
                onTap: () => context.go('/stats/meditation'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Последние записи
  Widget _buildRecentEntries(BuildContext context, WidgetRef ref) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Последние записи',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () => context.go('/home/entries'),
                child: const Text('Все записи'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Здесь будут последние записи
          _buildEmptyState(),
        ],
      ),
    );
  }

  /// Пустое состояние для последних записей
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mood_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет записей',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте первую запись настроения',
            style: AppTypography.caption,
          ),
        ],
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

/// Карточка статистики
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Карточка действия
class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
