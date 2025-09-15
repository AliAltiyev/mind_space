/// Базовый класс для всех ошибок в приложении
abstract class Failure {
  const Failure({required this.message});

  final String message;
}

/// Серверная ошибка
class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.statusCode});

  final int? statusCode;
}

/// Сетевая ошибка
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Ошибка кеша
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, this.errors});

  final Map<String, String>? errors;
}

/// Ошибка разрешений
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

/// Неизвестная ошибка
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
