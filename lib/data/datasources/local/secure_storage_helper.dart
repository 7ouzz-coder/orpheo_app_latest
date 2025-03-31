import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  final FlutterSecureStorage _secureStorage;

  SecureStorageHelper(this._secureStorage);

  // Token JWT
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<String> getValueOrDefault(String key, String alternateKey, {String defaultValue = ''}) async {
  String? value = await _secureStorage.read(key: key);
  if (value == null || value.isEmpty) {
    value = await _secureStorage.read(key: alternateKey);
  }
  return value ?? defaultValue;
}

  // Datos de usuario
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _secureStorage.write(key: 'user_id', value: userData['id'].toString());
    await _secureStorage.write(key: 'username', value: userData['username']);
    await _secureStorage.write(key: 'role', value: userData['role']);
    await _secureStorage.write(key: 'grado', value: userData['grado']);
    
    if (userData['cargo'] != null) {
      await _secureStorage.write(key: 'cargo', value: userData['cargo']);
    }
    
    if (userData['memberFullName'] != null) {
      await _secureStorage.write(key: 'member_full_name', value: userData['memberFullName']);
    }
    
    if (userData['miembroId'] != null) {
      await _secureStorage.write(key: 'miembro_id', value: userData['miembroId'].toString());
    }
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}