// lib/core/network/http_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:orpheo_app/core/constants/api_constants.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';

/// Servicio HTTP personalizado con interceptores para autenticación, manejo de errores y registro
class HttpService {
  final http.Client _client;
  final SecureStorageHelper _secureStorage;
  
  // Tiempo de espera para las solicitudes (30 segundos)
  static const Duration timeoutDuration = Duration(seconds: 30);

  HttpService({
    required http.Client client,
    required SecureStorageHelper secureStorage,
  })  : _client = client,
        _secureStorage = secureStorage;

  /// Realiza una solicitud GET a la API
  Future<dynamic> get(String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      // Construir la URL con parámetros de consulta si se proporcionan
      String url = '${ApiConstants.baseUrl}$endpoint';
      if (queryParameters != null && queryParameters.isNotEmpty) {
        url = Uri.parse(url).replace(queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        )).toString();
      }

      // Agregar encabezados de autenticación si se requiere
      final Map<String, String> requestHeaders = {...?headers};
      if (requiresAuth) {
        final authHeaders = await _getAuthHeaders();
        requestHeaders.addAll(authHeaders);
      }

      // Realizar solicitud con tiempo de espera
      final response = await _client
          .get(Uri.parse(url), headers: requestHeaders)
          .timeout(timeoutDuration);

      // Procesar respuesta
      return _processResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'La solicitud ha excedido el tiempo de espera');
    } on SocketException {
      throw NetworkException(message: 'No hay conexión a internet');
    } catch (e) {
      if (e is ServerException || e is AuthException || e is ValidationException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// Realiza una solicitud POST a la API
  Future<dynamic> post(String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      // Agregar encabezados de autenticación si se requiere
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      
      if (requiresAuth) {
        final authHeaders = await _getAuthHeaders();
        requestHeaders.addAll(authHeaders);
      }

      // Realizar solicitud con tiempo de espera
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeoutDuration);

      // Procesar respuesta
      return _processResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'La solicitud ha excedido el tiempo de espera');
    } on SocketException {
      throw NetworkException(message: 'No hay conexión a internet');
    } catch (e) {
      if (e is ServerException || e is AuthException || e is ValidationException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// Realiza una solicitud PUT a la API
  Future<dynamic> put(String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      // Agregar encabezados de autenticación si se requiere
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      
      if (requiresAuth) {
        final authHeaders = await _getAuthHeaders();
        requestHeaders.addAll(authHeaders);
      }

      // Realizar solicitud con tiempo de espera
      final response = await _client
          .put(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeoutDuration);

      // Procesar respuesta
      return _processResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'La solicitud ha excedido el tiempo de espera');
    } on SocketException {
      throw NetworkException(message: 'No hay conexión a internet');
    } catch (e) {
      if (e is ServerException || e is AuthException || e is ValidationException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// Realiza una solicitud DELETE a la API
  Future<dynamic> delete(String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    try {
      // Agregar encabezados de autenticación si se requiere
      final Map<String, String> requestHeaders = {...?headers};
      if (requiresAuth) {
        final authHeaders = await _getAuthHeaders();
        requestHeaders.addAll(authHeaders);
      }

      // Realizar solicitud con tiempo de espera
      final response = await _client
          .delete(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: requestHeaders,
          )
          .timeout(timeoutDuration);

      // Procesar respuesta
      return _processResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'La solicitud ha excedido el tiempo de espera');
    } on SocketException {
      throw NetworkException(message: 'No hay conexión a internet');
    } catch (e) {
      if (e is ServerException || e is AuthException || e is ValidationException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// Realiza una solicitud multipart para subir archivos
  Future<dynamic> multipartRequest(
    String method,
    String endpoint, {
    required String filePath,
    required String fileField,
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    try {
      // Crear solicitud multipart
      final request = http.MultipartRequest(
        method,
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      );

      // Agregar campos si se proporcionan
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Agregar archivo
      final file = await http.MultipartFile.fromPath(
        fileField,
        filePath,
      );
      request.files.add(file);

      // Agregar encabezados de autenticación si se requiere
      if (requiresAuth) {
        final authHeaders = await _getAuthHeaders();
        request.headers.addAll(authHeaders);
      }

      // Enviar solicitud
      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      // Procesar respuesta
      return _processResponse(response);
    } on TimeoutException {
      throw NetworkException(message: 'La solicitud ha excedido el tiempo de espera');
    } on SocketException {
      throw NetworkException(message: 'No hay conexión a internet');
    } catch (e) {
      if (e is ServerException || e is AuthException || e is ValidationException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// Procesa la respuesta HTTP y maneja errores
  dynamic _processResponse(http.Response response) {
    // Registrar respuesta en modo depuración
    if (kDebugMode) {
      print('Respuesta (${response.statusCode}): ${response.body}');
    }

    // Analizar respuesta como JSON si tiene contenido
    var responseJson;
    if (response.body.isNotEmpty) {
      try {
        responseJson = json.decode(response.body);
      } catch (_) {
        // Si no se puede analizar como JSON, devolver el cuerpo tal como está
        responseJson = response.body;
      }
    }

    // Manejar códigos de estado HTTP
    switch (response.statusCode) {
      case 200:
      case 201:
        return responseJson;
      case 400:
        final errorMessage = _extractErrorMessage(responseJson);
        throw ValidationException(message: errorMessage);
      case 401:
        final errorMessage = _extractErrorMessage(responseJson);
        throw AuthException(message: errorMessage);
      case 404:
        final errorMessage = _extractErrorMessage(responseJson);
        throw NotFoundException(message: errorMessage);
      case 500:
      default:
        final errorMessage = _extractErrorMessage(responseJson);
        throw ServerException(message: errorMessage);
    }
  }

  /// Extrae mensaje de error de la respuesta JSON
  String _extractErrorMessage(dynamic responseJson) {
    try {
      if (responseJson is Map<String, dynamic> && responseJson.containsKey('message')) {
        return responseJson['message'];
      }
    } catch (_) {}
    return 'Error en la solicitud';
  }

  /// Obtiene los encabezados de autenticación
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw AuthException(message: 'No hay token de autenticación');
    }
    return {'Authorization': 'Bearer $token'};
  }
}