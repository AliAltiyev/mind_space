import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Дополнительные улучшения для MoodBlob
class MoodBlobImprovements {
  MoodBlobImprovements._();

  // === МИКРО-АНИМАЦИИ ===

  /// Создает анимацию пульсации при hover
  static Animation<double> createHoverPulseAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  /// Создает анимацию свечения при focus
  static Animation<double> createFocusGlowAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutQuart));
  }

  // === ПАРАЛЛАКС ЭФФЕКТЫ ===

  /// Создает параллакс эффект для фона
  static Widget createParallaxBackground({
    required double animationValue,
    required Widget child,
    double intensity = 0.1,
  }) {
    final offset = math.sin(animationValue * 2 * math.pi) * intensity * 20;

    return Transform.translate(offset: Offset(offset, 0), child: child);
  }

  /// Создает волновой эффект для фона
  static Widget createWaveBackground({
    required double animationValue,
    required Widget child,
    double amplitude = 10.0,
  }) {
    final waveOffset = math.sin(animationValue * 2 * math.pi) * amplitude;

    return Transform.translate(offset: Offset(0, waveOffset), child: child);
  }

  // === АНИМАЦИИ ПЕРЕХОДА МЕЖДУ ТЕМАМИ ===

  /// Создает плавный переход между темами
  static Animation<Color?> createThemeTransitionAnimation(
    AnimationController controller,
    Color fromColor,
    Color toColor,
  ) {
    return ColorTween(begin: fromColor, end: toColor).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutQuart),
    );
  }

  /// Создает анимацию изменения размера при смене темы
  static Animation<double> createThemeScaleAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
  }

  // === ИНТЕРАКТИВНЫЕ ЭФФЕКТЫ ===

  /// Создает эффект магнитного притяжения
  static Widget createMagneticEffect({
    required Widget child,
    required VoidCallback onMagneticPull,
    double threshold = 50.0,
  }) {
    return GestureDetector(
      onPanUpdate: (details) {
        final center = const Offset(100, 100); // Центр виджета
        final distance = math.sqrt(
          math.pow(details.localPosition.dx - center.dx, 2) +
              math.pow(details.localPosition.dy - center.dy, 2),
        );

        if (distance < threshold) {
          onMagneticPull();
        }
      },
      child: child,
    );
  }

  /// Создает эффект резиновой ленты
  static Widget createRubberBandEffect({
    required Widget child,
    required AnimationController controller,
  }) {
    final animation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(scale: animation.value, child: child);
      },
      child: child,
    );
  }

  // === ПРОДВИНУТЫЕ RIPPLE ЭФФЕКТЫ ===

  /// Создает каскадный ripple эффект
  static List<Animation<double>> createCascadingRipples(
    TickerProvider tickerProvider,
    int rippleCount,
  ) {
    final ripples = <Animation<double>>[];

    for (int i = 0; i < rippleCount; i++) {
      final delay = i * 0.1;
      final controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: tickerProvider,
      );

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart),
      );

      ripples.add(animation);

      // Запускаем с задержкой
      Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
        controller.forward();
      });
    }

    return ripples;
  }

  // === ОПТИМИЗАЦИЯ ПРОИЗВОДИТЕЛЬНОСТИ ===

  /// Создает оптимизированный RepaintBoundary
  static Widget createOptimizedRepaintBoundary({
    required Widget child,
    String? debugLabel,
  }) {
    return RepaintBoundary(child: child);
  }

  /// Создает кэшированный CustomPainter
  static Widget createCachedCustomPainter({
    required CustomPainter painter,
    required Size size,
    Widget? child,
  }) {
    return CustomPaint(size: size, painter: painter, child: child);
  }

  // === ДОСТУПНОСТЬ ===

  /// Создает семантическую метку для MoodBlob
  static Widget createSemanticMoodBlob({
    required Widget child,
    required int moodRating,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: 'Mood rating: $moodRating out of 5',
      hint: 'Tap to change mood rating',
      onTap: onTap,
      child: child,
    );
  }

  /// Создает анимацию для пользователей с ограниченными возможностями
  static Widget createAccessibleAnimation({
    required Widget child,
    required AnimationController controller,
    required bool enableAnimations,
  }) {
    if (enableAnimations) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) => child!,
        child: child,
      );
    } else {
      return child;
    }
  }
}

/// Расширения для дополнительной функциональности
extension MoodBlobExtensions on Widget {
  /// Добавляет эффект свечения
  Widget withGlow({
    Color color = Colors.white,
    double blurRadius = 10.0,
    double spreadRadius = 2.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Добавляет эффект размытия фона
  Widget withBackdropBlur({double sigmaX = 10.0, double sigmaY = 10.0}) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: this,
    );
  }

  /// Добавляет эффект градиентной маски
  Widget withGradientMask({required Gradient gradient}) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: this,
    );
  }
}
