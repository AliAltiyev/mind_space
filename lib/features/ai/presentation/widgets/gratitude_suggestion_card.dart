import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../presentation/widgets/core/glass_surface.dart';
import '../../domain/entities/gratitude_entity.dart';

/// Карточка для отображения благодарственных предложений
class GratitudeSuggestionCard extends StatelessWidget {
  final GratitudeEntity gratitude;
  final VoidCallback? onTap;
  final double height;

  const GratitudeSuggestionCard({
    super.key,
    required this.gratitude,
    this.onTap,
    this.height = 300,
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

              // Предложения
              _buildPrompts(),

              const Spacer(),

              // Информация о категории
              _buildCategoryInfo(),
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
            color: gratitude.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(gratitude.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),

        const SizedBox(width: 16),

        // Заголовок
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gratitude.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                gratitude.category.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: gratitude.accentColor.withOpacity(0.8),
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
      gratitude.description,
      style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
    );
  }

  Widget _buildPrompts() {
    if (gratitude.prompts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_quote, size: 16, color: gratitude.accentColor),
            const SizedBox(width: 8),
            const Text(
              'Предложения для размышлений:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...gratitude.prompts.take(4).map((prompt) => _buildPromptItem(prompt)),
      ],
    );
  }

  Widget _buildPromptItem(String prompt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: gratitude.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: gratitude.accentColor.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 8, right: 12),
              decoration: BoxDecoration(
                color: gratitude.accentColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Expanded(
              child: Text(
                prompt,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Row(
      children: [
        Icon(
          Icons.category,
          size: 14,
          color: gratitude.accentColor.withOpacity(0.6),
        ),

        const SizedBox(width: 8),

        Text(
          'Категория: ${gratitude.category.displayName}',
          style: TextStyle(
            fontSize: 12,
            color: gratitude.accentColor.withOpacity(0.6),
          ),
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: gratitude.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${gratitude.promptCount} предложений',
            style: TextStyle(
              fontSize: 10,
              color: gratitude.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Виджет для отображения состояния загрузки благодарственных предложений
class GratitudeSuggestionLoadingCard extends StatelessWidget {
  final double height;

  const GratitudeSuggestionLoadingCard({super.key, this.height = 300});

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

            // Предложения с анимацией
            Row(
              children: [
                Icon(
                  Icons.format_quote,
                  size: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 180,
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
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Индикатор загрузки
            Row(
              children: [
                const Icon(Icons.format_quote, size: 14, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'AI генерирует предложения...',
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

/// Виджет для отображения ошибки благодарственных предложений
class GratitudeSuggestionErrorCard extends StatelessWidget {
  final String message;
  final String? suggestion;
  final VoidCallback? onRetry;
  final double height;

  const GratitudeSuggestionErrorCard({
    super.key,
    required this.message,
    this.suggestion,
    this.onRetry,
    this.height = 300,
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
                Icons.format_quote,
                size: 32,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            // Сообщение об ошибке
            Text(
              'Ошибка загрузки',
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
