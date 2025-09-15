import 'package:flutter/material.dart';

class AppDesign {
  // Основные цвета
  static const Color primaryBackground = Color(0xFF121212);
  static const Color secondaryBackground = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0x30FFFFFF);
  static const Color accentColor = Color(0xFF6D67E4);
  static const Color accentColorBright = Color(0xFF7B61FF);

  // Цвета текста
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  // Цвета настроений (градиенты)
  static const List<Color> verySadGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFC44569),
  ];

  static const List<Color> sadGradient = [Color(0xFFFF9E6B), Color(0xFFE77E7E)];

  static const List<Color> neutralGradient = [
    Color(0xFFFFD166),
    Color(0xFFF9A26C),
  ];

  static const List<Color> happyGradient = [
    Color(0xFF8ECDDD),
    Color(0xFF6D67E4),
  ];

  static const List<Color> veryHappyGradient = [
    Color(0xFF8ACB88),
    Color(0xFF59C3C3),
  ];

  // Дополнительные градиенты
  static const List<Color> primaryGradient = [
    Color(0xFF6D67E4),
    Color(0xFF7B61FF),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF121212),
    Color(0xFF1E1E1E),
  ];

  // Тени для неоморфизма
  static const List<BoxShadow> neumorphicShadows = [
    BoxShadow(
      color: Color(0x40FFFFFF),
      offset: Offset(-2, -2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(2, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> neumorphicShadowsPressed = [
    BoxShadow(
      color: Color(0x20FFFFFF),
      offset: Offset(-1, -1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x60000000),
      offset: Offset(1, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> glassShadows = [
    BoxShadow(
      color: Color(0x20FFFFFF),
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  // Радиусы скругления
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  // Отступы
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Размеры
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: AppDesign.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: AppDesign.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppDesign.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppDesign.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppDesign.textSecondary,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppDesign.textTertiary,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppDesign.textTertiary,
    letterSpacing: 0.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppDesign.textPrimary,
    letterSpacing: 0.5,
  );
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppDesign.primaryGradient,
  );

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppDesign.backgroundGradient,
  );

  static const LinearGradient verySad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppDesign.verySadGradient,
  );

  static const LinearGradient sad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppDesign.sadGradient,
  );

  static const LinearGradient neutral = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppDesign.neutralGradient,
  );

  static const LinearGradient happy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppDesign.happyGradient,
  );

  static const LinearGradient veryHappy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppDesign.veryHappyGradient,
  );

  static LinearGradient getMoodGradient(int moodValue) {
    switch (moodValue) {
      case 1:
        return verySad;
      case 2:
        return sad;
      case 3:
        return neutral;
      case 4:
        return happy;
      case 5:
        return veryHappy;
      default:
        return neutral;
    }
  }
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration verySlow = Duration(milliseconds: 800);

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve spring = Curves.elasticOut;
}

class AppShadows {
  static const List<BoxShadow> neumorphic = AppDesign.neumorphicShadows;
  static const List<BoxShadow> neumorphicPressed =
      AppDesign.neumorphicShadowsPressed;
  static const List<BoxShadow> glass = AppDesign.glassShadows;

  static List<BoxShadow> custom({
    required Color color,
    required Offset offset,
    required double blurRadius,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: color,
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}
