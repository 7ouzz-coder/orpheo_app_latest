// lib/data/datasources/remote/programas_remote_datasource.dart

import 'package:orpheo_app/core/constants/api_constants.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/core/network/http_service.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/models/programas/programa_model.dart';
import 'package:orpheo_app/data/models/programas/asistencia_model.dart';

class ProgramasRemoteDataSource {
  final HttpService httpService;
  final SecureStorageHelper secureStorage;
  
  ProgramasRemoteDataSource({
    required this.httpService,
    required this.secureStorage,
  });
  
  /// Obtiene todos los programas
  Future<List<ProgramaModel>> getProgramas() async {
    try {
      final response = await httpService.get(
        ApiConstants.programas,
      );
      
      if (response is List) {
        return ProgramaModel.fromJsonList(response);
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
  
  /// Obtiene programas filtrados por grado
  Future<List<ProgramaModel>> getProgramasByGrado(String grado) async {
    try {
      final queryParams = {'grado': grado};
      
      final response = await httpService.get(
        ApiConstants.programas,
        queryParameters: queryParams,
      );
      
      if (response is List) {
        return ProgramaModel.fromJsonList(response);
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
  
  /// Obtiene programas filtrados por estado
  Future<List<ProgramaModel>> getProgramasByEstado(String estado) async {
    try {
      final queryParams = {'estado': estado};
      
      final response = await httpService.get(
        ApiConstants.programas,
        queryParameters: queryParams,
      );
      
      if (response is List) {
        return ProgramaModel.fromJsonList(response);
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
  
  /// Obtiene programas próximos (futuros)
  Future<List<ProgramaModel>> getProximosProgramas() async {
    try {
      final response = await httpService.get(
        '${ApiConstants.programas}/proximos',
      );
      
      if (response is List) {
        return ProgramaModel.fromJsonList(response);
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
  
  /// Obtiene programas pasados (históricos)
  Future<List<ProgramaModel>> getProgramasPasados() async {
    try {
      final response = await httpService.get(
        '${ApiConstants.programas}/pasados',
      );
      
      if (response is List) {
        return ProgramaModel.fromJsonList(response);
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
  
  /// Obtiene un programa por ID
  Future<ProgramaModel> getProgramaById(int id) async {
    try {
      final response = await httpService.get(
        '${ApiConstants.programas}/$id',
      );
      
      return ProgramaModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Crea un nuevo programa
  Future<ProgramaModel> createPrograma(Map<String, dynamic> data) async {
    try {
      final response = await httpService.post(
        ApiConstants.programas,
        body: data,
      );
      
      return ProgramaModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Actualiza un programa
  Future<ProgramaModel> updatePrograma(int id, Map<String, dynamic> data) async {
    try {
      final response = await httpService.put(
        '${ApiConstants.programas}/$id',
        body: data,
      );
      
      return ProgramaModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Elimina un programa
  Future<void> deletePrograma(int id) async {
    try {
      await httpService.delete(
        '${ApiConstants.programas}/$id',
      );
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Obtiene la lista de asistencia para un programa
  Future<List<AsistenciaModel>> getAsistenciaByPrograma(int programaId) async {
    try {
      final response = await httpService.get(
        '${ApiConstants.asistencia}/programa/$programaId',
      );
      
      if (response is List) {
        return AsistenciaModel.fromJsonList(response);
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
  
  /// Registra asistencia para un miembro en un programa
  Future<AsistenciaModel> registrarAsistencia(Map<String, dynamic> data) async {
    try {
      final response = await httpService.post(
        ApiConstants.asistencia,
        body: data,
      );
      
      return AsistenciaModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Actualiza un registro de asistencia
  Future<AsistenciaModel> updateAsistencia(int id, Map<String, dynamic> data) async {
    try {
      final response = await httpService.put(
        '${ApiConstants.asistencia}/$id',
        body: data,
      );
      
      return AsistenciaModel.fromJson(response);
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