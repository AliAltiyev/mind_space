import 'package:flutter/material.dart';

/// Цветовая схема приложения - строгая и профессиональная
class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFF2E7D32); // Темно-зеленый
  static const Color primaryLight = Color(0xFF4CAF50); // Светло-зеленый
  static const Color primaryDark = Color(0xFF1B5E20); // Очень темно-зеленый
  
  // Вторичные цвета
  static const Color secondary = Color(0xFF1976D2); // Синий
  static const Color secondaryLight = Color(0xFF42A5F5); // Светло-синий
  
  // Нейтральные цвета
  static const Color background = Color(0xFFFAFAFA); // Светло-серый фон
  static const Color surface = Colors.white; // Белая поверхность
  static const Color card = Colors.white; // Белые карточки
  
  // Текст
  static const Color textPrimary = Color(0xFF212121); // Основной текст
  static const Color textSecondary = Color(0xFF757575); // Вторичный текст
  static const Color textHint = Color(0xFFBDBDBD); // Текст подсказки
  static const Color textOnPrimary = Colors.white; // Текст на основном цвете
  
  // Границы и разделители
  static const Color border = Color(0xFFE0E0E0); // Границы
  static const Color divider = Color(0xFFE0E0E0); // Разделители
  
  // Состояния
  static const Color success = Color(0xFF4CAF50); // Успех
  static const Color warning = Color(0xFFFF9800); // Предупреждение
  static const Color error = Color(0xFFF44336); // Ошибка
  static const Color info = Color(0xFF2196F3); // Информация
  
  // Настроения
  static const Color moodExcellent = Color(0xFF4CAF50); // Отличное (5)
  static const Color moodGood = Color(0xFF8BC34A); // Хорошее (4)
  static const Color moodOkay = Color(0xFFFFC107); // Нормальное (3)
  static const Color moodBad = Color(0xFFFF9800); // Плохое (2)
  static const Color moodTerrible = Color(0xFFF44336); // Ужасное (1)
  
  // Тени
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}

/// Градиенты для настроений
class MoodGradients {
  static const LinearGradient excellent = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient good = LinearGradient(
    colors: [Color(0xFF8BC34A), Color(0xFF9CCC65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient okay = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient bad = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient terrible = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Получить цвет настроения по значению
Color getMoodColor(int moodValue) {
  switch (moodValue) {
    case 5:
      return AppColors.moodExcellent;
    case 4:
      return AppColors.moodGood;
    case 3:
      return AppColors.moodOkay;
    case 2:
      return AppColors.moodBad;
    case 1:
      return AppColors.moodTerrible;
    default:
      return AppColors.moodOkay;
  }
}

/// Получить градиент настроения по значению
LinearGradient getMoodGradient(int moodValue) {
  switch (moodValue) {
    case 5:
      return MoodGradients.excellent;
    case 4:
      return MoodGradients.good;
    case 3:
      return MoodGradients.okay;
    case 2:
      return MoodGradients.bad;
    case 1:
      return MoodGradients.terrible;
    default:
      return MoodGradients.okay;
  }
}
