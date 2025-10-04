import 'package:flutter/material.dart';

/// Цвета приложения - Color Hunt Palette
/// https://colorhunt.co/palette/fcef91fb9e3ae6521fea2f14
class AppColors {
  // Основные цвета из Color Hunt палитры
  static const Color primary = Color(0xFFFB9E3A); // Vibrant Orange
  static const Color primaryVariant = Color(0xFFE6521F); // Deep Orange-Red
  static const Color secondary = Color(0xFFEA2F14); // Rich Red
  static const Color secondaryVariant = Color(0xFFFCEF91); // Warm Yellow/Cream

  // Семантические цвета
  static const Color success = Color(0xFFFCEF91); // Warm Yellow/Cream
  static const Color warning = Color(0xFFFB9E3A); // Vibrant Orange
  static const Color error = Color(0xFFEA2F14); // Rich Red
  static const Color info = Color(0xFFE6521F); // Deep Orange-Red

  // Цвета настроений (от плохого к хорошему)
  static const Color verySad = Color(0xFFEA2F14); // Rich Red - очень плохо
  static const Color sad = Color(0xFFE6521F); // Deep Orange-Red - плохо
  static const Color neutral = Color(0xFFFB9E3A); // Vibrant Orange - нормально
  static const Color happy = Color(0xFFFCEF91); // Warm Yellow/Cream - хорошо
  static const Color veryHappy = Color(0xFFFCEF91); // Warm Yellow/Cream - отлично

  // Градиенты с новой палитрой
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient moodGradient = LinearGradient(
    colors: [veryHappy, happy, neutral, sad, verySad],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Новые градиенты для Color Hunt палитры
  static const LinearGradient warmGradient = LinearGradient(
    colors: [secondaryVariant, primary, primaryVariant, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [primary, primaryVariant, secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Стеклянные эффекты
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Приватный конструктор
  AppColors._();
}

