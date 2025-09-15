import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
  static final DateFormat _weekdayFormat = DateFormat('EEEE', 'ru_RU');
  static final DateFormat _monthFormat = DateFormat('MMMM', 'ru_RU');

  /// Форматирует дату в формат dd.MM.yyyy
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Форматирует время в формат HH:mm
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Форматирует дату и время в формат dd.MM.yyyy HH:mm
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Форматирует дату для отображения в UI
  static String formatDateForUI(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня в ${formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Вчера в ${formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${_weekdayFormat.format(date)} в ${formatTime(date)}';
    } else {
      return formatDate(date);
    }
  }

  /// Получает начало дня
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Получает конец дня
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Получает начало недели (понедельник)
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return getStartOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  /// Получает конец недели (воскресенье)
  static DateTime getEndOfWeek(DateTime date) {
    final weekday = date.weekday;
    return getEndOfDay(date.add(Duration(days: 7 - weekday)));
  }

  /// Получает начало месяца
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Получает конец месяца
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Проверяет, является ли дата сегодняшней
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Проверяет, является ли дата вчерашней
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Получает список дат за последние N дней
  static List<DateTime> getLastNDays(int days) {
    final now = DateTime.now();
    return List.generate(days, (index) {
      return now.subtract(Duration(days: days - 1 - index));
    });
  }

  /// Получает список дат за неделю
  static List<DateTime> getWeekDates(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  /// Получает название месяца на русском языке
  static String getMonthName(DateTime date) {
    return _monthFormat.format(date);
  }

  /// Получает название дня недели на русском языке
  static String getWeekdayName(DateTime date) {
    return _weekdayFormat.format(date);
  }

  /// Получает относительное время (например, "2 часа назад")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин. назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      return formatDate(date);
    }
  }

  /// Проверяет, находится ли дата в указанном диапазоне
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end);
  }

  /// Получает количество дней между двумя датами
  static int getDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  /// Получает возраст в годах
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

