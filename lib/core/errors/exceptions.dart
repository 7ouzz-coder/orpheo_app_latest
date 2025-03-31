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