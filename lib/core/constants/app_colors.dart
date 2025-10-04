import 'package:flutter/material.dart';

/// Современная цветовая схема для iOS и Android
class AppColors {
  // Основные цвета - современная палитра
  static const Color primary = Color(0xFF6366F1); // Индиго (современный фиолетово-синий)
  static const Color primaryLight = Color(0xFF8B5CF6); // Фиолетовый
  static const Color primaryDark = Color(0xFF4F46E5); // Темно-индиго
  
  // Вторичные цвета - привлекательные и современные
  static const Color secondary = Color(0xFF06B6D4); // Циан
  static const Color secondaryLight = Color(0xFF22D3EE); // Светло-циан
  static const Color accent = Color(0xFF10B981); // Изумрудный
  
  // Нейтральные цвета - оптимизированы для обеих платформ
  static const Color background = Color(0xFFF8FAFC); // Очень светло-серый с голубым оттенком
  static const Color surface = Colors.white; // Чистый белый
  static const Color card = Colors.white; // Белые карточки
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Светло-серый с голубым
  
  // Текст - оптимизирован для читаемости
  static const Color textPrimary = Color(0xFF0F172A); // Почти черный
  static const Color textSecondary = Color(0xFF64748B); // Сланцево-серый
  static const Color textHint = Color(0xFF94A3B8); // Светло-серый
  static const Color textOnPrimary = Colors.white; // Текст на основном цвете
  
  // Границы и разделители - более мягкие
  static const Color border = Color(0xFFE2E8F0); // Светло-серый с голубым оттенком
  static const Color divider = Color(0xFFE2E8F0); // Светло-серый с голубым оттенком
  
  // Состояния - современные и яркие
  static const Color success = Color(0xFF10B981); // Изумрудный
  static const Color successLight = Color(0xFF34D399); // Светло-изумрудный
  static const Color warning = Color(0xFFF59E0B); // Янтарный
  static const Color warningLight = Color(0xFFFBBF24); // Светло-янтарный
  static const Color error = Color(0xFFEF4444); // Красный
  static const Color errorLight = Color(0xFFF87171); // Светло-красный
  static const Color info = Color(0xFF06B6D4); // Циан
  static const Color infoLight = Color(0xFF22D3EE); // Светло-циан
  
  // Настроения - более привлекательные и современные
  static const Color moodExcellent = Color(0xFF10B981); // Изумрудный (5)
  static const Color moodGood = Color(0xFF06B6D4); // Циан (4)
  static const Color moodOkay = Color(0xFF6366F1); // Индиго (3)
  static const Color moodBad = Color(0xFFF59E0B); // Янтарный (2)
  static const Color moodTerrible = Color(0xFFEF4444); // Красный (1)
  
  // Тени - более современные и мягкие
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F000000), // Более прозрачная тень
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000), // Дополнительная мягкая тень
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x15000000), // Более заметная тень
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // Мягкая тень
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];
  
  // Градиенты для современного вида
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, warningLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Современные градиенты для настроений
class MoodGradients {
  static const LinearGradient excellent = LinearGradient(
    colors: [AppColors.moodExcellent, AppColors.successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient good = LinearGradient(
    colors: [AppColors.moodGood, AppColors.infoLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient okay = LinearGradient(
    colors: [AppColors.moodOkay, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient bad = LinearGradient(
    colors: [AppColors.moodBad, AppColors.warningLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient terrible = LinearGradient(
    colors: [AppColors.moodTerrible, AppColors.errorLight],
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
