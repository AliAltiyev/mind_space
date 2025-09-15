import 'package:flutter/material.dart';

import '../../../../../presentation/widgets/core/glass_surface.dart';
import '../../domain/entities/meditation_entity.dart';

/// Карточка для отображения медитационных сессий
class MeditationSuggestionCard extends StatelessWidget {
  final MeditationEntity meditation;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final double height;

  const MeditationSuggestionCard({
    super.key,
    required this.meditation,
    this.onTap,
    this.onStart,
    this.height = 350,
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

              // Информация о сессии
              _buildSessionInfo(),

              const SizedBox(height: 16),

              // Инструкции
              _buildInstructions(),

              const Spacer(),

              // Кнопка начала и дополнительная информация
              _buildFooter(),
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
            color: meditation.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(meditation.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),

        const SizedBox(width: 16),

        // Заголовок
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meditation.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                meditation.type.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: meditation.accentColor.withOpacity(0.8),
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
      meditation.description,
      style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
    );
  }

  Widget _buildSessionInfo() {
    return Row(
      children: [
        // Длительность
        _buildInfoChip(
          icon: Icons.timer,
          label: '${meditation.duration} мин',
          color: meditation.accentColor,
        ),

        const SizedBox(width: 12),

        // Сложность
        _buildInfoChip(
          icon: Icons.speed,
          label: meditation.difficulty.displayName,
          color: meditation.difficulty.color,
        ),

        const SizedBox(width: 12),

        // Тип
        _buildInfoChip(
          icon: meditation.type.emoji,
          label: meditation.type.displayName,
          color: meditation.accentColor,
          isEmoji: true,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required dynamic icon,
    required String label,
    required Color color,
    bool isEmoji = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isEmoji
              ? Text(icon, style: const TextStyle(fontSize: 12))
              : Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    if (meditation.instructions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt, size: 16, color: meditation.accentColor),
            const SizedBox(width: 8),
            const Text(
              'Инструкции:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...meditation.instructions
            .take(3)
            .map((instruction) => _buildInstructionItem(instruction)),
      ],
    );
  }

  Widget _buildInstructionItem(String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: meditation.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${meditation.instructions.indexOf(instruction) + 1}',
                style: TextStyle(
                  fontSize: 10,
                  color: meditation.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: Text(
              instruction,
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

  Widget _buildFooter() {
    return Column(
      children: [
        // Кнопка начала медитации
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: Text('Начать медитацию (${meditation.duration} мин)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: meditation.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Дополнительная информация
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: meditation.accentColor.withOpacity(0.6),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                'Создано: ${_formatDate(meditation.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: meditation.accentColor.withOpacity(0.6),
                ),
              ),
            ),

            // Советы
            if (meditation.tips.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: meditation.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${meditation.tipCount} советов',
                  style: TextStyle(
                    fontSize: 10,
                    color: meditation.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }
}

/// Виджет для отображения состояния загрузки медитационных сессий
class MeditationSuggestionLoadingCard extends StatelessWidget {
  final double height;

  const MeditationSuggestionLoadingCard({super.key, this.height = 350});

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

            // Информация о сессии с анимацией
            Row(
              children: [
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 120,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Инструкции с анимацией
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  size: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
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
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
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

            // Кнопка с анимацией
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 16),

            // Индикатор загрузки
            Row(
              children: [
                const Icon(
                  Icons.self_improvement,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI подбирает медитацию...',
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

/// Виджет для отображения ошибки медитационных сессий
class MeditationSuggestionErrorCard extends StatelessWidget {
  final String message;
  final String? suggestion;
  final VoidCallback? onRetry;
  final double height;

  const MeditationSuggestionErrorCard({
    super.key,
    required this.message,
    this.suggestion,
    this.onRetry,
    this.height = 350,
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
                Icons.self_improvement,
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
