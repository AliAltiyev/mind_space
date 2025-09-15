import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Базовый API клиент для всех запросов
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Получение настроений
  Future<List<Map<String, dynamic>>> getMoods() async {
    final response = await _dio.get('/moods');
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Сохранение настроения
  Future<Map<String, dynamic>> createMood(Map<String, dynamic> mood) async {
    final response = await _dio.post('/moods', data: mood);
    return Map<String, dynamic>.from(response.data);
  }

  /// Обновление настроения
  Future<Map<String, dynamic>> updateMood(
    int id,
    Map<String, dynamic> mood,
  ) async {
    final response = await _dio.put('/moods/$id', data: mood);
    return Map<String, dynamic>.from(response.data);
  }

  /// Удаление настроения
  Future<void> deleteMood(int id) async {
    await _dio.delete('/moods/$id');
  }

  /// Получение ИИ-инсайтов
  Future<List<Map<String, dynamic>>> getInsights() async {
    final response = await _dio.get('/insights');
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Создание ИИ-инсайта
  Future<Map<String, dynamic>> createInsight(
    Map<String, dynamic> insight,
  ) async {
    final response = await _dio.post('/insights', data: insight);
    return Map<String, dynamic>.from(response.data);
  }

  /// Получение аналитики
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _dio.get('/analytics');
    return Map<String, dynamic>.from(response.data);
  }
}

/// Интерцептор для добавления токена авторизации
class AuthInterceptor extends Interceptor {
  final String? token;

  AuthInterceptor({this.token});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Интерцептор для обработки ошибок
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Обработка различных типов ошибок
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Таймаут
        break;
      case DioExceptionType.badResponse:
        // Ошибка сервера
        break;
      case DioExceptionType.cancel:
        // Отмененный запрос
        break;
      case DioExceptionType.connectionError:
        // Ошибка подключения
        break;
      case DioExceptionType.badCertificate:
        // Проблема с сертификатом
        break;
      case DioExceptionType.unknown:
        // Неизвестная ошибка
        break;
    }
    handler.next(err);
  }
}

/// Создание экземпляра Dio с настройками
Dio createDioClient({String? token}) {
  final dio = Dio();

  // Настройки по умолчанию
  dio.options = BaseOptions(
    connectTimeout: AppConstants.apiTimeout,
    receiveTimeout: AppConstants.apiTimeout,
    sendTimeout: AppConstants.apiTimeout,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  // Добавление интерцепторов
  dio.interceptors.addAll([
    AuthInterceptor(token: token),
    ErrorInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true, error: true),
  ]);

  return dio;
}
