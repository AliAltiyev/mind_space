import 'package:intl/intl.dart';

/// Утилиты для работы с датами
class DateUtils {
  // Приватный конструктор
  DateUtils._();

  /// Форматирование даты для отображения
  static String formatDate(DateTime date, {String pattern = 'dd.MM.yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  /// Форматирование времени для отображения
  static String formatTime(DateTime time, {String pattern = 'HH:mm'}) {
    return DateFormat(pattern).format(time);
  }

  /// Форматирование даты и времени для отображения
  static String formatDateTime(
    DateTime dateTime, {
    String pattern = 'dd.MM.yyyy HH:mm',
  }) {
    return DateFormat(pattern).format(dateTime);
  }

  /// Проверка, является ли дата сегодняшней
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Проверка, является ли дата вчерашней
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Проверка, является ли дата завтрашней
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Получение начала дня
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Получение конца дня
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Получение начала недели (понедельник)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Получение конца недели (воскресенье)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  /// Получение начала месяца
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Получение конца месяца
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Получение начала года
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Получение конца года
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }

  /// Получение относительного времени (например, "2 часа назад")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'только что';
    }
  }

  /// Получение названия дня недели
  static String getWeekdayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Получение названия месяца
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }
}
