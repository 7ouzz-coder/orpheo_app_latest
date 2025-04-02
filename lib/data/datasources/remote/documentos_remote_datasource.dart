// lib/data/datasources/remote/documentos_remote_datasource.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:orpheo_app/core/constants/api_constants.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/models/documentos/documento_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class DocumentosRemoteDataSource {
  final http.Client client;
  final SecureStorageHelper secureStorage;
  
  DocumentosRemoteDataSource({
    required this.client,
    required this.secureStorage,
  });
  
  // Método para verificar si se puede abrir una URL
  Future<bool> canLaunchUrl(Uri uri) async {
    return await url_launcher.canLaunchUrl(uri);
  }
  
  // Método para abrir una URL
  Future<bool> launchUrl(Uri uri, {url_launcher.LaunchMode? mode}) async {
    return await url_launcher.launchUrl(uri, mode: mode ?? url_launcher.LaunchMode.platformDefault);
  }
  
  // Obtener todos los documentos
  Future<List<DocumentoModel>> getDocumentos() async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.documentos}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> documentosJson = json.decode(response.body);
        return DocumentoModel.fromJsonList(documentosJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else {
        throw ServerException(message: 'Error al obtener documentos: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Obtener documentos filtrados por categoría
  Future<List<DocumentoModel>> getDocumentosByCategoria(String categoria) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.documentos}/categoria/$categoria'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> documentosJson = json.decode(response.body);
        return DocumentoModel.fromJsonList(documentosJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else {
        throw ServerException(message: 'Error al obtener documentos: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Obtener un documento por su ID
  Future<DocumentoModel> getDocumentoById(int id) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.documentos}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final documentoJson = json.decode(response.body);
        return DocumentoModel.fromJson(documentoJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Documento no encontrado');
      } else {
        throw ServerException(message: 'Error al obtener documento: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Buscar documentos
  Future<List<DocumentoModel>> searchDocumentos(String query, {String categoria = 'todos'}) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      String url = '${ApiConstants.baseUrl}${ApiConstants.documentos}/search?query=$query';
      if (categoria != 'todos') {
        url += '&categoria=$categoria';
      }
      
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> documentosJson = json.decode(response.body);
        return DocumentoModel.fromJsonList(documentosJson);
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
  
  // Descargar un documento
  Future<String> downloadDocumento(int id) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      // Primero obtenemos los detalles del documento para saber el nombre y tipo
      final documento = await getDocumentoById(id);
      
      // Obtenemos el archivo
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.documentos}/$id/download'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        // Guardar el archivo localmente
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(directory.path, documento.nombre);
        
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        return filePath;
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Documento no encontrado');
      } else {
        throw ServerException(message: 'Error al descargar documento: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Subir un documento
  Future<DocumentoModel> uploadDocumento(Map<String, dynamic> data, String filePath) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final file = File(filePath);
      final fileName = path.basename(filePath);
      final fileExtension = path.extension(filePath).replaceAll('.', '');
      
      // Crear una solicitud multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.documentos}'),
      );
      
      // Añadir encabezados
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      // Añadir campos de datos
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Añadir el archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('application', fileExtension),
          filename: fileName,
        ),
      );
      
      // Enviar la solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final documentoJson = json.decode(response.body);
        return DocumentoModel.fromJson(documentoJson);
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else if (response.statusCode == 400) {
        throw ValidationException(message: 'Error de validación: ${response.body}');
      } else {
        throw ServerException(message: 'Error al subir documento: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is ValidationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  // Eliminar un documento
  Future<void> deleteDocumento(int id) async {
    try {
      final token = await secureStorage.getToken();
      
      if (token == null) {
        throw AuthException(message: 'No hay token de autenticación');
      }
      
      final response = await client.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.documentos}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Token inválido o expirado');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Documento no encontrado');
      } else {
        throw ServerException(message: 'Error al eliminar documento: ${response.statusCode}');
      }
    } catch (e) {
      if (e is AuthException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}