import 'dart:ui';

import 'package:flutter/material.dart';

/// Переиспользуемый контейнер для создания эффекта матового стекла
///
/// Виджет создает красивый эффект размытого стекла с настраиваемыми параметрами.
/// Использует BackdropFilter для создания эффекта размытия фона и Container
/// с полупрозрачным фоном для имитации стеклянной поверхности.
class GlassSurface extends StatelessWidget {
  /// Содержимое, которое будет отображаться внутри стеклянной поверхности
  final Widget child;

  /// Сила размытия фона (значение sigma для ImageFilter.blur)
  ///
  /// Большие значения создают более сильное размытие.
  /// Рекомендуемые значения: 5.0 - 20.0
  final double blurStrength;

  /// Радиус скругления углов стеклянной поверхности
  final BorderRadius borderRadius;

  /// Базовый цвет поверхности стекла
  ///
  /// Обычно используется полупрозрачный белый или черный цвет
  /// для создания эффекта матового стекла
  final Color baseColor;

  /// Внутренние отступы от границ стеклянной поверхности
  final EdgeInsets padding;

  /// Толщина границы стеклянной поверхности
  final double borderWidth;

  /// Цвет границы стеклянной поверхности
  ///
  /// Обычно используется полупрозрачный цвет для создания
  /// тонкой светящейся границы
  final Color borderColor;

  const GlassSurface({
    super.key,
    required this.child,
    this.blurStrength = 10.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(20.0)),
    this.baseColor = const Color.fromRGBO(255, 255, 255, 0.07),
    this.padding = const EdgeInsets.all(16.0),
    this.borderWidth = 1.0,
    this.borderColor = const Color.fromRGBO(255, 255, 255, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurStrength,
              sigmaY: blurStrength,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: borderRadius,
                border: Border.all(width: borderWidth, color: borderColor),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Предустановленные стили для GlassSurface
class GlassSurfaceStyles {
  GlassSurfaceStyles._();

  /// Создает стиль для карточек с мягким размытием
  static GlassSurface card({required Widget child}) => GlassSurface(
    blurStrength: 8.0,
    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
    baseColor: const Color.fromRGBO(255, 255, 255, 0.05),
    borderWidth: 1.0,
    borderColor: const Color.fromRGBO(255, 255, 255, 0.08),
    child: child,
  );

  /// Создает стиль для модальных окон с сильным размытием
  static GlassSurface modal({required Widget child}) => GlassSurface(
    blurStrength: 15.0,
    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
    baseColor: const Color.fromRGBO(255, 255, 255, 0.1),
    borderWidth: 1.5,
    borderColor: const Color.fromRGBO(255, 255, 255, 0.15),
    padding: const EdgeInsets.all(24.0),
    child: child,
  );

  /// Создает стиль для кнопок с легким размытием
  static GlassSurface button({required Widget child}) => GlassSurface(
    blurStrength: 6.0,
    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    baseColor: const Color.fromRGBO(255, 255, 255, 0.08),
    borderWidth: 1.0,
    borderColor: const Color.fromRGBO(255, 255, 255, 0.12),
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: child,
  );

  /// Создает стиль для темной темы
  static GlassSurface dark({required Widget child}) => GlassSurface(
    blurStrength: 12.0,
    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
    baseColor: const Color.fromRGBO(0, 0, 0, 0.3),
    borderWidth: 1.0,
    borderColor: const Color.fromRGBO(255, 255, 255, 0.05),
    child: child,
  );
}
