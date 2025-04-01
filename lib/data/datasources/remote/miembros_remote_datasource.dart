// lib/data/datasources/remote/miembros_remote_datasource.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orpheo_app/core/constants/api_constants.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/models/miembros/miembro_model.dart';

class MiembrosRemoteDataSource {
  final http.Client client;
  final SecureStorageHelper secureStorage;
  
  MiembrosRemoteDataSource({
    required this.client,
    required this.secureStorage,
  });
  
  // Obtener todos los miembros
  Future<List<MiembroModel>> getMiembros() async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.miembros}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> miembrosJson = json.decode(response.body);
        return MiembroModel.fromJsonList(miembrosJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else {
        throw ServerException(message: 'Error al obtener miembros: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Obtener miembros filtrados por grado
  Future<List<MiembroModel>> getMiembrosByGrado(String grado) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.miembros}?grado=$grado'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> miembrosJson = json.decode(response.body);
        return MiembroModel.fromJsonList(miembrosJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else {
        throw ServerException(message: 'Error al obtener miembros: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Obtener un miembro por id
  Future<MiembroModel> getMiembroById(int id) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.miembros}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final miembroJson = json.decode(response.body);
        return MiembroModel.fromJson(miembroJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Miembro no encontrado');
      } else {
        throw ServerException(message: 'Error al obtener miembro: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Actualizar un miembro
  Future<MiembroModel> updateMiembro(int id, Map<String, dynamic> data) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.miembros}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        final miembroJson = json.decode(response.body);
        return MiembroModel.fromJson(miembroJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Miembro no encontrado');
      } else if (response.statusCode == 400) {
        throw ValidationException(message: 'Datos inválidos: ${response.body}');
      } else {
        throw ServerException(message: 'Error al actualizar miembro: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is NotFoundException || e is ValidationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Crear un miembro
  Future<MiembroModel> createMiembro(Map<String, dynamic> data) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.miembros}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      
      if (response.statusCode == 201) {
        final miembroJson = json.decode(response.body);
        return MiembroModel.fromJson(miembroJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else if (response.statusCode == 400) {
        throw ValidationException(message: 'Datos inválidos: ${response.body}');
      } else {
        throw ServerException(message: 'Error al crear miembro: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is ValidationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Buscar miembros
  Future<List<MiembroModel>> searchMiembros(String query, {String grado = 'todos'}) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      String url = '${ApiConstants.baseUrl}${ApiConstants.miembros}/search?query=$query';
      if (grado != 'todos') {
        url += '&grado=$grado';
      }
      
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> miembrosJson = json.decode(response.body);
        return MiembroModel.fromJsonList(miembrosJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else {
        throw ServerException(message: 'Error en la búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}