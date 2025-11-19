import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../presentation/widgets/core/glass_surface.dart';
import '../../domain/entities/mood_pattern_entity.dart';

/// Карточка для отображения анализа паттернов настроения
class PatternAnalysisCard extends StatelessWidget {
  final MoodPatternEntity patterns;
  final VoidCallback? onTap;
  final double height;

  const PatternAnalysisCard({
    super.key,
    required this.patterns,
    this.onTap,
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        child: Container(
          height: height,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              _buildHeader(),

              const SizedBox(height: 16),

              // Описание
              _buildDescription(),

              const SizedBox(height: 20),

              // Паттерны
              _buildPatterns(),

              const SizedBox(height: 16),

              // Рекомендации
              _buildRecommendations(),

              const Spacer(),

              // Информация о периоде анализа
              _buildAnalysisInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Emoji
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: patterns.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(patterns.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),

        const SizedBox(width: 16),

        // Заголовок
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patterns.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Анализ за ${patterns.analysisPeriod} дней',
                style: TextStyle(
                  fontSize: 12,
                  color: patterns.accentColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      patterns.description,
      style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
    );
  }

  Widget _buildPatterns() {
    if (patterns.patterns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, size: 16, color: patterns.accentColor),
            const SizedBox(width: 8),
            const Text(
              'Выявленные паттерны:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...patterns.patterns
            .take(3)
            .map((pattern) => _buildPatternItem(pattern)),
      ],
    );
  }

  Widget _buildPatternItem(String pattern) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: patterns.accentColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          Expanded(
            child: Text(
              pattern,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    if (patterns.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: patterns.accentColor,
            ),
            const SizedBox(width: 8),
            const Text(
              'Рекомендации:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...patterns.recommendations
            .take(2)
            .map((recommendation) => _buildRecommendationItem(recommendation)),
      ],
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: patterns.accentColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisInfo() {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: patterns.accentColor.withOpacity(0.6),
        ),

        const SizedBox(width: 8),

        Text(
          'Анализ от ${_formatDate(patterns.analyzedAt)}',
          style: TextStyle(
            fontSize: 12,
            color: patterns.accentColor.withOpacity(0.6),
          ),
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: patterns.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${patterns.patternCount} паттернов',
            style: TextStyle(
              fontSize: 10,
              color: patterns.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }
}

/// Виджет для отображения состояния загрузки анализа паттернов
class PatternAnalysisLoadingCard extends StatelessWidget {
  final double height;

  const PatternAnalysisLoadingCard({super.key, this.height = 320});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с анимацией
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Описание с анимацией
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index < 2 ? 8 : 0),
                child: Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Паттерны с анимацией
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  size: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Рекомендации с анимацией
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Индикатор загрузки
            Row(
              children: [
                const Icon(Icons.analytics, size: 14, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'AI анализирует паттерны...',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const Spacer(),
                SizedBox(
                  width: 60,
                  height: 4,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Виджет для отображения ошибки анализа паттернов
class PatternAnalysisErrorCard extends StatelessWidget {
  final String message;
  final String? suggestion;
  final VoidCallback? onRetry;
  final double height;

  const PatternAnalysisErrorCard({
    super.key,
    required this.message,
    this.suggestion,
    this.onRetry,
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка ошибки
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.analytics, size: 32, color: Colors.red),
            ),

            const SizedBox(height: 20),

            // Сообщение об ошибке
            Text(
              'ai.error_analysis'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),

            if (suggestion != null) ...[
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (onRetry != null) ...[
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('common.try_again'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
