import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'animated_mood_icon.dart';
import 'liquid_blob_painter.dart';
import 'ripple_effect_painter.dart';

/// Главный виджет MoodBlob - центральный элемент приложения
///
/// Создает анимированный blob с жидкой формой, который реагирует на настроение
/// и создает ripple эффекты при тапе. Интегрирован с FAB для плавного перехода.
class MoodBlob extends StatefulWidget {
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

  const MoodBlob({
    super.key,
    required this.moodRating,
    this.size = 200.0,
    this.onTap,
    this.showMoodIcon = true,
    this.iconSize = 48.0,
  });

  @override
  State<MoodBlob> createState() => _MoodBlobState();
}

class _MoodBlobState extends State<MoodBlob> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _tapController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _tapAnimation;

  final List<RippleAnimation> _ripples = [];

  /// Время для анимации дыхания (очень медленное)
  static const Duration _breathingDuration = Duration(seconds: 4);

  /// Время для анимации тапа
  static const Duration _tapDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Контроллер для дыхания blob
    _breathingController = AnimationController(
      duration: _breathingDuration,
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Контроллер для анимации тапа
    _tapController = AnimationController(duration: _tapDuration, vsync: this);

    _tapAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.elasticOut),
    );

    // Запускаем дыхание
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Создаем ripple эффект
    _createRippleEffect();

    // Запускаем анимацию тапа
    _tapController.forward().then((_) {
      _tapController.reverse();
    });

    // Вызываем колбэк
    widget.onTap?.call();
  }

  void _createRippleEffect() {
    final ripple = RippleAnimation(
      center: Offset(widget.size / 2, widget.size / 2),
      maxRadius: widget.size / 2 + 50,
      duration: const Duration(milliseconds: 1500),
      startTime: DateTime.now(),
      color: Colors.white,
    );

    setState(() {
      _ripples.add(ripple);
    });

    // Удаляем старые ripple эффекты
    Future.delayed(ripple.duration, () {
      if (mounted) {
        setState(() {
          _ripples.removeWhere((r) => !r.isActive);
        });
      }
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
              // Основной blob
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
                    painter: LiquidBlobPainter(
                      animationTime: _breathingController.value * 2 * math.pi,
                      size: widget.size,
                      gradientColors: gradientColors,
                      distortionStrength: 0.4,
                      breathingSpeed: 1.0,
                      breathingScale: combinedScale,
                      center: Offset(widget.size / 2, widget.size / 2),
                    ),
                  );
                },
              ),

              // Ripple эффекты
              if (_ripples.isNotEmpty)
                AnimatedBuilder(
                  animation: _breathingController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: RippleEffectPainter(
                        ripples: _ripples,
                        rippleColor: Colors.white,
                      ),
                    );
                  },
                ),

              // Иконка настроения
              if (widget.showMoodIcon)
                AnimatedBuilder(
                  animation: _tapAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 / _tapAnimation.value,
                      child: AnimatedMoodIcon(
                        rating: widget.moodRating,
                        size: widget.iconSize,
                        animated:
                            false, // Отключаем анимацию, так как blob сам анимируется
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

/// Интегрированный FAB с MoodBlob
class MoodBlobWithFAB extends StatefulWidget {
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

  const MoodBlobWithFAB({
    super.key,
    required this.moodRating,
    this.size = 200.0,
    this.onTap,
    this.showFAB = true,
    this.fabSize = 56.0,
  });

  @override
  State<MoodBlobWithFAB> createState() => _MoodBlobWithFABState();
}

class _MoodBlobWithFABState extends State<MoodBlobWithFAB>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _fabPositionAnimation;

  final bool _isFABVisible = true;

  @override
  void initState() {
    super.initState();
    _initializeFABAnimations();
  }

  void _initializeFABAnimations() {
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _fabPositionAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack),
        );

    // Запускаем анимацию появления FAB
    _fabController.forward();
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
          // MoodBlob
          MoodBlob(
            moodRating: widget.moodRating,
            size: widget.size,
            onTap: widget.onTap,
          ),

          // FAB кольцо
          if (widget.showFAB && _isFABVisible)
            AnimatedBuilder(
              animation: _fabController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _fabPositionAnimation.value * 20,
                  child: Transform.scale(
                    scale: _fabScaleAnimation.value,
                    child: Container(
                      width: widget.fabSize,
                      height: widget.fabSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 3.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8.0,
                            spreadRadius: 2.0,
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
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
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
