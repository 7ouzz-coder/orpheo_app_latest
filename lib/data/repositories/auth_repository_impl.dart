// lib/data/repositories/auth_repository_impl.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:orpheo_app/data/models/auth/login_response_model.dart';
import 'package:orpheo_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageHelper secureStorage;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });
  
  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await secureStorage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<Either<Failure, LoginResponseModel>> login(String username, String password) async {
    try {
      final response = await remoteDataSource.login(username, password);
      
      // Guardar token y datos de usuario
      await secureStorage.saveToken(response.token);
      
      final userData = {
        'id': response.user.id.toString(),
        'username': response.user.username,
        'role': response.user.role,
        'grado': response.user.grado,
        'cargo': response.user.cargo ?? '',
        'memberFullName': response.user.memberFullName ?? '',
        'miembroId': response.user.miembroId != null 
            ? response.user.miembroId.toString() 
            : '',
        'email': response.user.email ?? '',
      };
      
      await secureStorage.saveUserData(userData);
      
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> register(Map<String, dynamic> userData) async {
    try {
      final response = await remoteDataSource.register(userData);
      
      return Right(response.success);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await secureStorage.clearAll();
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Error al cerrar sesión: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      // Obtener datos del usuario desde el almacenamiento seguro
      final id = await secureStorage.getValueOrDefault('user_id', 'id', defaultValue: '0');
      final username = await secureStorage.getValueOrDefault('username', 'username', defaultValue: '');
      final email = await secureStorage.getValueOrDefault('email', 'email', defaultValue: '');
      final role = await secureStorage.getValueOrDefault('role', 'role', defaultValue: 'general');
      final grado = await secureStorage.getValueOrDefault('grado', 'grado', defaultValue: 'aprendiz');
      final cargo = await secureStorage.getValueOrDefault('cargo', 'cargo', defaultValue: '');
      final memberFullName = await secureStorage.getValueOrDefault('member_full_name', 'memberFullName', defaultValue: '');
      final miembroIdStr = await secureStorage.getValueOrDefault('miembro_id', 'miembroId', defaultValue: '');
      
      int? miembroId;
      if (miembroIdStr.isNotEmpty) {
        try {
          miembroId = int.parse(miembroIdStr);
        } catch (_) {
          miembroId = null;
        }
      }
      
      // Reconstruir el objeto usuario
      final user = UserModel(
        id: int.tryParse(id) ?? 0,
        username: username,
        email: email.isEmpty ? null : email,
        role: role,
        grado: grado,
        cargo: cargo.isEmpty ? null : cargo,
        memberFullName: memberFullName.isEmpty ? null : memberFullName,
        miembroId: miembroId,
      );
      
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Error al obtener usuario: ${e.toString()}'));
    }
  }
}