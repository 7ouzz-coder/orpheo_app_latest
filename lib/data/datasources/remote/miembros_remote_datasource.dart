// lib/data/datasources/remote/miembros_remote_datasource.dart

import 'package:orpheo_app/core/constants/api_constants.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/core/network/http_service.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/models/miembros/miembro_model.dart';

class MiembrosRemoteDataSource {
  final HttpService httpService;
  final SecureStorageHelper secureStorage;
  
  MiembrosRemoteDataSource({
    required this.httpService,
    required this.secureStorage,
  });
  
  /// Obtiene todos los miembros
  Future<List<MiembroModel>> getMiembros() async {
    try {
      final response = await httpService.get(
        ApiConstants.miembros,
      );
      
      if (response is List) {
        return MiembroModel.fromJsonList(response);
      }
      
      throw ServerException(message: 'Formato de respuesta inválido');
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Obtiene miembros filtrados por grado
  Future<List<MiembroModel>> getMiembrosByGrado(String grado) async {
    try {
      final response = await httpService.get(
        '${ApiConstants.miembros}/grado/$grado',
      );
      
      if (response is List) {
        return MiembroModel.fromJsonList(response);
      }
      
      throw ServerException(message: 'Formato de respuesta inválido');
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Obtiene un miembro por ID
  Future<MiembroModel> getMiembroById(int id) async {
    try {
      final response = await httpService.get(
        '${ApiConstants.miembros}/$id',
      );
      
      return MiembroModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Actualiza un miembro
  Future<MiembroModel> updateMiembro(int id, Map<String, dynamic> data) async {
    try {
      final response = await httpService.put(
        '${ApiConstants.miembros}/$id',
        body: data,
      );
      
      return MiembroModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Crea un nuevo miembro
  Future<MiembroModel> createMiembro(Map<String, dynamic> data) async {
    try {
      final response = await httpService.post(
        ApiConstants.miembros,
        body: data,
      );
      
      return MiembroModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Busca miembros
  Future<List<MiembroModel>> searchMiembros(String query, {String grado = 'todos'}) async {
    try {
      final queryParams = {
        'query': query,
      };
      
      if (grado != 'todos') {
        queryParams['grado'] = grado;
      }
      
      final response = await httpService.get(
        '${ApiConstants.miembros}/search',
        queryParameters: queryParams,
      );
      
      if (response is List) {
        return MiembroModel.fromJsonList(response);
      }
      
      throw ServerException(message: 'Formato de respuesta inválido');
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Elimina un miembro
  Future<bool> deleteMiembro(int id) async {
    try {
      await httpService.delete(
        '${ApiConstants.miembros}/$id',
      );
      
      return true;
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}