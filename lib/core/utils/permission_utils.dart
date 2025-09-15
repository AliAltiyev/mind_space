import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// Запрашивает разрешение на использование микрофона
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  /// Проверяет, есть ли разрешение на использование микрофона
  static Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// Запрашивает разрешение на запись аудио
  static Future<bool> requestAudioPermission() async {
    final status = await Permission.audio.request();
    return status == PermissionStatus.granted;
  }

  /// Проверяет, есть ли разрешение на запись аудио
  static Future<bool> hasAudioPermission() async {
    final status = await Permission.audio.status;
    return status == PermissionStatus.granted;
  }

  /// Запрашивает разрешение на доступ к файлам
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  /// Проверяет, есть ли разрешение на доступ к файлам
  static Future<bool> hasStoragePermission() async {
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }

  /// Запрашивает разрешение на уведомления
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status == PermissionStatus.granted;
  }

  /// Проверяет, есть ли разрешение на уведомления
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status == PermissionStatus.granted;
  }

  /// Открывает настройки приложения
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Получает статус разрешения
  static Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// Запрашивает разрешение
  static Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }
}
