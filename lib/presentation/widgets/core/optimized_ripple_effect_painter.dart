import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Оптимизированный кастомный художник для ripple эффекта при тапе
class OptimizedRippleEffectPainter extends CustomPainter {
  /// Список активных ripple эффектов
  final List<RippleAnimation> ripples;

  /// Цвет ripple эффекта
  final Color rippleColor;

  OptimizedRippleEffectPainter({
    required this.ripples,
    this.rippleColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Кэшируем Paint объекты для производительности
    Paint? mainPaint;
    Paint? innerPaint;
    Paint? outerPaint;

    for (final ripple in ripples) {
      if (ripple.isActive) {
        // Основной ripple
        mainPaint ??= Paint()
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;

        mainPaint.color = rippleColor.withOpacity(ripple.opacity);
        mainPaint.strokeWidth = ripple.strokeWidth;

        canvas.drawCircle(ripple.center, ripple.radius, mainPaint);

        // Дополнительные кольца для реалистичности
        if (ripple.radius > 20) {
          innerPaint ??= Paint()
            ..style = PaintingStyle.stroke
            ..isAntiAlias = true;

          innerPaint.color = rippleColor.withOpacity(ripple.opacity * 0.5);
          innerPaint.strokeWidth = ripple.strokeWidth * 0.7;

          canvas.drawCircle(ripple.center, ripple.radius * 0.7, innerPaint);
        }

        if (ripple.radius > 40) {
          outerPaint ??= Paint()
            ..style = PaintingStyle.stroke
            ..isAntiAlias = true;

          outerPaint.color = rippleColor.withOpacity(ripple.opacity * 0.3);
          outerPaint.strokeWidth = ripple.strokeWidth * 0.5;

          canvas.drawCircle(ripple.center, ripple.radius * 1.3, outerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(OptimizedRippleEffectPainter oldDelegate) {
    // Оптимизированное сравнение списков
    if (oldDelegate.ripples.length != ripples.length) return true;
    if (oldDelegate.rippleColor != rippleColor) return true;

    for (int i = 0; i < ripples.length; i++) {
      if (oldDelegate.ripples[i] != ripples[i]) return true;
    }

    return false;
  }
}

/// Оптимизированный класс для анимации ripple эффекта
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

    // Используем easeOutQuart кривую для более естественного эффекта
    final easedProgress = 1.0 - math.pow(1.0 - progress, 4);

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RippleAnimation &&
        other.center == center &&
        other.maxRadius == maxRadius &&
        other.duration == duration &&
        other.startTime == startTime &&
        other.color == color &&
        other.maxStrokeWidth == maxStrokeWidth;
  }

  @override
  int get hashCode {
    return Object.hash(
      center,
      maxRadius,
      duration,
      startTime,
      color,
      maxStrokeWidth,
    );
  }
}
