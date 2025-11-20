import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../../core/constants/app_typography.dart';

/// Красивая карточка для экрана сна с glassmorphism эффектом
class SleepCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const SleepCard({
    super.key,
    required this.child,
    this.glowColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = glowColor ?? theme.colorScheme.primary;

    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          if (glowColor != null)
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: -5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Карточка статистики сна
class SleepStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;

  const SleepStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = color ?? theme.colorScheme.primary;

    return SleepCard(
      glowColor: cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cardColor, size: 32),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? Colors.white60
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
