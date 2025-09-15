import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Потрясающий анимированный фон с невероятными эффектами
class AmazingBackground extends StatefulWidget {
  final Widget child;
  final BackgroundType type;

  const AmazingBackground({
    super.key,
    required this.child,
    this.type = BackgroundType.cosmic,
  });

  @override
  State<AmazingBackground> createState() => _AmazingBackgroundState();
}

class _AmazingBackgroundState extends State<AmazingBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    _gradientController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _gradientController,
          _particleController,
          _pulseController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: _buildBackgroundGradient(),
            ),
            child: Stack(
              children: [
                // Анимированные частицы
                _buildParticles(),
                
                // Основной контент
                widget.child,
              ],
            ),
          );
        },
      ),
    );
  }

  Gradient _buildBackgroundGradient() {
    switch (widget.type) {
      case BackgroundType.cosmic:
        return RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFF0F0F23),
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F3460),
          ],
          stops: [
            0.0,
            0.3,
            0.7,
            1.0,
          ],
        );
      case BackgroundType.neon:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF000000),
            const Color(0xFF0A0A0A),
            const Color(0xFF1A0033),
            const Color(0xFF330066),
          ],
          stops: [
            0.0,
            0.3,
            0.7,
            1.0,
          ],
        );
      case BackgroundType.cyber:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF000000),
            const Color(0xFF001122),
            const Color(0xFF003344),
            const Color(0xFF000000),
          ],
          stops: [
            0.0,
            0.4,
            0.8,
            1.0,
          ],
        );
      case BackgroundType.rainbow:
        return SweepGradient(
          center: Alignment.center,
          startAngle: _gradientController.value * 2 * math.pi,
          endAngle: (_gradientController.value * 2 * math.pi) + (math.pi / 2),
          colors: [
            const Color(0xFFFF0000),
            const Color(0xFFFF8000),
            const Color(0xFFFFD700),
            const Color(0xFF00FF00),
            const Color(0xFF0080FF),
            const Color(0xFF8000FF),
            const Color(0xFFFF0080),
            const Color(0xFFFF0000),
          ],
          stops: [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0],
        );
    }
  }

  Widget _buildParticles() {
    return CustomPaint(
      size: Size.infinite,
      painter: ParticlePainter(
        animation: _particleController,
        pulseAnimation: _pulseController,
        type: widget.type,
      ),
    );
  }
}

/// Типы фонов
enum BackgroundType {
  cosmic,
  neon,
  cyber,
  rainbow,
}

/// Художник для рисования анимированных частиц
class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final Animation<double> pulseAnimation;
  final BackgroundType type;

  ParticlePainter({
    required this.animation,
    required this.pulseAnimation,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Рисуем частицы
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 23.0 + animation.value * 100) % size.height;
      
      final alpha = (math.sin(animation.value * 2 * math.pi + i) + 1) / 2;
      final particleSize = 2.0 + (pulseAnimation.value * 3);
      
      paint.color = _getParticleColor().withOpacity(alpha * 0.6);
      
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }

    // Рисуем звезды
    for (int i = 0; i < 30; i++) {
      final x = (i * 53.0) % size.width;
      final y = (i * 41.0 + animation.value * 50) % size.height;
      
      final alpha = (math.cos(animation.value * 2 * math.pi + i) + 1) / 2;
      
      paint.color = _getStarColor().withOpacity(alpha * 0.8);
      
      canvas.drawCircle(
        Offset(x, y),
        1.0 + (pulseAnimation.value * 2),
        paint,
      );
    }
  }

  Color _getParticleColor() {
    switch (type) {
      case BackgroundType.cosmic:
        return const Color(0xFF8B5CF6);
      case BackgroundType.neon:
        return const Color(0xFF00FFFF);
      case BackgroundType.cyber:
        return const Color(0xFF00FF41);
      case BackgroundType.rainbow:
        return const Color(0xFFFFD700);
    }
  }

  Color _getStarColor() {
    switch (type) {
      case BackgroundType.cosmic:
        return const Color(0xFF06B6D4);
      case BackgroundType.neon:
        return const Color(0xFF00FF00);
      case BackgroundType.cyber:
        return const Color(0xFF00D4FF);
      case BackgroundType.rainbow:
        return const Color(0xFFFFFFFF);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
