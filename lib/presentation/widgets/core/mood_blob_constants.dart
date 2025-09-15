import 'package:flutter/material.dart';

/// Константы для дизайн-системы MoodBlob
class MoodBlobConstants {
  MoodBlobConstants._();

  // === АНИМАЦИИ ===
  /// Единая кривая для всех анимаций
  static const Curve primaryCurve = Curves.easeOutQuart;

  /// Длительность дыхания blob
  static const Duration breathingDuration = Duration(seconds: 4);

  /// Длительность анимации тапа
  static const Duration tapDuration = Duration(milliseconds: 800);

  /// Длительность появления FAB
  static const Duration fabAppearDuration = Duration(milliseconds: 600);

  /// Длительность ripple эффекта
  static const Duration rippleDuration = Duration(milliseconds: 1500);

  // === РАЗМЕРЫ И МАСШТАБЫ ===
  /// Минимальный масштаб дыхания
  static const double breathingMinScale = 0.95;

  /// Максимальный масштаб дыхания
  static const double breathingMaxScale = 1.05;

  /// Масштаб при тапе
  static const double tapScale = 1.2;

  /// Сила деформации blob
  static const double distortionStrength = 0.4;

  /// Скорость дыхания
  static const double breathingSpeed = 1.0;

  /// Количество точек для создания гладкой кривой
  static const int blobPoints = 32;

  /// Количество точек для внутреннего свечения
  static const int glowPoints = 24;

  // === РАЗМЕРЫ ПО УМОЛЧАНИЮ ===
  /// Размер blob по умолчанию
  static const double defaultBlobSize = 200.0;

  /// Размер иконки настроения по умолчанию
  static const double defaultIconSize = 48.0;

  /// Размер FAB по умолчанию
  static const double defaultFabSize = 56.0;

  /// Размер иконки в FAB
  static const double fabIconSize = 24.0;

  // === ОТСТУПЫ И ПРОПОРЦИИ ===
  /// Коэффициент внутреннего свечения
  static const double innerGlowRadius = 0.8;

  /// Коэффициент внутреннего пути
  static const double innerPathRadius = 0.7;

  /// Дополнительный радиус для ripple
  static const double rippleExtraRadius = 50.0;

  /// Толщина границы FAB
  static const double fabBorderWidth = 3.0;

  /// Радиус размытия тени FAB
  static const double fabShadowBlur = 8.0;

  /// Распространение тени FAB
  static const double fabShadowSpread = 2.0;

  /// Смещение FAB при анимации
  static const double fabAnimationOffset = 20.0;

  // === ПРОЗРАЧНОСТЬ ===
  /// Прозрачность границы FAB
  static const double fabBorderOpacity = 0.8;

  /// Прозрачность тени FAB
  static const double fabShadowOpacity = 0.2;

  /// Прозрачность внутреннего свечения (начальная)
  static const double innerGlowStartOpacity = 0.3;

  /// Прозрачность внутреннего свечения (средняя)
  static const double innerGlowMidOpacity = 0.1;

  // === КОЭФФИЦИЕНТЫ ДЕФОРМАЦИИ ===
  /// Коэффициент первой волны деформации
  static const double distortionWave1 = 0.3;

  /// Коэффициент второй волны деформации
  static const double distortionWave2 = 0.2;

  /// Коэффициент третьей волны деформации
  static const double distortionWave3 = 0.1;

  /// Коэффициент деформации для внутреннего свечения
  static const double glowDistortion = 0.1;

  // === ЧАСТОТЫ ВОЛН ===
  /// Частота первой волны деформации
  static const double wave1Frequency = 3.0;

  /// Частота второй волны деформации
  static const double wave2Frequency = 5.0;

  /// Частота третьей волны деформации
  static const double wave3Frequency = 7.0;

  /// Частота волны внутреннего свечения
  static const double glowWaveFrequency = 2.0;

  // === ФАЗОВЫЕ СМЕЩЕНИЯ ===
  /// Фазовое смещение второй волны
  static const double wave2PhaseShift = 1.5;

  /// Фазовое смещение третьей волны
  static const double wave3PhaseShift = 0.8;

  /// Фазовое смещение волны свечения
  static const double glowPhaseShift = 0.5;
}

