import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Расширение темы для кастомных цветов
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.secondaryVariant,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.veryHappy,
    required this.happy,
    required this.neutral,
    required this.sad,
    required this.verySad,
    required this.glassBackground,
    required this.glassBorder,
  });

  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color secondaryVariant;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color veryHappy;
  final Color happy;
  final Color neutral;
  final Color sad;
  final Color verySad;
  final Color glassBackground;
  final Color glassBorder;

  @override
  AppThemeExtension copyWith({
    Color? primary,
    Color? primaryVariant,
    Color? secondary,
    Color? secondaryVariant,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? veryHappy,
    Color? happy,
    Color? neutral,
    Color? sad,
    Color? verySad,
    Color? glassBackground,
    Color? glassBorder,
  }) {
    return AppThemeExtension(
      primary: primary ?? this.primary,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      secondary: secondary ?? this.secondary,
      secondaryVariant: secondaryVariant ?? this.secondaryVariant,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      veryHappy: veryHappy ?? this.veryHappy,
      happy: happy ?? this.happy,
      neutral: neutral ?? this.neutral,
      sad: sad ?? this.sad,
      verySad: verySad ?? this.verySad,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryVariant: Color.lerp(primaryVariant, other.primaryVariant, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryVariant: Color.lerp(
        secondaryVariant,
        other.secondaryVariant,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      veryHappy: Color.lerp(veryHappy, other.veryHappy, t)!,
      happy: Color.lerp(happy, other.happy, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      sad: Color.lerp(sad, other.sad, t)!,
      verySad: Color.lerp(verySad, other.verySad, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
    );
  }

  /// Светлая тема
  static const AppThemeExtension light = AppThemeExtension(
    primary: AppColors.primary,
    primaryVariant: AppColors.primaryVariant,
    secondary: AppColors.secondary,
    secondaryVariant: AppColors.secondaryVariant,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    veryHappy: AppColors.veryHappy,
    happy: AppColors.happy,
    neutral: AppColors.neutral,
    sad: AppColors.sad,
    verySad: AppColors.verySad,
    glassBackground: AppColors.glassBackground,
    glassBorder: AppColors.glassBorder,
  );

  /// Темная тема
  static const AppThemeExtension dark = AppThemeExtension(
    primary: AppColors.primary,
    primaryVariant: AppColors.primaryVariant,
    secondary: AppColors.secondary,
    secondaryVariant: AppColors.secondaryVariant,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    veryHappy: AppColors.veryHappy,
    happy: AppColors.happy,
    neutral: AppColors.neutral,
    sad: AppColors.sad,
    verySad: AppColors.verySad,
    glassBackground: Color(0x1A000000),
    glassBorder: Color(0x33000000),
  );
}

/// Расширение для получения кастомных цветов из темы
extension AppThemeExtensionGetter on ThemeData {
  AppThemeExtension get appColors => extension<AppThemeExtension>()!;
}

