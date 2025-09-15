import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../features/ai/domain/entities/ai_insight_entity.dart';
import '../core/amazing_glass_surface.dart' as amazing;

/// Потрясающая AI карточка с невероятными эффектами
class AmazingAIInsightCard extends StatefulWidget {
  final AIInsightEntity insight;
  final VoidCallback? onTap;
  final bool showSuggestions;
  final double height;
  final amazing.GlassEffectType effectType;
  final amazing.ColorScheme colorScheme;

  const AmazingAIInsightCard({
    super.key,
    required this.insight,
    this.onTap,
    this.showSuggestions = true,
    this.height = 280,
    this.effectType = amazing.GlassEffectType.neon,
    this.colorScheme = amazing.ColorScheme.neon,
  });

  @override
  State<AmazingAIInsightCard> createState() => _AmazingAIInsightCardState();
}

class _AmazingAIInsightCardState extends State<AmazingAIInsightCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseController,
          _rotationController,
          _glowController,
        ]),
        builder: (context, child) {
          return amazing.AmazingGlassSurface(
            effectType: widget.effectType,
            colorScheme: widget.colorScheme,
            child: SizedBox(
              height: widget.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок с анимированной иконкой
                  _buildHeader(),

                  const SizedBox(height: 16),

                  // Основной контент
                  Expanded(child: _buildContent()),

                  if (widget.showSuggestions) ...[
                    const SizedBox(height: 16),
                    _buildSuggestions(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Анимированная иконка
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: widget.colorScheme.neonColors,
                    stops: [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.colorScheme.borderColor.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: widget.colorScheme.borderColor,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Персональные инсайты',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      color: widget.colorScheme.borderColor.withOpacity(0.5),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Анимированный индикатор
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.colorScheme.borderColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.colorScheme.borderColor,
                    blurRadius: 10 + (_pulseController.value * 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.colorScheme.borderColor.withOpacity(0.1),
            Colors.transparent,
            widget.colorScheme.borderColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.colorScheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.insight.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              widget.insight.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    if (widget.insight.suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.colorScheme.borderColor.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.colorScheme.borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Рекомендации:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.colorScheme.borderColor,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.insight.suggestions.take(2).map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.colorScheme.borderColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
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
}
