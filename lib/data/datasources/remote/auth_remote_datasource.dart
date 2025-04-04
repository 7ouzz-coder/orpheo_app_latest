// lib/data/datasources/remote/auth_remote_datasource.dart

import 'package:orpheo_app/core/constants/api_constants.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/core/network/http_service.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/models/auth/login_response_model.dart';
import 'package:orpheo_app/data/models/auth/register_response_model.dart';

class AuthRemoteDataSource {
  final HttpService httpService;
  final SecureStorageHelper secureStorage;

  AuthRemoteDataSource({
    required this.httpService,
    required this.secureStorage,
  });

  /// Inicia sesión con credenciales de usuario
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final response = await httpService.post(
        ApiConstants.login,
        body: {
          'username': username,
          'password': password,
        },
        requiresAuth: false, // No requiere autenticación previa
      );

      return LoginResponseModel.fromJson(response);
    } on AuthException {
      // Reenviar excepción de autenticación
      rethrow;
    } catch (e) {
      if (e is ServerException || e is ValidationException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  /// Registra un nuevo usuario
  Future<RegisterResponseModel> register(Map<String, dynamic> userData) async {
    try {
      final response = await httpService.post(
        ApiConstants.register,
        body: userData,
        requiresAuth: false, // No requiere autenticación previa
      );

      return RegisterResponseModel.fromJson(response);
    } on ValidationException {
      // Reenviar excepción de validación
      rethrow;
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Verifica si el token es válido
  Future<bool> verifyToken() async {
    try {
      // Esta ruta debe ser implementada en el backend
      await httpService.get('/auth/verify');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Cierra la sesión enviando solicitud al servidor (opcional)
  Future<void> logout() async {
    try {
      // Esta ruta debe ser implementada en el backend si se desea
      // registrar el cierre de sesión en el servidor
      await httpService.post('/auth/logout');
    } catch (_) {
      // Ignorar errores, lo importante es limpiar el almacenamiento local
    }
    
    // Limpiar token y datos de usuario de todas formas
    await secureStorage.clearAll();
  }
}