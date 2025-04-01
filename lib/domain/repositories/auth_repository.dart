// lib/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/data/models/auth/login_response_model.dart';

abstract class AuthRepository {
  /// Verifica si hay un token válido guardado
  Future<bool> isAuthenticated();
  
  /// Inicia sesión con credenciales
  Future<Either<Failure, LoginResponseModel>> login(String username, String password);
  
  /// Registra un nuevo usuario
  Future<Either<Failure, bool>> register(Map<String, dynamic> userData);
  
  /// Cierra la sesión
  Future<Either<Failure, bool>> logout();
  
  /// Obtiene el usuario actual
  Future<Either<Failure, UserModel>> getCurrentUser();
}