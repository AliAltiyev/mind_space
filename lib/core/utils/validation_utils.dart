import '../constants/app_constants.dart';

class ValidationUtils {
  /// Проверяет, является ли текст валидным
  static bool isValidText(String? text) {
    return text != null && text.trim().isNotEmpty;
  }

  /// Проверяет, является ли текст валидным для записи настроения
  static bool isValidMoodNote(String? text) {
    if (text == null) return true; // Заметка необязательна
    return text.length <= AppConstants.maxNoteLength;
  }

  /// Проверяет, является ли ID валидным
  static bool isValidId(String? id) {
    return id != null && id.trim().isNotEmpty;
  }

  /// Проверяет, является ли дата валидной
  static bool isValidDate(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.isBefore(now.add(const Duration(days: 1))) && 
           date.isAfter(DateTime(2020));
  }

  /// Проверяет, является ли дата в будущем
  static bool isFutureDate(DateTime? date) {
    if (date == null) return false;
    return date.isAfter(DateTime.now());
  }

  /// Проверяет, является ли дата в прошлом
  static bool isPastDate(DateTime? date) {
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  /// Проверяет, является ли дата сегодняшней
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Проверяет, является ли дата вчерашней
  static bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// Проверяет, является ли дата в указанном диапазоне
  static bool isDateInRange(DateTime? date, DateTime start, DateTime end) {
    if (date == null) return false;
    return date.isAfter(start) && date.isBefore(end);
  }

  /// Проверяет, является ли email валидным
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  /// Проверяет, является ли номер телефона валидным
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(cleanPhone);
  }

  /// Проверяет, является ли URL валидным
  static bool isValidUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    return RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$')
        .hasMatch(url.trim());
  }

  /// Проверяет, является ли имя пользователя валидным
  static bool isValidUsername(String? username) {
    if (username == null || username.trim().isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username.trim());
  }

  /// Проверяет, является ли пароль валидным
  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    return password.length >= 8 && 
           password.contains(RegExp(r'[A-Z]')) && 
           password.contains(RegExp(r'[a-z]')) && 
           password.contains(RegExp(r'[0-9]'));
  }

  /// Проверяет, является ли пароль достаточно сильным
  static bool isStrongPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    return password.length >= 12 && 
           password.contains(RegExp(r'[A-Z]')) && 
           password.contains(RegExp(r'[a-z]')) && 
           password.contains(RegExp(r'[0-9]')) &&
           password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  /// Проверяет, совпадают ли пароли
  static bool doPasswordsMatch(String? password1, String? password2) {
    if (password1 == null || password2 == null) return false;
    return password1 == password2;
  }

  /// Проверяет, является ли возраст валидным
  static bool isValidAge(int? age) {
    return age != null && age >= 0 && age <= 150;
  }

  /// Проверяет, является ли возраст взрослым
  static bool isAdultAge(int? age) {
    return age != null && age >= 18;
  }

  /// Проверяет, является ли возраст детским
  static bool isChildAge(int? age) {
    return age != null && age < 18;
  }

  /// Проверяет, является ли номер валидным
  static bool isValidNumber(String? number) {
    if (number == null || number.trim().isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(number.trim());
  }

  /// Проверяет, является ли число валидным
  static bool isValidDouble(String? number) {
    if (number == null || number.trim().isEmpty) return false;
    return double.tryParse(number.trim()) != null;
  }

  /// Проверяет, является ли целое число валидным
  static bool isValidInt(String? number) {
    if (number == null || number.trim().isEmpty) return false;
    return int.tryParse(number.trim()) != null;
  }

  /// Проверяет, является ли число в указанном диапазоне
  static bool isNumberInRange(double? number, double min, double max) {
    if (number == null) return false;
    return number >= min && number <= max;
  }

  /// Проверяет, является ли число положительным
  static bool isPositiveNumber(double? number) {
    return number != null && number > 0;
  }

  /// Проверяет, является ли число отрицательным
  static bool isNegativeNumber(double? number) {
    return number != null && number < 0;
  }

  /// Проверяет, является ли число нулевым
  static bool isZeroNumber(double? number) {
    return number != null && number == 0;
  }

  /// Проверяет, является ли список валидным
  static bool isValidList(List? list) {
    return list != null && list.isNotEmpty;
  }

  /// Проверяет, является ли список пустым
  static bool isEmptyList(List? list) {
    return list == null || list.isEmpty;
  }

  /// Проверяет, является ли карта валидной
  static bool isValidMap(Map? map) {
    return map != null && map.isNotEmpty;
  }

  /// Проверяет, является ли карта пустой
  static bool isEmptyMap(Map? map) {
    return map == null || map.isEmpty;
  }

  /// Проверяет, является ли строка валидным JSON
  static bool isValidJson(String? json) {
    if (json == null || json.trim().isEmpty) return false;
    try {
      // Простая проверка на JSON
      return json.trim().startsWith('{') && json.trim().endsWith('}') ||
             json.trim().startsWith('[') && json.trim().endsWith(']');
    } catch (e) {
      return false;
    }
  }

  /// Проверяет, является ли строка валидным UUID
  static bool isValidUuid(String? uuid) {
    if (uuid == null || uuid.trim().isEmpty) return false;
    return RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
        .hasMatch(uuid.toLowerCase());
  }

  /// Проверяет, является ли строка валидным IP адресом
  static bool isValidIpAddress(String? ip) {
    if (ip == null || ip.trim().isEmpty) return false;
    return RegExp(r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$')
        .hasMatch(ip.trim());
  }

  /// Проверяет, является ли строка валидным MAC адресом
  static bool isValidMacAddress(String? mac) {
    if (mac == null || mac.trim().isEmpty) return false;
    return RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')
        .hasMatch(mac.trim());
  }

  /// Проверяет, является ли строка валидным цветом в hex формате
  static bool isValidHexColor(String? color) {
    if (color == null || color.trim().isEmpty) return false;
    return RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$')
        .hasMatch(color.trim());
  }

  /// Проверяет, является ли строка валидным временем
  static bool isValidTime(String? time) {
    if (time == null || time.trim().isEmpty) return false;
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$')
        .hasMatch(time.trim());
  }

  /// Проверяет, является ли строка валидной датой
  static bool isValidDateString(String? date) {
    if (date == null || date.trim().isEmpty) return false;
    try {
      DateTime.parse(date.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Проверяет, является ли строка валидным временем в формате ISO
  static bool isValidIsoTime(String? time) {
    if (time == null || time.trim().isEmpty) return false;
    try {
      DateTime.parse(time.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Получает сообщение об ошибке валидации
  static String getValidationErrorMessage(String field, String error) {
    switch (error) {
      case 'required':
        return 'Поле $field обязательно для заполнения';
      case 'invalid':
        return 'Поле $field содержит недопустимое значение';
      case 'too_short':
        return 'Поле $field слишком короткое';
      case 'too_long':
        return 'Поле $field слишком длинное';
      case 'invalid_email':
        return 'Некорректный email адрес';
      case 'invalid_phone':
        return 'Некорректный номер телефона';
      case 'invalid_url':
        return 'Некорректный URL';
      case 'invalid_username':
        return 'Некорректное имя пользователя';
      case 'invalid_password':
        return 'Некорректный пароль';
      case 'passwords_dont_match':
        return 'Пароли не совпадают';
      case 'invalid_age':
        return 'Некорректный возраст';
      case 'invalid_number':
        return 'Некорректное число';
      case 'invalid_date':
        return 'Некорректная дата';
      case 'invalid_time':
        return 'Некорректное время';
      default:
        return 'Ошибка валидации поля $field';
    }
  }
}

