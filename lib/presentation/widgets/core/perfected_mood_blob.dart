import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'animated_mood_icon.dart';
import 'mood_blob_constants.dart';
import 'optimized_liquid_blob_painter.dart';
import 'optimized_ripple_effect_painter.dart';

/// Совершенный виджет MoodBlob - центральный элемент приложения
///
/// Использует оптимизированные анимации, кэширование и единую дизайн-систему
/// для создания максимально плавного и производительного пользовательского опыта.
class PerfectedMoodBlob extends StatefulWidget {
  /// Рейтинг настроения от 1 до 5
  final int moodRating;

  /// Размер blob
  final double size;

  /// Колбэк при тапе на blob
  final VoidCallback? onTap;

  /// Показывать ли иконку настроения внутри blob
  final bool showMoodIcon;

  /// Размер иконки настроения
  final double iconSize;

  /// Включить ли параллакс эффект
  final bool enableParallax;

  const PerfectedMoodBlob({
    super.key,
    required this.moodRating,
    this.size = MoodBlobConstants.defaultBlobSize,
    this.onTap,
    this.showMoodIcon = true,
    this.iconSize = MoodBlobConstants.defaultIconSize,
    this.enableParallax = false,
  });

  @override
  State<PerfectedMoodBlob> createState() => _PerfectedMoodBlobState();
}

class _PerfectedMoodBlobState extends State<PerfectedMoodBlob>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _tapController;
  late AnimationController _parallaxController;

  late Animation<double> _breathingAnimation;
  late Animation<double> _tapAnimation;
  late Animation<double> _parallaxAnimation;

  final List<RippleAnimation> _ripples = [];

  /// Таймер для очистки неактивных ripple эффектов
  Timer? _rippleCleanupTimer;

  @override
  void initState() {
    super.initState();
    _initializeOptimizedAnimations();
    _startRippleCleanupTimer();
  }

  /// Инициализация оптимизированных анимаций
  void _initializeOptimizedAnimations() {
    // Контроллер для дыхания blob
    _breathingController = AnimationController(
      duration: MoodBlobConstants.breathingDuration,
      vsync: this,
    );

    _breathingAnimation =
        Tween<double>(
          begin: MoodBlobConstants.breathingMinScale,
          end: MoodBlobConstants.breathingMaxScale,
        ).animate(
          CurvedAnimation(
            parent: _breathingController,
            curve: MoodBlobConstants.primaryCurve,
          ),
        );

    // Контроллер для анимации тапа
    _tapController = AnimationController(
      duration: MoodBlobConstants.tapDuration,
      vsync: this,
    );

    _tapAnimation = Tween<double>(begin: 1.0, end: MoodBlobConstants.tapScale)
        .animate(
          CurvedAnimation(parent: _tapController, curve: Curves.elasticOut),
        );

    // Контроллер для параллакс эффекта
    if (widget.enableParallax) {
      _parallaxController = AnimationController(
        duration: const Duration(seconds: 8),
        vsync: this,
      );

      _parallaxAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _parallaxController, curve: Curves.easeInOut),
      );

      _parallaxController.repeat();
    }

    // Запускаем дыхание
    _breathingController.repeat(reverse: true);
  }

  /// Запуск таймера для очистки ripple эффектов
  void _startRippleCleanupTimer() {
    _rippleCleanupTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _cleanupInactiveRipples(),
    );
  }

  /// Очистка неактивных ripple эффектов
  void _cleanupInactiveRipples() {
    final initialCount = _ripples.length;
    _ripples.removeWhere((ripple) => !ripple.isActive);

    // Обновляем UI только если что-то изменилось
    if (_ripples.length != initialCount && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _tapController.dispose();
    _parallaxController.dispose();
    _rippleCleanupTimer?.cancel();
    super.dispose();
  }

  /// Обработка тапа с оптимизированной анимацией
  void _handleTap() {
    // Создаем ripple эффект без setState
    _createOptimizedRippleEffect();

    // Запускаем анимацию тапа
    _tapController.forward().then((_) {
      _tapController.reverse();
    });

    // Вызываем колбэк
    widget.onTap?.call();
  }

  /// Создание оптимизированного ripple эффекта
  void _createOptimizedRippleEffect() {
    final ripple = RippleAnimation(
      center: Offset(widget.size / 2, widget.size / 2),
      maxRadius: widget.size / 2 + MoodBlobConstants.rippleExtraRadius,
      duration: MoodBlobConstants.rippleDuration,
      startTime: DateTime.now(),
      color: Colors.white,
    );

    setState(() {
      _ripples.add(ripple);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = MoodBlobGradients.getGradientForRating(
      widget.moodRating,
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTap: _handleTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Основной blob с оптимизированным painter
              AnimatedBuilder(
                animation: Listenable.merge([
                  _breathingAnimation,
                  _tapAnimation,
                ]),
                builder: (context, child) {
                  final breathingScale = _breathingAnimation.value;
                  final tapScale = _tapAnimation.value;
                  final combinedScale = breathingScale * tapScale;

                  return CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: OptimizedLiquidBlobPainter(
                      animationTime: _breathingController.value * 2 * math.pi,
                      size: widget.size,
                      gradientColors: gradientColors,
                      distortionStrength: MoodBlobConstants.distortionStrength,
                      breathingSpeed: MoodBlobConstants.breathingSpeed,
                      breathingScale: combinedScale,
                      center: Offset(widget.size / 2, widget.size / 2),
                    ),
                  );
                },
              ),

              // Оптимизированные ripple эффекты
              if (_ripples.isNotEmpty)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: OptimizedRippleEffectPainter(
                    ripples: _ripples,
                    rippleColor: Colors.white,
                  ),
                ),

              // Иконка настроения с микро-анимацией
              if (widget.showMoodIcon)
                AnimatedBuilder(
                  animation: _tapAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 / _tapAnimation.value,
                      child: AnimatedMoodIcon(
                        rating: widget.moodRating,
                        size: widget.iconSize,
                        animated: false,
                      ),
                    );
                  },
                ),

              // Параллакс эффект для фона (если включен)
              if (widget.enableParallax)
                AnimatedBuilder(
                  animation: _parallaxAnimation,
                  builder: (context, child) {
                    final parallaxOffset =
                        math.sin(_parallaxAnimation.value * 2 * math.pi) * 4;
                    return Transform.translate(
                      offset: Offset(parallaxOffset, 0),
                      child: Container(
                        width: widget.size * 0.3,
                        height: widget.size * 0.3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Совершенный интегрированный FAB с MoodBlob
class PerfectedMoodBlobWithFAB extends StatefulWidget {
  /// Рейтинг настроения от 1 до 5
  final int moodRating;

  /// Размер blob
  final double size;

  /// Колбэк при тапе
  final VoidCallback? onTap;

  /// Показывать ли FAB
  final bool showFAB;

  /// Размер FAB
  final double fabSize;

  /// Включить ли анимацию появления
  final bool enableEntranceAnimation;

  const PerfectedMoodBlobWithFAB({
    super.key,
    required this.moodRating,
    this.size = MoodBlobConstants.defaultBlobSize,
    this.onTap,
    this.showFAB = true,
    this.fabSize = MoodBlobConstants.defaultFabSize,
    this.enableEntranceAnimation = true,
  });

  @override
  State<PerfectedMoodBlobWithFAB> createState() =>
      _PerfectedMoodBlobWithFABState();
}

class _PerfectedMoodBlobWithFABState extends State<PerfectedMoodBlobWithFAB>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _fabPositionAnimation;
  late Animation<double> _fabRotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeOptimizedFABAnimations();
  }

  /// Инициализация оптимизированных FAB анимаций
  void _initializeOptimizedFABAnimations() {
    _fabController = AnimationController(
      duration: MoodBlobConstants.fabAppearDuration,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: MoodBlobConstants.primaryCurve,
      ),
    );

    _fabPositionAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack),
        );

    _fabRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: MoodBlobConstants.primaryCurve,
      ),
    );

    // Запускаем анимацию появления FAB с задержкой
    if (widget.enableEntranceAnimation) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _fabController.forward();
      });
    } else {
      _fabController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Совершенный MoodBlob
          PerfectedMoodBlob(
            moodRating: widget.moodRating,
            size: widget.size,
            onTap: widget.onTap,
            enableParallax: true,
          ),

          // Совершенный FAB кольцо
          if (widget.showFAB)
            AnimatedBuilder(
              animation: _fabController,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      _fabPositionAnimation.value *
                      MoodBlobConstants.fabAnimationOffset,
                  child: Transform.scale(
                    scale: _fabScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _fabRotationAnimation.value,
                      child: Container(
                        width: widget.fabSize,
                        height: widget.fabSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              MoodBlobConstants.fabBorderOpacity,
                            ),
                            width: MoodBlobConstants.fabBorderWidth,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                MoodBlobConstants.fabShadowOpacity,
                              ),
                              blurRadius: MoodBlobConstants.fabShadowBlur,
                              spreadRadius: MoodBlobConstants.fabShadowSpread,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              widget.fabSize / 2,
                            ),
                            onTap: widget.onTap,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: MoodBlobConstants.fabIconSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
