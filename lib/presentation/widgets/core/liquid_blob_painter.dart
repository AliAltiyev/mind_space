import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Кастомный художник для создания жидкого blob с анимацией
///
/// Использует синусоидальные функции для создания органичной формы,
/// которая плавно изменяется во времени, имитируя движение жидкости.
class LiquidBlobPainter extends CustomPainter {
  /// Время анимации для создания плавного движения
  final double animationTime;

  /// Размер blob
  final double size;

  /// Цвета градиента для настроения
  final List<Color> gradientColors;

  /// Сила деформации (0.0 - круг, 1.0 - максимальная деформация)
  final double distortionStrength;

  /// Скорость анимации дыхания
  final double breathingSpeed;

  /// Масштаб дыхания (1.0 = без изменения размера)
  final double breathingScale;

  /// Точки для создания ripple эффекта
  final List<RipplePoint> ripplePoints;

  /// Центр blob
  final Offset center;

  LiquidBlobPainter({
    required this.animationTime,
    required this.size,
    required this.gradientColors,
    this.distortionStrength = 0.3,
    this.breathingSpeed = 1.0,
    this.breathingScale = 1.0,
    this.ripplePoints = const [],
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = _createGradientShader();

    final path = _createBlobPath();

    // Рисуем основную форму blob
    canvas.drawPath(path, paint);

    // Рисуем ripple эффекты
    _drawRippleEffects(canvas);

    // Рисуем внутреннее свечение
    _drawInnerGlow(canvas, path);
  }

  /// Создает градиентный шейдер для blob
  Shader _createGradientShader() {
    final rect = Rect.fromCircle(
      center: center,
      radius: size / 2 * breathingScale,
    );

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
      stops: const [0.0, 1.0],
    ).createShader(rect);
  }

  /// Создает путь blob с органичной формой
  Path _createBlobPath() {
    final path = Path();
    final radius = size / 2 * breathingScale;
    final numPoints = 32; // Количество точек для создания гладкой кривой

    // Генерируем точки по окружности с деформацией
    final points = <Offset>[];

    for (int i = 0; i <= numPoints; i++) {
      final angle = (i / numPoints) * 2 * math.pi;
      final baseRadius = radius;

      // Применяем синусоидальную деформацию
      final distortion1 =
          math.sin(angle * 3 + animationTime * breathingSpeed) *
          distortionStrength *
          0.3;
      final distortion2 =
          math.sin(angle * 5 + animationTime * breathingSpeed * 1.5) *
          distortionStrength *
          0.2;
      final distortion3 =
          math.sin(angle * 7 + animationTime * breathingSpeed * 0.8) *
          distortionStrength *
          0.1;

      final currentRadius =
          baseRadius * (1 + distortion1 + distortion2 + distortion3);

      final x = center.dx + math.cos(angle) * currentRadius;
      final y = center.dy + math.sin(angle) * currentRadius;

      points.add(Offset(x, y));
    }

    // Создаем плавную кривую через точки
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        final currentPoint = points[i];
        final previousPoint = points[i - 1];

        // Используем квадратичную кривую для плавности
        final controlPoint = Offset(
          (previousPoint.dx + currentPoint.dx) / 2,
          (previousPoint.dy + currentPoint.dy) / 2,
        );

        path.quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          currentPoint.dx,
          currentPoint.dy,
        );
      }

      path.close();
    }

    return path;
  }

  /// Рисует ripple эффекты от тапов
  void _drawRippleEffects(Canvas canvas) {
    for (final ripple in ripplePoints) {
      if (ripple.isActive) {
        final paint = Paint()
          ..color = ripple.color.withOpacity(ripple.opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ripple.strokeWidth;

        canvas.drawCircle(ripple.center, ripple.radius, paint);
      }
    }
  }

  /// Рисует внутреннее свечение blob
  void _drawInnerGlow(Canvas canvas, Path path) {
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader =
          RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: center,
              radius: size / 2 * breathingScale * 0.8,
            ),
          );

    // Создаем внутренний путь для свечения
    final innerPath = Path();
    final innerRadius = (size / 2 * breathingScale) * 0.7;
    final numPoints = 24;

    for (int i = 0; i <= numPoints; i++) {
      final angle = (i / numPoints) * 2 * math.pi;
      final baseRadius = innerRadius;

      // Меньшая деформация для внутреннего свечения
      final distortion =
          math.sin(angle * 2 + animationTime * breathingSpeed * 0.5) *
          distortionStrength *
          0.1;
      final currentRadius = baseRadius * (1 + distortion);

      final x = center.dx + math.cos(angle) * currentRadius;
      final y = center.dy + math.sin(angle) * currentRadius;

      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }

    innerPath.close();
    canvas.drawPath(innerPath, glowPaint);
  }

  @override
  bool shouldRepaint(LiquidBlobPainter oldDelegate) {
    return oldDelegate.animationTime != animationTime ||
        oldDelegate.size != size ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.distortionStrength != distortionStrength ||
        oldDelegate.breathingSpeed != breathingSpeed ||
        oldDelegate.breathingScale != breathingScale ||
        oldDelegate.ripplePoints != ripplePoints ||
        oldDelegate.center != center;
  }
}

/// Класс для представления ripple эффекта
class RipplePoint {
  final Offset center;
  final double radius;
  final double opacity;
  final Color color;
  final double strokeWidth;
  final bool isActive;

  const RipplePoint({
    required this.center,
    required this.radius,
    required this.opacity,
    required this.color,
    this.strokeWidth = 2.0,
    this.isActive = true,
  });

  RipplePoint copyWith({
    Offset? center,
    double? radius,
    double? opacity,
    Color? color,
    double? strokeWidth,
    bool? isActive,
  }) {
    return RipplePoint(
      center: center ?? this.center,
      radius: radius ?? this.radius,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RipplePoint &&
        other.center == center &&
        other.radius == radius &&
        other.opacity == opacity &&
        other.color == color &&
        other.strokeWidth == strokeWidth &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(center, radius, opacity, color, strokeWidth, isActive);
  }
}

/// Предустановленные градиенты для разных настроений
class MoodBlobGradients {
  MoodBlobGradients._();

  /// Очень плохое настроение (1)
  static const List<Color> veryBad = [Color(0xFF4A5568), Color(0xFF2D3748)];

  /// Плохое настроение (2)
  static const List<Color> bad = [Color(0xFF6B73FF), Color(0xFF9B59B6)];

  /// Нейтральное настроение (3)
  static const List<Color> neutral = [Color(0xFF74B9FF), Color(0xFF0984E3)];

  /// Хорошее настроение (4)
  static const List<Color> good = [Color(0xFFFFEAA7), Color(0xFFFDCB6E)];

  /// Отличное настроение (5)
  static const List<Color> excellent = [Color(0xFFFF7675), Color(0xFFE84393)];

  /// Получить градиент по рейтингу настроения
  static List<Color> getGradientForRating(int rating) {
    switch (rating) {
      case 1:
        return veryBad;
      case 2:
        return bad;
      case 3:
        return neutral;
      case 4:
        return good;
      case 5:
        return excellent;
      default:
        return neutral;
    }
  }
}

