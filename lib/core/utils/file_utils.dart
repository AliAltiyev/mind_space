import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  /// Получает директорию для документов приложения
  static Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Получает директорию для кэша приложения
  static Future<Directory> getAppCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Получает директорию для файлов приложения
  static Future<Directory> getAppFilesDirectory() async {
    final documentsDir = await getAppDocumentsDirectory();
    final appDir = Directory(path.join(documentsDir.path, 'MindSpace'));
    
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    
    return appDir;
  }

  /// Получает директорию для голосовых записей
  static Future<Directory> getVoiceNotesDirectory() async {
    final appDir = await getAppFilesDirectory();
    final voiceDir = Directory(path.join(appDir.path, 'voice_notes'));
    
    if (!await voiceDir.exists()) {
      await voiceDir.create(recursive: true);
    }
    
    return voiceDir;
  }

  /// Получает директорию для экспорта данных
  static Future<Directory> getExportDirectory() async {
    final appDir = await getAppFilesDirectory();
    final exportDir = Directory(path.join(appDir.path, 'exports'));
    
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    
    return exportDir;
  }

  /// Получает директорию для резервных копий
  static Future<Directory> getBackupDirectory() async {
    final appDir = await getAppFilesDirectory();
    final backupDir = Directory(path.join(appDir.path, 'backups'));
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir;
  }

  /// Проверяет, существует ли файл
  static Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  /// Проверяет, существует ли директория
  static Future<bool> directoryExists(String dirPath) async {
    return await Directory(dirPath).exists();
  }

  /// Создает файл, если он не существует
  static Future<File> createFileIfNotExists(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  /// Создает директорию, если она не существует
  static Future<Directory> createDirectoryIfNotExists(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Читает содержимое файла как строку
  static Future<String> readFileAsString(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }

  /// Читает содержимое файла как байты
  static Future<Uint8List> readFileAsBytes(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }

  /// Записывает строку в файл
  static Future<void> writeStringToFile(String filePath, String content) async {
    final file = await createFileIfNotExists(filePath);
    await file.writeAsString(content);
  }

  /// Записывает байты в файл
  static Future<void> writeBytesToFile(String filePath, Uint8List bytes) async {
    final file = await createFileIfNotExists(filePath);
    await file.writeAsBytes(bytes);
  }

  /// Добавляет строку в файл
  static Future<void> appendStringToFile(String filePath, String content) async {
    final file = await createFileIfNotExists(filePath);
    await file.writeAsString(content, mode: FileMode.append);
  }

  /// Удаляет файл
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Удаляет директорию
  static Future<void> deleteDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Получает размер файла в байтах
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Получает размер файла в человекочитаемом формате
  static Future<String> getFileSizeFormatted(String filePath) async {
    final size = await getFileSize(filePath);
    return _formatBytes(size);
  }

  /// Получает размер директории в байтах
  static Future<int> getDirectorySize(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return 0;
    
    int totalSize = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    
    return totalSize;
  }

  /// Получает размер директории в человекочитаемом формате
  static Future<String> getDirectorySizeFormatted(String dirPath) async {
    final size = await getDirectorySize(dirPath);
    return _formatBytes(size);
  }

  /// Получает список файлов в директории
  static Future<List<FileSystemEntity>> getFilesInDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];
    
    final files = <FileSystemEntity>[];
    await for (final entity in dir.list()) {
      files.add(entity);
    }
    
    return files;
  }

  /// Получает список только файлов в директории
  static Future<List<File>> getOnlyFilesInDirectory(String dirPath) async {
    final entities = await getFilesInDirectory(dirPath);
    return entities.whereType<File>().toList();
  }

  /// Получает список только директорий в директории
  static Future<List<Directory>> getOnlyDirectoriesInDirectory(String dirPath) async {
    final entities = await getFilesInDirectory(dirPath);
    return entities.whereType<Directory>().toList();
  }

  /// Получает расширение файла
  static String getFileExtension(String filePath) {
    return path.extension(filePath);
  }

  /// Получает имя файла без расширения
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Получает имя файла с расширением
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Получает родительскую директорию
  static String getParentDirectory(String filePath) {
    return path.dirname(filePath);
  }

  /// Проверяет, является ли файл изображением
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  /// Проверяет, является ли файл аудио
  static bool isAudioFile(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase();
    return ['.mp3', '.wav', '.aac', '.m4a', '.ogg', '.flac'].contains(extension);
  }

  /// Проверяет, является ли файл видео
  static bool isVideoFile(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase();
    return ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm'].contains(extension);
  }

  /// Проверяет, является ли файл документом
  static bool isDocumentFile(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase();
    return ['.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt'].contains(extension);
  }

  /// Проверяет, является ли файл архивом
  static bool isArchiveFile(String filePath) {
    final extension = getFileExtension(filePath).toLowerCase();
    return ['.zip', '.rar', '.7z', '.tar', '.gz'].contains(extension);
  }

  /// Создает уникальное имя файла
  static String createUniqueFileName(String originalPath) {
    final directory = getParentDirectory(originalPath);
    final nameWithoutExt = getFileNameWithoutExtension(originalPath);
    final extension = getFileExtension(originalPath);
    
    int counter = 1;
    String newPath = originalPath;
    
    while (File(newPath).existsSync()) {
      newPath = path.join(directory, '${nameWithoutExt}_$counter$extension');
      counter++;
    }
    
    return newPath;
  }

  /// Копирует файл
  static Future<void> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);
    
    await destinationFile.create(recursive: true);
    await sourceFile.copy(destinationPath);
  }

  /// Перемещает файл
  static Future<void> moveFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);
    
    await destinationFile.create(recursive: true);
    await sourceFile.rename(destinationPath);
  }

  /// Очищает кэш приложения
  static Future<void> clearAppCache() async {
    final cacheDir = await getAppCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  /// Очищает старые файлы
  static Future<void> clearOldFiles(String dirPath, int daysOld) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;
    
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await entity.delete();
        }
      }
    }
  }

  /// Получает информацию о файле
  static Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return {
        'exists': false,
        'size': 0,
        'sizeFormatted': '0 B',
        'extension': '',
        'name': '',
        'path': filePath,
      };
    }
    
    final stat = await file.stat();
    final size = await file.length();
    
    return {
      'exists': true,
      'size': size,
      'sizeFormatted': _formatBytes(size),
      'extension': getFileExtension(filePath),
      'name': getFileName(filePath),
      'path': filePath,
      'modified': stat.modified,
      'accessed': stat.accessed,
      'type': stat.type,
    };
  }

  /// Форматирует размер в байтах в человекочитаемый формат
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

