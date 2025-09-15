import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_design.dart';
import '../features/mood_tracking/domain/entities/mood_entry.dart';

class MoodSelector extends StatefulWidget {
  final MoodLevel? selectedMood;
  final Function(MoodLevel) onMoodSelected;
  final double size;
  final bool isVisible;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
    this.size = 300.0,
    this.isVisible = true,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _hoverController;
  late AnimationController _selectController;

  late Animation<double> _appearAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _selectAnimation;

  MoodLevel? _hoveredMood;
  MoodLevel? _selectedMood;

  @override
  void initState() {
    super.initState();

    _selectedMood = widget.selectedMood;

    _appearController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _selectController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _appearAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.elasticOut,
    );

    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    );

    _selectAnimation = CurvedAnimation(
      parent: _selectController,
      curve: Curves.bounceOut,
    );

    if (widget.isVisible) {
      _startAppearAnimation();
    }
  }

  void _startAppearAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _appearController.forward();
      }
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    _hoverController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _appearController,
        _hoverController,
        _selectController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: MoodSelectorPainter(
            moods: MoodLevel.values,
            selectedMood: _selectedMood,
            hoveredMood: _hoveredMood,
            appearAnimation: _appearAnimation.value,
            hoverAnimation: _hoverAnimation.value,
            selectAnimation: _selectAnimation.value,
            onMoodTap: _onMoodTap,
            onMoodHover: _onMoodHover,
            onMoodLeave: _onMoodLeave,
          ),
        );
      },
    );
  }

  void _onMoodTap(MoodLevel mood) {
    setState(() {
      _selectedMood = mood;
    });

    _selectController.forward().then((_) {
      _selectController.reverse();
    });

    widget.onMoodSelected(mood);
  }

  void _onMoodHover(MoodLevel mood) {
    setState(() {
      _hoveredMood = mood;
    });
    _hoverController.forward();
  }

  void _onMoodLeave() {
    setState(() {
      _hoveredMood = null;
    });
    _hoverController.reverse();
  }
}

class MoodSelectorPainter extends CustomPainter {
  final List<MoodLevel> moods;
  final MoodLevel? selectedMood;
  final MoodLevel? hoveredMood;
  final double appearAnimation;
  final double hoverAnimation;
  final double selectAnimation;
  final Function(MoodLevel) onMoodTap;
  final Function(MoodLevel) onMoodHover;
  final VoidCallback onMoodLeave;

  MoodSelectorPainter({
    required this.moods,
    this.selectedMood,
    this.hoveredMood,
    required this.appearAnimation,
    required this.hoverAnimation,
    required this.selectAnimation,
    required this.onMoodTap,
    required this.onMoodHover,
    required this.onMoodLeave,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 50;

    // Рисуем дугу
    _drawArc(canvas, center, radius);

    // Рисуем эмодзи
    _drawMoods(canvas, center, radius);
  }

  void _drawArc(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppDesign.accentColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, math.pi, false, paint);
  }

  void _drawMoods(Canvas canvas, Offset center, double radius) {
    final angleStep = math.pi / (moods.length - 1);

    for (int i = 0; i < moods.length; i++) {
      final mood = moods[i];
      final angle = -math.pi / 2 + (i * angleStep);

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final moodCenter = Offset(x, y);

      // Анимация появления
      final appearScale = appearAnimation * (1.0 - (i * 0.1));
      final appearOffset = Offset(0, 50 * (1.0 - appearAnimation));

      // Анимация наведения
      final hoverScale = mood == hoveredMood ? 1.0 + hoverAnimation * 0.3 : 1.0;

      // Анимация выбора
      final selectScale = mood == selectedMood
          ? 1.0 + selectAnimation * 0.2
          : 1.0;

      final finalScale = appearScale * hoverScale * selectScale;
      final finalOffset = appearOffset;

      _drawMoodCircle(
        canvas,
        moodCenter + finalOffset,
        mood,
        finalScale,
        mood == selectedMood,
        mood == hoveredMood,
      );
    }
  }

  void _drawMoodCircle(
    Canvas canvas,
    Offset center,
    MoodLevel mood,
    double scale,
    bool isSelected,
    bool isHovered,
  ) {
    final radius = 30.0 * scale;

    // Создаем градиент
    final colors = _getMoodColors(mood);
    final gradient = RadialGradient(colors: [colors[0], colors[1]]);

    // Рисуем фон
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    // Добавляем тень
    if (isSelected || isHovered) {
      final shadowPaint = Paint()
        ..color = colors[0].withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius + 5, shadowPaint);
    }

    canvas.drawCircle(center, radius, paint);

    // Рисуем границу
    final borderPaint = Paint()
      ..color = isSelected ? Colors.white : Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 1.0;

    canvas.drawCircle(center, radius, borderPaint);

    // Рисуем эмодзи
    _drawEmoji(canvas, center, mood.emoji, radius * 0.6);
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

  void _drawEmoji(Canvas canvas, Offset center, String emoji, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: fontSize, color: Colors.white),
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

class InteractiveMoodSelector extends StatefulWidget {
  final MoodLevel? selectedMood;
  final Function(MoodLevel) onMoodSelected;
  final double size;
  final bool isVisible;

  const InteractiveMoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
    this.size = 300.0,
    this.isVisible = true,
  });

  @override
  State<InteractiveMoodSelector> createState() =>
      _InteractiveMoodSelectorState();
}

class _InteractiveMoodSelectorState extends State<InteractiveMoodSelector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final mood = _getMoodFromPosition(details.localPosition);
        if (mood != null) {
          widget.onMoodSelected(mood);
        }
      },
      onPanUpdate: (details) {
        final mood = _getMoodFromPosition(details.localPosition);
        if (mood != null) {
          widget.onMoodSelected(mood);
        }
      },
      child: MoodSelector(
        selectedMood: widget.selectedMood,
        onMoodSelected: widget.onMoodSelected,
        size: widget.size,
        isVisible: widget.isVisible,
      ),
    );
  }

  MoodLevel? _getMoodFromPosition(Offset position) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final radius = widget.size / 2 - 50;

    final angleStep = math.pi / (MoodLevel.values.length - 1);

    for (int i = 0; i < MoodLevel.values.length; i++) {
      final angle = -math.pi / 2 + (i * angleStep);

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final moodCenter = Offset(x, y);

      final distance = (position - moodCenter).distance;
      if (distance <= 30) {
        return MoodLevel.values[i];
      }
    }

    return null;
  }
}
