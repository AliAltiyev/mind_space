import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Виджет для визуализации дыхания (пульсирующий круг)
class BreathingVisualization extends StatefulWidget {
  final Color color;
  final double size;

  const BreathingVisualization({
    super.key,
    this.color = Colors.blue,
    this.size = 200,
  });

  @override
  State<BreathingVisualization> createState() => _BreathingVisualizationState();
}

class _BreathingVisualizationState extends State<BreathingVisualization>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // 4 секунды на цикл дыхания
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.3),
              border: Border.all(color: widget.color, width: 3),
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
