// lib/data/datasources/remote/documentos_remote_datasource.dart

import 'dart:io';

import 'package:orpheo_app/core/constants/api_constants.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/core/network/http_service.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/models/documentos/documento_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DocumentosRemoteDataSource {
  final HttpService httpService;
  final SecureStorageHelper secureStorage;
  
  DocumentosRemoteDataSource({
    required this.httpService,
    required this.secureStorage,
  });
  
  /// Obtiene todos los documentos
  Future<List<DocumentoModel>> getDocumentos() async {
    try {
      final response = await httpService.get(
        ApiConstants.documentos,
      );
      
      if (response is List) {
        return DocumentoModel.fromJsonList(response);
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
  
  /// Obtiene documentos filtrados por categoría
  Future<List<DocumentoModel>> getDocumentosByCategoria(String categoria) async {
    try {
      final response = await httpService.get(
        '${ApiConstants.documentos}/categoria/$categoria',
      );
      
      if (response is List) {
        return DocumentoModel.fromJsonList(response);
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
  
  /// Obtiene un documento por ID
  Future<DocumentoModel> getDocumentoById(int id) async {
    try {
      final response = await httpService.get(
        '${ApiConstants.documentos}/$id',
      );
      
      return DocumentoModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Busca documentos
  Future<List<DocumentoModel>> searchDocumentos(String query, {String categoria = 'todos'}) async {
    try {
      final queryParams = {
        'query': query,
      };
      
      if (categoria != 'todos') {
        queryParams['categoria'] = categoria;
      }
      
      final response = await httpService.get(
        '${ApiConstants.documentos}/search',
        queryParameters: queryParams,
      );
      
      if (response is List) {
        return DocumentoModel.fromJsonList(response);
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
  
  /// Descarga un documento y lo guarda localmente
  Future<String> downloadDocumento(int id) async {
    try {
      // Primero obtener la información del documento para saber el nombre y tipo
      final documento = await getDocumentoById(id);
      
      // Hacer la solicitud de descarga
      final response = await httpService.get(
        '${ApiConstants.documentos}/$id/download',
        headers: {'Accept': 'application/octet-stream'},
      );
      
      // Si la respuesta es un mapa con 'data' en base64, decodificarlo
      // De lo contrario, asumir que es el contenido del archivo directamente
      List<int> fileBytes;
      if (response is Map && response.containsKey('data')) {
        // Decodificar base64 si es necesario
        fileBytes = _decodeBase64(response['data']);
      } else {
        // Si no es un mapa con 'data', probablemente ya tenemos los bytes
        fileBytes = response;
      }
      
      // Guardar el archivo localmente
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, documento.nombre);
      
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      return filePath;
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Error al descargar documento: ${e.toString()}');
    }
  }
  
  /// Sube un documento
  Future<DocumentoModel> uploadDocumento(Map<String, dynamic> data, String filePath) async {
    try {
      final response = await httpService.multipartRequest(
        'POST',
        ApiConstants.documentos,
        filePath: filePath,
        fileField: 'file',
        fields: data.map((key, value) => MapEntry(key, value.toString())),
      );
      
      return DocumentoModel.fromJson(response);
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Error al subir documento: ${e.toString()}');
    }
  }
  
  /// Elimina un documento
  Future<void> deleteDocumento(int id) async {
    try {
      await httpService.delete(
        '${ApiConstants.documentos}/$id',
      );
    } catch (e) {
      if (e is ServerException || e is AuthException || 
          e is ValidationException || e is NetworkException || 
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Error al eliminar documento: ${e.toString()}');
    }
  }
  
  /// Decodifica una cadena en base64 a lista de enteros
  List<int> _decodeBase64(String base64String) {
    try {
      // Aquí iría la lógica para decodificar base64 a bytes
      // Necesitarías importar 'dart:convert' para usar base64.decode
      throw UnimplementedError('Decodificación base64 no implementada');
    } catch (e) {
      throw ServerException(message: 'Error al decodificar base64: ${e.toString()}');
    }
  }
}