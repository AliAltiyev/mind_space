import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'mood_blob_constants.dart';

/// Оптимизированный кастомный художник для создания жидкого blob с анимацией
///
/// Использует кэширование, оптимизированные вычисления и единую дизайн-систему
/// для создания максимально плавной и производительной анимации.
class OptimizedLiquidBlobPainter extends CustomPainter {
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

  /// Центр blob
  final Offset center;

  /// Кэшированные объекты для производительности
  ui.Paint? _cachedPaint;
  ui.Shader? _cachedGradient;
  ui.Shader? _cachedGlowGradient;
  Path? _cachedBlobPath;
  Path? _cachedGlowPath;
  double? _lastAnimationTime;
  double? _lastBreathingScale;
  List<Color>? _lastGradientColors;

  OptimizedLiquidBlobPainter({
    required this.animationTime,
    required this.size,
    required this.gradientColors,
    this.distortionStrength = MoodBlobConstants.distortionStrength,
    this.breathingSpeed = MoodBlobConstants.breathingSpeed,
    this.breathingScale = 1.0,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Кэшируем Paint объект
    _cachedPaint ??= Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Создаем градиентный шейдер
    final shader = _createOptimizedGradientShader();
    _cachedPaint!.shader = shader;

    // Создаем оптимизированный путь blob
    final blobPath = _createOptimizedBlobPath();
    canvas.drawPath(blobPath, _cachedPaint!);

    // Рисуем внутреннее свечение
    _drawOptimizedInnerGlow(canvas);
  }

  /// Создает оптимизированный градиентный шейдер с кэшированием
  ui.Shader _createOptimizedGradientShader() {
    // Проверяем, нужно ли обновить градиент
    if (_cachedGradient == null ||
        _lastGradientColors != gradientColors ||
        _lastBreathingScale != breathingScale) {
      final rect = Rect.fromCircle(
        center: center,
        radius: size / 2 * breathingScale,
      );

      _cachedGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
        stops: const [0.0, 1.0],
      ).createShader(rect);

      _lastGradientColors = List<Color>.from(gradientColors);
      _lastBreathingScale = breathingScale;
    }

    return _cachedGradient!;
  }

  /// Создает оптимизированный путь blob с кэшированием
  Path _createOptimizedBlobPath() {
    // Проверяем, нужно ли пересчитать путь
    if (_cachedBlobPath == null ||
        _lastAnimationTime != animationTime ||
        _lastBreathingScale != breathingScale) {
      _cachedBlobPath = _generateBlobPath();
      _lastAnimationTime = animationTime;
      _lastBreathingScale = breathingScale;
    }

    return _cachedBlobPath!;
  }

  /// Генерирует путь blob с оптимизированными вычислениями
  Path _generateBlobPath() {
    final path = Path();
    final radius = size / 2 * breathingScale;
    final numPoints = MoodBlobConstants.blobPoints;

    // Предварительно вычисляем константы
    final twoPi = 2 * math.pi;
    final angleStep = twoPi / numPoints;
    final timePhase1 = animationTime * breathingSpeed;
    final timePhase2 =
        animationTime * breathingSpeed * MoodBlobConstants.wave2PhaseShift;
    final timePhase3 =
        animationTime * breathingSpeed * MoodBlobConstants.wave3PhaseShift;

    final points = <Offset>[];

    for (int i = 0; i <= numPoints; i++) {
      final angle = i * angleStep;

      // Оптимизированные вычисления деформации
      final distortion1 =
          math.sin(angle * MoodBlobConstants.wave1Frequency + timePhase1) *
          distortionStrength *
          MoodBlobConstants.distortionWave1;

      final distortion2 =
          math.sin(angle * MoodBlobConstants.wave2Frequency + timePhase2) *
          distortionStrength *
          MoodBlobConstants.distortionWave2;

      final distortion3 =
          math.sin(angle * MoodBlobConstants.wave3Frequency + timePhase3) *
          distortionStrength *
          MoodBlobConstants.distortionWave3;

      final totalDistortion = 1 + distortion1 + distortion2 + distortion3;
      final currentRadius = radius * totalDistortion;

      final x = center.dx + math.cos(angle) * currentRadius;
      final y = center.dy + math.sin(angle) * currentRadius;

      points.add(Offset(x, y));
    }

    // Создаем оптимизированную кривую
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        final currentPoint = points[i];
        final previousPoint = points[i - 1];

        // Оптимизированная контрольная точка
        final controlPoint = Offset(
          (previousPoint.dx + currentPoint.dx) * 0.5,
          (previousPoint.dy + currentPoint.dy) * 0.5,
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

  /// Рисует оптимизированное внутреннее свечение
  void _drawOptimizedInnerGlow(Canvas canvas) {
    // Создаем градиент для свечения
    if (_cachedGlowGradient == null || _lastBreathingScale != breathingScale) {
      _cachedGlowGradient =
          RadialGradient(
            center: Alignment.center,
            radius: MoodBlobConstants.innerGlowRadius,
            colors: [
              Colors.white.withOpacity(MoodBlobConstants.innerGlowStartOpacity),
              Colors.white.withOpacity(MoodBlobConstants.innerGlowMidOpacity),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: center,
              radius:
                  size / 2 * breathingScale * MoodBlobConstants.innerGlowRadius,
            ),
          );
    }

    // Создаем путь для свечения
    final glowPath = _createOptimizedGlowPath();

    // Создаем Paint для свечения
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = _cachedGlowGradient
      ..isAntiAlias = true;

    canvas.drawPath(glowPath, glowPaint);
  }

  /// Создает оптимизированный путь для внутреннего свечения
  Path _createOptimizedGlowPath() {
    if (_cachedGlowPath == null ||
        _lastAnimationTime != animationTime ||
        _lastBreathingScale != breathingScale) {
      _cachedGlowPath = _generateGlowPath();
    }

    return _cachedGlowPath!;
  }

  /// Генерирует путь для внутреннего свечения
  Path _generateGlowPath() {
    final innerPath = Path();
    final innerRadius =
        (size / 2 * breathingScale) * MoodBlobConstants.innerPathRadius;
    final numPoints = MoodBlobConstants.glowPoints;

    // Предварительно вычисляем константы
    final twoPi = 2 * math.pi;
    final angleStep = twoPi / numPoints;
    final timePhase =
        animationTime * breathingSpeed * MoodBlobConstants.glowPhaseShift;

    for (int i = 0; i <= numPoints; i++) {
      final angle = i * angleStep;

      // Меньшая деформация для внутреннего свечения
      final distortion =
          math.sin(angle * MoodBlobConstants.glowWaveFrequency + timePhase) *
          distortionStrength *
          MoodBlobConstants.glowDistortion;

      final currentRadius = innerRadius * (1 + distortion);
      final x = center.dx + math.cos(angle) * currentRadius;
      final y = center.dy + math.sin(angle) * currentRadius;

      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }

    innerPath.close();
    return innerPath;
  }

  @override
  bool shouldRepaint(OptimizedLiquidBlobPainter oldDelegate) {
    // Оптимизированное сравнение
    return oldDelegate.animationTime != animationTime ||
        oldDelegate.size != size ||
        oldDelegate.distortionStrength != distortionStrength ||
        oldDelegate.breathingSpeed != breathingSpeed ||
        oldDelegate.breathingScale != breathingScale ||
        oldDelegate.center != center ||
        !_listEquals(oldDelegate.gradientColors, gradientColors);
  }

  /// Эффективное сравнение списков цветов
  bool _listEquals(List<Color>? a, List<Color>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Предустановленные градиенты для разных настроений
class MoodBlobGradients {
  MoodBlobGradients._();

  /// Очень плохое настроение (1) - глубокий серый
  static const List<Color> veryBad = [Color(0xFF4A5568), Color(0xFF2D3748)];

  /// Плохое настроение (2) - фиолетово-синий
  static const List<Color> bad = [Color(0xFF6B73FF), Color(0xFF9B59B6)];

  /// Нейтральное настроение (3) - голубой
  static const List<Color> neutral = [Color(0xFF74B9FF), Color(0xFF0984E3)];

  /// Хорошее настроение (4) - теплый желтый
  static const List<Color> good = [Color(0xFFFFEAA7), Color(0xFFFDCB6E)];

  /// Отличное настроение (5) - яркий розово-красный
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
