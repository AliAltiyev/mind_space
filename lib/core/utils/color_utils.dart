import 'package:flutter/material.dart';

import '../../features/mood_tracking/domain/entities/mood_entry.dart';
import '../constants/app_constants.dart';

class ColorUtils {
  /// Получает цвет для настроения
  static Color getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.verySad:
        return const Color(AppConstants.verySadColor);
      case MoodLevel.sad:
        return const Color(AppConstants.sadColor);
      case MoodLevel.neutral:
        return const Color(AppConstants.neutralColor);
      case MoodLevel.happy:
        return const Color(AppConstants.happyColor);
      case MoodLevel.veryHappy:
        return const Color(AppConstants.veryHappyColor);
    }
  }

  /// Получает светлую версию цвета настроения
  static Color getMoodLightColor(MoodLevel mood) {
    return getMoodColor(mood).withOpacity(0.1);
  }

  /// Получает среднюю версию цвета настроения
  static Color getMoodMediumColor(MoodLevel mood) {
    return getMoodColor(mood).withOpacity(0.3);
  }

  /// Получает темную версию цвета настроения
  static Color getMoodDarkColor(MoodLevel mood) {
    return getMoodColor(mood).withOpacity(0.8);
  }

  /// Получает цвет фона для карточки настроения
  static Color getMoodCardBackgroundColor(MoodLevel mood) {
    return getMoodColor(mood).withOpacity(0.05);
  }

  /// Получает цвет границы для карточки настроения
  static Color getMoodCardBorderColor(MoodLevel mood) {
    return getMoodColor(mood).withOpacity(0.2);
  }

  /// Получает цвет текста для настроения
  static Color getMoodTextColor(MoodLevel mood) {
    return getMoodColor(mood);
  }

  /// Получает цвет иконки для настроения
  static Color getMoodIconColor(MoodLevel mood) {
    return getMoodColor(mood);
  }

  /// Получает градиент для настроения
  static LinearGradient getMoodGradient(MoodLevel mood) {
    final color = getMoodColor(mood);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
    );
  }

  /// Получает цвет для статистики
  static Color getStatisticsColor(int index) {
    final colors = [
      const Color(AppConstants.verySadColor),
      const Color(AppConstants.sadColor),
      const Color(AppConstants.neutralColor),
      const Color(AppConstants.happyColor),
      const Color(AppConstants.veryHappyColor),
    ];
    return colors[index % colors.length];
  }

  /// Получает цвет для графика
  static Color getChartColor(int index) {
    final colors = [
      const Color(AppConstants.verySadColor),
      const Color(AppConstants.sadColor),
      const Color(AppConstants.neutralColor),
      const Color(AppConstants.happyColor),
      const Color(AppConstants.veryHappyColor),
    ];
    return colors[index % colors.length];
  }

  /// Получает цвет для прогресс-бара
  static Color getProgressBarColor(double value) {
    if (value < 0.2) {
      return const Color(AppConstants.verySadColor);
    } else if (value < 0.4) {
      return const Color(AppConstants.sadColor);
    } else if (value < 0.6) {
      return const Color(AppConstants.neutralColor);
    } else if (value < 0.8) {
      return const Color(AppConstants.happyColor);
    } else {
      return const Color(AppConstants.veryHappyColor);
    }
  }

  /// Получает цвет для рейтинга
  static Color getRatingColor(double rating) {
    if (rating < 2) {
      return const Color(AppConstants.verySadColor);
    } else if (rating < 3) {
      return const Color(AppConstants.sadColor);
    } else if (rating < 4) {
      return const Color(AppConstants.neutralColor);
    } else if (rating < 5) {
      return const Color(AppConstants.happyColor);
    } else {
      return const Color(AppConstants.veryHappyColor);
    }
  }

  /// Получает цвет для статуса
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
      case 'отлично':
        return const Color(AppConstants.veryHappyColor);
      case 'good':
      case 'хорошо':
        return const Color(AppConstants.happyColor);
      case 'neutral':
      case 'нейтрально':
        return const Color(AppConstants.neutralColor);
      case 'bad':
      case 'плохо':
        return const Color(AppConstants.sadColor);
      case 'terrible':
      case 'ужасно':
        return const Color(AppConstants.verySadColor);
      default:
        return const Color(AppConstants.neutralColor);
    }
  }

  /// Получает цвет для типа инсайта
  static Color getInsightColor(String type) {
    switch (type.toLowerCase()) {
      case 'pattern':
      case 'паттерн':
        return Colors.blue;
      case 'recommendation':
      case 'рекомендация':
        return Colors.green;
      case 'trend':
      case 'тренд':
        return Colors.orange;
      case 'warning':
      case 'предупреждение':
        return Colors.red;
      case 'celebration':
      case 'празднование':
        return Colors.purple;
      default:
        return const Color(AppConstants.neutralColor);
    }
  }

  /// Получает цвет для приоритета
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.green;
      default:
        return const Color(AppConstants.neutralColor);
    }
  }

  /// Получает цвет для темы
  static Color getThemeColor(String theme) {
    switch (theme.toLowerCase()) {
      case 'dark':
      case 'темная':
        return Colors.grey[800]!;
      case 'light':
      case 'светлая':
        return Colors.white;
      case 'blue':
      case 'синяя':
        return Colors.blue[50]!;
      case 'green':
      case 'зеленая':
        return Colors.green[50]!;
      case 'purple':
      case 'фиолетовая':
        return Colors.purple[50]!;
      default:
        return Colors.white;
    }
  }

  /// Получает контрастный цвет для текста
  static Color getContrastTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Получает цвет с прозрачностью
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Получает цвет из hex строки
  static Color getColorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Получает hex строку из цвета
  static String getHexFromColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  /// Получает цвет для градиента
  static List<Color> getGradientColors(Color baseColor) {
    return [
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.4),
      baseColor.withOpacity(0.1),
    ];
  }

  /// Получает цвет для тени
  static Color getShadowColor(Color baseColor) {
    return baseColor.withOpacity(0.3);
  }

  /// Получает цвет для границы
  static Color getBorderColor(Color baseColor) {
    return baseColor.withOpacity(0.2);
  }

  /// Получает цвет для фона
  static Color getBackgroundColor(Color baseColor) {
    return baseColor.withOpacity(0.05);
  }
}
