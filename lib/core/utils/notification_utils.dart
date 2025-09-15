import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class NotificationUtils {
  /// Показывает SnackBar с сообщением
  static void showSnackBar(BuildContext context, String message, {
    Color? backgroundColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? const Color(AppConstants.primaryColor),
        duration: duration ?? const Duration(seconds: 3),
        action: action,
      ),
    );
  }

  /// Показывает SnackBar об успехе
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Показывает SnackBar об ошибке
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  /// Показывает SnackBar с предупреждением
  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
    );
  }

  /// Показывает диалог подтверждения
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Да',
    String cancelText = 'Нет',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Показывает диалог с информацией
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
