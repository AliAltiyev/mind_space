import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Кастомный художник для ripple эффекта при тапе
class RippleEffectPainter extends CustomPainter {
  /// Список активных ripple эффектов
  final List<RippleAnimation> ripples;

  /// Цвет ripple эффекта
  final Color rippleColor;

  RippleEffectPainter({required this.ripples, this.rippleColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    for (final ripple in ripples) {
      if (ripple.isActive) {
        final paint = Paint()
          ..color = rippleColor.withOpacity(ripple.opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ripple.strokeWidth;

        canvas.drawCircle(ripple.center, ripple.radius, paint);

        // Рисуем дополнительные кольца для более реалистичного эффекта
        if (ripple.radius > 20) {
          final innerPaint = Paint()
            ..color = rippleColor.withOpacity(ripple.opacity * 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = ripple.strokeWidth * 0.7;

          canvas.drawCircle(ripple.center, ripple.radius * 0.7, innerPaint);
        }

        if (ripple.radius > 40) {
          final outerPaint = Paint()
            ..color = rippleColor.withOpacity(ripple.opacity * 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = ripple.strokeWidth * 0.5;

          canvas.drawCircle(ripple.center, ripple.radius * 1.3, outerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(RippleEffectPainter oldDelegate) {
    return oldDelegate.ripples != ripples ||
        oldDelegate.rippleColor != rippleColor;
  }
}

/// Класс для анимации ripple эффекта
class RippleAnimation {
  final Offset center;
  final double maxRadius;
  final Duration duration;
  final DateTime startTime;
  final Color color;
  final double maxStrokeWidth;

  RippleAnimation({
    required this.center,
    required this.maxRadius,
    required this.duration,
    required this.startTime,
    required this.color,
    this.maxStrokeWidth = 3.0,
  });

  /// Получает текущий радиус на основе прошедшего времени
  double get radius {
    final elapsed = DateTime.now().difference(startTime);
    final progress = (elapsed.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );

    // Используем easeOut кривую для более естественного эффекта
    final easedProgress = 1.0 - math.pow(1.0 - progress, 3);

    return maxRadius * easedProgress;
  }

  /// Получает текущую прозрачность
  double get opacity {
    final elapsed = DateTime.now().difference(startTime);
    final progress = (elapsed.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );

    // Прозрачность уменьшается с ростом радиуса
    return (1.0 - progress) * 0.8;
  }

  /// Получает текущую толщину линии
  double get strokeWidth {
    final elapsed = DateTime.now().difference(startTime);
    final progress = (elapsed.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );

    // Толщина уменьшается с ростом радиуса
    return maxStrokeWidth * (1.0 - progress * 0.7);
  }

  /// Проверяет, активен ли ripple эффект
  bool get isActive {
    final elapsed = DateTime.now().difference(startTime);
    return elapsed < duration && opacity > 0.01;
  }
}
