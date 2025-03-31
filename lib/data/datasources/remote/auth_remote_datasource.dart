import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orpheo_app/core/constants/api_constants.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/data/models/auth/login_response_model.dart';
import 'package:orpheo_app/data/models/auth/register_response_model.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource({required this.client});

  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw AuthException(message: 'Credenciales inválidas');
      } else {
        throw ServerException(message: 'Error en el servidor');
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  Future<RegisterResponseModel> register(Map<String, dynamic> userData) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return RegisterResponseModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw ValidationException(message: errorData['message'] ?? 'Error de validación');
      } else {
        throw ServerException(message: 'Error en el servidor');
      }
    } catch (e) {
      if (e is ValidationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}