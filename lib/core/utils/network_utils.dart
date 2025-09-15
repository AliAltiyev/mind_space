import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class NetworkUtils {
  static final Dio _dio = Dio();

  /// Проверяет подключение к интернету
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Проверяет подключение к конкретному хосту
  static Future<bool> canReachHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Выполняет GET запрос
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    try {
      return await http.get(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
      );
    } catch (e) {
      throw NetworkException('GET request failed: $e');
    }
  }

  /// Выполняет POST запрос
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: body,
      );
    } catch (e) {
      throw NetworkException('POST request failed: $e');
    }
  }

  /// Выполняет PUT запрос
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http.put(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: body,
      );
    } catch (e) {
      throw NetworkException('PUT request failed: $e');
    }
  }

  /// Выполняет DELETE запрос
  static Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    try {
      return await http.delete(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
      );
    } catch (e) {
      throw NetworkException('DELETE request failed: $e');
    }
  }

  /// Выполняет запрос с помощью Dio
  static Future<Response> dioGet(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException('Dio GET request failed: ${e.message}');
    }
  }

  /// Выполняет POST запрос с помощью Dio
  static Future<Response> dioPost(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException('Dio POST request failed: ${e.message}');
    }
  }

  /// Выполняет PUT запрос с помощью Dio
  static Future<Response> dioPut(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException('Dio PUT request failed: ${e.message}');
    }
  }

  /// Выполняет DELETE запрос с помощью Dio
  static Future<Response> dioDelete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException('Dio DELETE request failed: ${e.message}');
    }
  }

  /// Загружает файл
  static Future<Response> uploadFile(
    String url,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      return await _dio.post(
        url,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw NetworkException('File upload failed: ${e.message}');
    }
  }

  /// Скачивает файл
  static Future<Response> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw NetworkException('File download failed: ${e.message}');
    }
  }

  /// Проверяет статус ответа
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Проверяет, является ли статус код ошибкой клиента
  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Проверяет, является ли статус код ошибкой сервера
  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Получает сообщение об ошибке по статус коду
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Неверный запрос';
      case 401:
        return 'Не авторизован';
      case 403:
        return 'Доступ запрещен';
      case 404:
        return 'Не найдено';
      case 408:
        return 'Время ожидания истекло';
      case 429:
        return 'Слишком много запросов';
      case 500:
        return 'Внутренняя ошибка сервера';
      case 502:
        return 'Плохой шлюз';
      case 503:
        return 'Сервис недоступен';
      case 504:
        return 'Время ожидания шлюза истекло';
      default:
        return 'Неизвестная ошибка ($statusCode)';
    }
  }

  /// Получает тип контента из заголовков
  static String? getContentType(Map<String, String> headers) {
    return headers['content-type'] ?? headers['Content-Type'];
  }

  /// Проверяет, является ли контент JSON
  static bool isJsonContent(Map<String, String> headers) {
    final contentType = getContentType(headers);
    return contentType?.contains('application/json') ?? false;
  }

  /// Проверяет, является ли контент XML
  static bool isXmlContent(Map<String, String> headers) {
    final contentType = getContentType(headers);
    return contentType?.contains('application/xml') ?? false;
  }

  /// Проверяет, является ли контент HTML
  static bool isHtmlContent(Map<String, String> headers) {
    final contentType = getContentType(headers);
    return contentType?.contains('text/html') ?? false;
  }

  /// Получает размер контента из заголовков
  static int? getContentLength(Map<String, String> headers) {
    final contentLength = headers['content-length'] ?? headers['Content-Length'];
    return contentLength != null ? int.tryParse(contentLength) : null;
  }

  /// Получает кодировку из заголовков
  static String? getCharset(Map<String, String> headers) {
    final contentType = getContentType(headers);
    if (contentType == null) return null;
    
    final charsetMatch = RegExp(r'charset=([^;]+)').firstMatch(contentType);
    return charsetMatch?.group(1);
  }

  /// Создает заголовки для API запроса
  static Map<String, String> createApiHeaders({
    String? token,
    String? contentType = 'application/json',
    Map<String, String>? additionalHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': contentType!,
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Создает заголовки для загрузки файла
  static Map<String, String> createUploadHeaders({
    String? token,
    Map<String, String>? additionalHeaders,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Настраивает Dio с базовыми параметрами
  static void configureDio({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, dynamic>? headers,
  }) {
    _dio.options.baseUrl = baseUrl ?? '';
    _dio.options.connectTimeout = connectTimeout ?? const Duration(seconds: 30);
    _dio.options.receiveTimeout = receiveTimeout ?? const Duration(seconds: 30);
    _dio.options.sendTimeout = sendTimeout ?? const Duration(seconds: 30);
    
    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }
  }

  /// Добавляет интерцептор для логирования
  static void addLoggingInterceptor() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
  }

  /// Добавляет интерцептор для обработки ошибок
  static void addErrorInterceptor() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout) {
          error = DioException(
            requestOptions: error.requestOptions,
            error: 'Время подключения истекло',
            type: DioExceptionType.connectionTimeout,
          );
        } else if (error.type == DioExceptionType.receiveTimeout) {
          error = DioException(
            requestOptions: error.requestOptions,
            error: 'Время получения данных истекло',
            type: DioExceptionType.receiveTimeout,
          );
        } else if (error.type == DioExceptionType.sendTimeout) {
          error = DioException(
            requestOptions: error.requestOptions,
            error: 'Время отправки данных истекло',
            type: DioExceptionType.sendTimeout,
          );
        }
        handler.next(error);
      },
    ));
  }
}

/// Исключение для сетевых ошибок
class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

