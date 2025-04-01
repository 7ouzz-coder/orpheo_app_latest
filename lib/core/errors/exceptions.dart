// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  
  ServerException({this.message = 'Error de servidor'});
}

class AuthException implements Exception {
  final String message;
  
  AuthException({this.message = 'Error de autenticación'});
}

class ValidationException implements Exception {
  final String message;
  
  ValidationException({this.message = 'Error de validación'});
}

class NotFoundException implements Exception {
  final String message;
  
  NotFoundException({this.message = 'Recurso no encontrado'});
}

class CacheException implements Exception {
  final String message;
  
  CacheException({this.message = 'Error de caché local'});
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException({this.message = 'Error de red'});
}