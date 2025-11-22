import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Анимированный фон для экрана сна с ночным небом
class SleepBackground extends StatefulWidget {
  final Widget child;

  const SleepBackground({super.key, required this.child});

  @override
  State<SleepBackground> createState() => _SleepBackgroundState();
}

class _SleepBackgroundState extends State<SleepBackground> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkBackground,
                  AppColors.darkSurface,
                  AppColors.darkBackground,
                ]
              : [
                  AppColors.background,
                  AppColors.surfaceVariant,
                  AppColors.border,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Тонкие декоративные элементы
          if (isDark)
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          if (isDark)
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Контент
          widget.child,
        ],
      ),
    );
  }
}
