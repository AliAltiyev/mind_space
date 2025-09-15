import 'package:flutter/material.dart';

/// Цвета приложения
class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color secondaryVariant = Color(0xFFDB2777);

  // Семантические цвета
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Цвета настроений
  static const Color veryHappy = Color(0xFF10B981); // Emerald
  static const Color happy = Color(0xFF84CC16); // Lime
  static const Color neutral = Color(0xFFF59E0B); // Amber
  static const Color sad = Color(0xFFF97316); // Orange
  static const Color verySad = Color(0xFFEF4444); // Red

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient moodGradient = LinearGradient(
    colors: [veryHappy, happy, neutral, sad, verySad],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Стеклянные эффекты
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Приватный конструктор
  AppColors._();
}

