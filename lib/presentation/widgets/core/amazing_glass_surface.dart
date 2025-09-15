import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Невероятный виджет стеклянной поверхности с анимированными градиентами и неоновыми эффектами
class AmazingGlassSurface extends StatefulWidget {
  /// Содержимое, которое будет отображаться внутри стеклянной поверхности
  final Widget child;

  /// Сила размытия фона
  final double blurStrength;

  /// Радиус скругления углов
  final BorderRadius borderRadius;

  /// Внутренние отступы
  final EdgeInsets padding;

  /// Тип эффекта
  final GlassEffectType effectType;

  /// Цветовая схема
  final ColorScheme colorScheme;

  const AmazingGlassSurface({
    super.key,
    required this.child,
    this.blurStrength = 15.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.padding = const EdgeInsets.all(20.0),
    this.effectType = GlassEffectType.rainbow,
    this.colorScheme = ColorScheme.neon,
  });

  @override
  State<AmazingGlassSurface> createState() => _AmazingGlassSurfaceState();
}

class _AmazingGlassSurfaceState extends State<AmazingGlassSurface>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _gradientController,
        _pulseController,
        _rotationController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: _getShadowColor().withOpacity(0.3),
                blurRadius: 20 + (_pulseController.value * 10),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: _getShadowColor().withOpacity(0.1),
                blurRadius: 40 + (_pulseController.value * 20),
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurStrength,
                sigmaY: widget.blurStrength,
              ),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius,
                  gradient: _buildGradient(),
                  border: Border.all(width: 2, color: _getBorderColor()),
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  Gradient _buildGradient() {
    switch (widget.effectType) {
      case GlassEffectType.rainbow:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getRainbowColors(),
          stops: [
            0.0,
            0.2 + (_gradientController.value * 0.1),
            0.4 + (_gradientController.value * 0.1),
            0.6 + (_gradientController.value * 0.1),
            0.8 + (_gradientController.value * 0.1),
            1.0,
          ],
        );
      case GlassEffectType.neon:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getNeonColors(),
          stops: [0.0, 0.5, 1.0],
        );
      case GlassEffectType.cyber:
        return RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: _getCyberColors(),
          stops: [0.0, 0.7, 1.0],
        );
      case GlassEffectType.cosmic:
        return SweepGradient(
          center: Alignment.center,
          startAngle: _rotationController.value * 2 * math.pi,
          endAngle: (_rotationController.value * 2 * math.pi) + (math.pi / 2),
          colors: _getCosmicColors(),
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        );
    }
  }

  List<Color> _getRainbowColors() {
    final colors = widget.colorScheme.primaryColors;
    return [
      colors[0].withOpacity(0.15 + (_pulseController.value * 0.05)),
      colors[1].withOpacity(0.12 + (_pulseController.value * 0.03)),
      colors[2].withOpacity(0.10 + (_pulseController.value * 0.02)),
      colors[3].withOpacity(0.08 + (_pulseController.value * 0.02)),
      colors[4].withOpacity(0.12 + (_pulseController.value * 0.03)),
      colors[5].withOpacity(0.15 + (_pulseController.value * 0.05)),
    ];
  }

  List<Color> _getNeonColors() {
    final colors = widget.colorScheme.neonColors;
    return [
      colors[0].withOpacity(0.2 + (_pulseController.value * 0.1)),
      colors[1].withOpacity(0.1 + (_pulseController.value * 0.05)),
      colors[2].withOpacity(0.2 + (_pulseController.value * 0.1)),
    ];
  }

  List<Color> _getCyberColors() {
    final colors = widget.colorScheme.cyberColors;
    return [
      colors[0].withOpacity(0.25),
      colors[1].withOpacity(0.15),
      colors[2].withOpacity(0.05),
    ];
  }

  List<Color> _getCosmicColors() {
    final colors = widget.colorScheme.cosmicColors;
    return [
      colors[0].withOpacity(0.2),
      colors[1].withOpacity(0.15),
      colors[2].withOpacity(0.1),
      colors[3].withOpacity(0.15),
      colors[4].withOpacity(0.2),
    ];
  }

  Color _getBorderColor() {
    final baseColor = widget.colorScheme.borderColor;
    return baseColor.withOpacity(0.6 + (_pulseController.value * 0.4));
  }

  Color _getShadowColor() {
    return widget.colorScheme.shadowColor;
  }
}

/// Типы эффектов стекла
enum GlassEffectType { rainbow, neon, cyber, cosmic }

/// Цветовые схемы
enum ColorScheme { neon, cyber, cosmic, rainbow }

/// Расширение для цветовых схем
extension ColorSchemeExtension on ColorScheme {
  List<Color> get primaryColors {
    switch (this) {
      case ColorScheme.neon:
        return [
          const Color(0xFF00FFFF), // Cyan
          const Color(0xFF00FF00), // Lime
          const Color(0xFFFF00FF), // Magenta
          const Color(0xFFFF0080), // Pink
          const Color(0xFF8000FF), // Purple
          const Color(0xFF0080FF), // Blue
        ];
      case ColorScheme.cyber:
        return [
          const Color(0xFF00FF41), // Matrix Green
          const Color(0xFF00D4FF), // Cyber Blue
          const Color(0xFFFF0040), // Cyber Red
          const Color(0xFFFFD700), // Cyber Gold
          const Color(0xFF8000FF), // Cyber Purple
          const Color(0xFF00FFFF), // Cyber Cyan
        ];
      case ColorScheme.cosmic:
        return [
          const Color(0xFF4A00E0), // Deep Purple
          const Color(0xFF8B5CF6), // Light Purple
          const Color(0xFF06B6D4), // Cyan
          const Color(0xFF10B981), // Emerald
          const Color(0xFFF59E0B), // Amber
          const Color(0xFFEF4444), // Red
        ];
      case ColorScheme.rainbow:
        return [
          const Color(0xFFFF0000), // Red
          const Color(0xFFFF8000), // Orange
          const Color(0xFFFFD700), // Yellow
          const Color(0xFF00FF00), // Green
          const Color(0xFF0080FF), // Blue
          const Color(0xFF8000FF), // Purple
        ];
    }
  }

  List<Color> get neonColors {
    switch (this) {
      case ColorScheme.neon:
        return [
          const Color(0xFF00FFFF),
          const Color(0xFF00FF00),
          const Color(0xFFFF00FF),
        ];
      case ColorScheme.cyber:
        return [
          const Color(0xFF00FF41),
          const Color(0xFF00D4FF),
          const Color(0xFFFF0040),
        ];
      case ColorScheme.cosmic:
        return [
          const Color(0xFF4A00E0),
          const Color(0xFF06B6D4),
          const Color(0xFFF59E0B),
        ];
      case ColorScheme.rainbow:
        return [
          const Color(0xFFFF0000),
          const Color(0xFF00FF00),
          const Color(0xFF0080FF),
        ];
    }
  }

  List<Color> get cyberColors {
    switch (this) {
      case ColorScheme.neon:
        return [
          const Color(0xFF00FFFF),
          const Color(0xFF0080FF),
          const Color(0xFF000000),
        ];
      case ColorScheme.cyber:
        return [
          const Color(0xFF00FF41),
          const Color(0xFF00D4FF),
          const Color(0xFF000000),
        ];
      case ColorScheme.cosmic:
        return [
          const Color(0xFF4A00E0),
          const Color(0xFF06B6D4),
          const Color(0xFF000000),
        ];
      case ColorScheme.rainbow:
        return [
          const Color(0xFFFF0000),
          const Color(0xFF00FF00),
          const Color(0xFF000000),
        ];
    }
  }

  List<Color> get cosmicColors {
    switch (this) {
      case ColorScheme.neon:
        return [
          const Color(0xFF00FFFF),
          const Color(0xFF00FF00),
          const Color(0xFFFF00FF),
          const Color(0xFFFF0080),
          const Color(0xFF8000FF),
        ];
      case ColorScheme.cyber:
        return [
          const Color(0xFF00FF41),
          const Color(0xFF00D4FF),
          const Color(0xFFFF0040),
          const Color(0xFFFFD700),
          const Color(0xFF8000FF),
        ];
      case ColorScheme.cosmic:
        return [
          const Color(0xFF4A00E0),
          const Color(0xFF8B5CF6),
          const Color(0xFF06B6D4),
          const Color(0xFF10B981),
          const Color(0xFFF59E0B),
        ];
      case ColorScheme.rainbow:
        return [
          const Color(0xFFFF0000),
          const Color(0xFFFF8000),
          const Color(0xFFFFD700),
          const Color(0xFF00FF00),
          const Color(0xFF0080FF),
        ];
    }
  }

  Color get borderColor {
    switch (this) {
      case ColorScheme.neon:
        return const Color(0xFF00FFFF);
      case ColorScheme.cyber:
        return const Color(0xFF00FF41);
      case ColorScheme.cosmic:
        return const Color(0xFF8B5CF6);
      case ColorScheme.rainbow:
        return const Color(0xFFFFD700);
    }
  }

  Color get shadowColor {
    switch (this) {
      case ColorScheme.neon:
        return const Color(0xFF00FFFF);
      case ColorScheme.cyber:
        return const Color(0xFF00FF41);
      case ColorScheme.cosmic:
        return const Color(0xFF8B5CF6);
      case ColorScheme.rainbow:
        return const Color(0xFFFFD700);
    }
  }
}
