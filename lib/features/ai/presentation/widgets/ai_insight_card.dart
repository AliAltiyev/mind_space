import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../presentation/widgets/core/glass_surface.dart';
import '../../domain/entities/ai_insight_entity.dart';

/// Карточка для отображения AI инсайтов
class AIInsightCard extends StatelessWidget {
  final AIInsightEntity insight;
  final VoidCallback? onTap;
  final bool showSuggestions;
  final double height;

  const AIInsightCard({
    super.key,
    required this.insight,
    this.onTap,
    this.showSuggestions = true,
    this.height = 280,
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
              // Заголовок с emoji
              _buildHeader(),

              const SizedBox(height: 16),

              // Описание
              _buildDescription(),

              if (showSuggestions) ...[
                const SizedBox(height: 20),

                // Предложения
                _buildSuggestions(),
              ],

              const Spacer(),

              // Индикатор уверенности
              _buildConfidenceIndicator(),
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
            color: insight.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(insight.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),

        const SizedBox(width: 16),

        // Заголовок
        Expanded(
          child: Text(
            insight.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      insight.description,
      style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
    );
  }

  Widget _buildSuggestions() {
    if (insight.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Рекомендации:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 12),

        ...insight.suggestions
            .take(3)
            .map((suggestion) => _buildSuggestionItem(suggestion)),
      ],
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
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
              color: insight.accentColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          Expanded(
            child: Text(
              suggestion,
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

  Widget _buildConfidenceIndicator() {
    return Row(
      children: [
        Icon(Icons.psychology, size: 16, color: insight.accentColor),

        const SizedBox(width: 8),

        Text(
          'Уверенность AI: ${(insight.confidence * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: insight.accentColor.withOpacity(0.8),
          ),
        ),

        const Spacer(),

        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: insight.confidence,
            child: Container(
              decoration: BoxDecoration(
                color: insight.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Виджет для отображения состояния загрузки AI инсайтов
class AIInsightLoadingCard extends StatelessWidget {
  final double height;

  const AIInsightLoadingCard({super.key, this.height = 280});

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
                        height: 16,
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

            // Рекомендации с анимацией
            ...List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
                const Icon(Icons.psychology, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'AI анализирует ваши данные...',
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

/// Виджет для отображения ошибки AI инсайтов
class AIInsightErrorCard extends StatelessWidget {
  final String message;
  final String? suggestion;
  final VoidCallback? onRetry;
  final double height;

  const AIInsightErrorCard({
    super.key,
    required this.message,
    this.suggestion,
    this.onRetry,
    this.height = 280,
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
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            // Сообщение об ошибке
            Text(
              'ai.error_loading'.tr(),
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
                label: const Text('Попробовать снова'),
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
