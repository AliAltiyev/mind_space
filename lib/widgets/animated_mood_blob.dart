import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_design.dart';
import '../features/mood_tracking/domain/entities/mood_entry.dart';

class AnimatedMoodBlob extends StatefulWidget {
  final MoodLevel? mood;
  final double size;
  final VoidCallback? onTap;
  final bool isPulsing;
  final Duration animationDuration;

  const AnimatedMoodBlob({
    super.key,
    this.mood,
    this.size = 200.0,
    this.onTap,
    this.isPulsing = true,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedMoodBlob> createState() => _AnimatedMoodBlobState();
}

class _AnimatedMoodBlobState extends State<AnimatedMoodBlob>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _breathController;
  late AnimationController _morphController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _breathAnimation;
  late Animation<double> _morphAnimation;
  
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Контроллер для пульсации
    _pulseController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // Контроллер для дыхания
    _breathController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Контроллер для морфинга формы
    _morphController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _breathAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    ));
    
    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    ));
    
    // Анимация цвета
    if (widget.mood != null) {
      final colors = _getMoodColors(widget.mood!);
      _colorAnimation = ColorTween(
        begin: colors[0],
        end: colors[1],
      ).animate(CurvedAnimation(
        parent: _morphController,
        curve: Curves.easeInOut,
      ));
    }
  }

  void _startAnimations() {
    if (widget.isPulsing) {
      _pulseController.repeat(reverse: true);
      _breathController.repeat(reverse: true);
      _morphController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breathController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  List<Color> _getMoodColors(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.verySad:
        return AppDesign.verySadGradient;
      case MoodLevel.sad:
        return AppDesign.sadGradient;
      case MoodLevel.neutral:
        return AppDesign.neutralGradient;
      case MoodLevel.happy:
        return AppDesign.happyGradient;
      case MoodLevel.veryHappy:
        return AppDesign.veryHappyGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseController,
          _breathController,
          _morphController,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * _breathAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: MoodBlobPainter(
                mood: widget.mood,
                morphValue: _morphAnimation.value,
                colorAnimation: _colorAnimation,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MoodBlobPainter extends CustomPainter {
  final MoodLevel? mood;
  final double morphValue;
  final Animation<Color?>? colorAnimation;

  MoodBlobPainter({
    this.mood,
    required this.morphValue,
    this.colorAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Создаем путь для капли
    final path = _createBlobPath(center, radius);
    
    // Создаем градиент
    final gradient = _createGradient(center, radius);
    
    // Рисуем каплю
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: center,
        radius: radius,
      ));
    
    canvas.drawPath(path, paint);
    
    // Добавляем блик
    _drawHighlight(canvas, center, radius);
    
    // Добавляем эмодзи если есть настроение
    if (mood != null) {
      _drawEmoji(canvas, center, radius);
    }
  }

  Path _createBlobPath(Offset center, double radius) {
    final path = Path();
    
    // Базовые точки для капли
    final top = Offset(center.dx, center.dy - radius * 0.8);
    final bottom = Offset(center.dx, center.dy + radius * 0.6);
    final left = Offset(center.dx - radius * 0.7, center.dy);
    final right = Offset(center.dx + radius * 0.7, center.dy);
    
    // Морфинг точек
    final topMorphed = Offset(
      top.dx + math.sin(morphValue * 2 * math.pi) * radius * 0.1,
      top.dy + math.cos(morphValue * 2 * math.pi) * radius * 0.1,
    );
    
    final bottomMorphed = Offset(
      bottom.dx + math.sin(morphValue * 2 * math.pi + math.pi) * radius * 0.1,
      bottom.dy + math.cos(morphValue * 2 * math.pi + math.pi) * radius * 0.1,
    );
    
    final leftMorphed = Offset(
      left.dx + math.sin(morphValue * 2 * math.pi + math.pi / 2) * radius * 0.1,
      left.dy + math.cos(morphValue * 2 * math.pi + math.pi / 2) * radius * 0.1,
    );
    
    final rightMorphed = Offset(
      right.dx + math.sin(morphValue * 2 * math.pi + 3 * math.pi / 2) * radius * 0.1,
      right.dy + math.cos(morphValue * 2 * math.pi + 3 * math.pi / 2) * radius * 0.1,
    );
    
    // Создаем каплю
    path.moveTo(topMorphed.dx, topMorphed.dy);
    
    // Верхняя часть
    path.quadraticBezierTo(
      rightMorphed.dx, rightMorphed.dy - radius * 0.3,
      rightMorphed.dx, rightMorphed.dy,
    );
    
    // Правая часть
    path.quadraticBezierTo(
      rightMorphed.dx + radius * 0.2, rightMorphed.dy + radius * 0.2,
      bottomMorphed.dx, bottomMorphed.dy,
    );
    
    // Нижняя часть
    path.quadraticBezierTo(
      leftMorphed.dx + radius * 0.2, leftMorphed.dy + radius * 0.2,
      leftMorphed.dx, leftMorphed.dy,
    );
    
    // Левая часть
    path.quadraticBezierTo(
      leftMorphed.dx - radius * 0.2, leftMorphed.dy - radius * 0.2,
      topMorphed.dx, topMorphed.dy,
    );
    
    path.close();
    
    return path;
  }

  Gradient _createGradient(Offset center, double radius) {
    if (mood != null) {
      final colors = _getMoodColors(mood!);
      return RadialGradient(
        center: Alignment.topLeft,
        radius: 1.0,
        colors: [
          colors[0],
          colors[1],
          colors[0].withOpacity(0.8),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
    } else {
      return RadialGradient(
        center: Alignment.topLeft,
        radius: 1.0,
        colors: [
          AppDesign.accentColor,
          AppDesign.accentColor.withOpacity(0.7),
          AppDesign.accentColor.withOpacity(0.5),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
    }
  }

  List<Color> _getMoodColors(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.verySad:
        return AppDesign.verySadGradient;
      case MoodLevel.sad:
        return AppDesign.sadGradient;
      case MoodLevel.neutral:
        return AppDesign.neutralGradient;
      case MoodLevel.happy:
        return AppDesign.happyGradient;
      case MoodLevel.veryHappy:
        return AppDesign.veryHappyGradient;
    }
  }

  void _drawHighlight(Canvas canvas, Offset center, double radius) {
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
        radius: radius * 0.2,
      ));
    
    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawEmoji(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: mood!.emoji,
        style: TextStyle(
          fontSize: radius * 0.4,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
