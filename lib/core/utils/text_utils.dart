import '../constants/app_constants.dart';

class TextUtils {
  /// Обрезает текст до указанной длины
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Обрезает текст для отображения в UI
  static String truncateTextForUI(String text) {
    return truncateText(text, AppConstants.maxNoteLength);
  }

  /// Проверяет, является ли текст пустым или содержит только пробелы
  static bool isEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Проверяет, является ли текст непустым
  static bool isNotEmpty(String? text) {
    return !isEmpty(text);
  }

  /// Удаляет лишние пробелы из текста
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Проверяет, содержит ли текст только цифры
  static bool isNumeric(String text) {
    return RegExp(r'^\d+$').hasMatch(text);
  }

  /// Проверяет, является ли текст валидным email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Проверяет, является ли текст валидным номером телефона
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone.replaceAll(' ', ''));
  }

  /// Проверяет, является ли текст валидным URL
  static bool isValidUrl(String url) {
    return RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$')
        .hasMatch(url);
  }

  /// Получает инициалы из имени
  static String getInitials(String name) {
    if (isEmpty(name)) return '';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Форматирует имя для отображения
  static String formatName(String name) {
    if (isEmpty(name)) return '';
    
    final words = name.trim().split(' ');
    return words.map((word) => 
      word.isNotEmpty 
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : ''
    ).join(' ');
  }

  /// Форматирует текст для поиска
  static String formatForSearch(String text) {
    return text.toLowerCase().trim();
  }

  /// Проверяет, содержит ли текст подстроку (без учета регистра)
  static bool containsIgnoreCase(String text, String substring) {
    return text.toLowerCase().contains(substring.toLowerCase());
  }

  /// Получает количество слов в тексте
  static int getWordCount(String text) {
    if (isEmpty(text)) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Получает количество символов в тексте
  static int getCharacterCount(String text) {
    return text.length;
  }

  /// Получает количество символов без пробелов
  static int getCharacterCountWithoutSpaces(String text) {
    return text.replaceAll(' ', '').length;
  }

  /// Проверяет, является ли текст слишком длинным
  static bool isTooLong(String text, int maxLength) {
    return text.length > maxLength;
  }

  /// Проверяет, является ли текст слишком коротким
  static bool isTooShort(String text, int minLength) {
    return text.length < minLength;
  }

  /// Проверяет, соответствует ли текст требованиям длины
  static bool isValidLength(String text, int minLength, int maxLength) {
    return text.length >= minLength && text.length <= maxLength;
  }

  /// Получает первое предложение из текста
  static String getFirstSentence(String text) {
    if (isEmpty(text)) return '';
    
    final sentences = text.split(RegExp(r'[.!?]+'));
    return sentences.isNotEmpty ? sentences[0].trim() : '';
  }

  /// Получает последнее предложение из текста
  static String getLastSentence(String text) {
    if (isEmpty(text)) return '';
    
    final sentences = text.split(RegExp(r'[.!?]+'));
    return sentences.isNotEmpty ? sentences.last.trim() : '';
  }

  /// Получает количество предложений в тексте
  static int getSentenceCount(String text) {
    if (isEmpty(text)) return 0;
    return text.split(RegExp(r'[.!?]+')).length;
  }

  /// Форматирует текст для отображения в списке
  static String formatForList(String text) {
    if (isEmpty(text)) return 'Без описания';
    return truncateTextForUI(text);
  }

  /// Форматирует текст для отображения в карточке
  static String formatForCard(String text) {
    if (isEmpty(text)) return '';
    return truncateText(text, 100);
  }

  /// Форматирует текст для отображения в заголовке
  static String formatForTitle(String text) {
    if (isEmpty(text)) return 'Без названия';
    return truncateText(text, 50);
  }

  /// Форматирует текст для отображения в описании
  static String formatForDescription(String text) {
    if (isEmpty(text)) return 'Без описания';
    return truncateText(text, 200);
  }

  /// Получает краткое описание из текста
  static String getShortDescription(String text) {
    if (isEmpty(text)) return '';
    return truncateText(text, 150);
  }

  /// Получает среднее описание из текста
  static String getMediumDescription(String text) {
    if (isEmpty(text)) return '';
    return truncateText(text, 300);
  }

  /// Получает длинное описание из текста
  static String getLongDescription(String text) {
    if (isEmpty(text)) return '';
    return truncateText(text, 500);
  }

  /// Проверяет, содержит ли текст эмодзи
  static bool containsEmoji(String text) {
    return RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]')
        .hasMatch(text);
  }

  /// Получает количество эмодзи в тексте
  static int getEmojiCount(String text) {
    final matches = RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]')
        .allMatches(text);
    return matches.length;
  }

  /// Удаляет эмодзи из текста
  static String removeEmojis(String text) {
    return text.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]'), '');
  }

  /// Получает только эмодзи из текста
  static String getOnlyEmojis(String text) {
    final matches = RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]')
        .allMatches(text);
    return matches.map((match) => match.group(0)).join('');
  }

  /// Форматирует текст для отображения в уведомлениях
  static String formatForNotification(String text) {
    if (isEmpty(text)) return 'Новое уведомление';
    return truncateText(text, 100);
  }

  /// Форматирует текст для отображения в поиске
  static String formatForSearchResult(String text) {
    if (isEmpty(text)) return '';
    return truncateText(text, 200);
  }

  /// Проверяет, является ли текст валидным именем пользователя
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  /// Проверяет, является ли текст валидным паролем
  static bool isValidPassword(String password) {
    return password.length >= 8 && 
           password.contains(RegExp(r'[A-Z]')) && 
           password.contains(RegExp(r'[a-z]')) && 
           password.contains(RegExp(r'[0-9]'));
  }

  /// Получает уровень сложности пароля
  static String getPasswordStrength(String password) {
    if (password.length < 6) return 'Слабый';
    if (password.length < 8) return 'Средний';
    if (password.length < 12) return 'Хороший';
    return 'Отличный';
  }
}

