// lib/presentation/pages/perfil/perfil_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool _isLoading = true;
  Map<String, String> _userData = {};
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final secureStorage = SecureStorageHelper(const FlutterSecureStorage());
      final username = await secureStorage.getValueOrDefault('username', 'username');
      final memberFullName = await secureStorage.getValueOrDefault('member_full_name', 'username');
      final grado = await secureStorage.getValueOrDefault('grado', 'grado', defaultValue: 'aprendiz');
      final role = await secureStorage.getValueOrDefault('role', 'role', defaultValue: 'general');
      final cargo = await secureStorage.getValueOrDefault('cargo', 'cargo', defaultValue: '');
      final email = await secureStorage.getValueOrDefault('email', 'email', defaultValue: '');
      
      // Para demo, agregamos datos adicionales simulados
      setState(() {
        _userData = {
          'username': username,
          'nombre': memberFullName,
          'grado': _capitalizeFirstLetter(grado),
          'role': _capitalizeFirstLetter(role),
          'cargo': cargo.isNotEmpty ? _capitalizeFirstLetter(cargo) : 'Ninguno',
          'email': email.isNotEmpty ? email : 'No disponible',
          'telefono': '+56 9 1234 5678', // Dato simulado
          'direccion': 'Av. Ejemplo 1234, Santiago', // Dato simulado
          'profesion': 'Profesional', // Dato simulado
          'fechaIngreso': '10/06/2018', // Dato simulado
          'fechaUltimoGrado': '15/08/2022', // Dato simulado
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _logout() async {
    try {
      final secureStorage = SecureStorageHelper(const FlutterSecureStorage());
      await secureStorage.clearAll();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cabecera de perfil
            Card(
              margin: EdgeInsets.zero,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Avatar y nombre
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        _userData['nombre']?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userData['nombre'] ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGradoChip(_userData['grado'] ?? 'Aprendiz'),
                        if (_userData['cargo'] != 'Ninguno') ...[
                          const SizedBox(width: 8),
                          _buildCargoChip(_userData['cargo'] ?? ''),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    // Información de cuenta
                    ListTile(
                      leading: const Icon(Icons.account_circle, color: Colors.blue),
                      title: const Text('Nombre de usuario'),
                      subtitle: Text(_userData['username'] ?? 'No disponible'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: const Text('Correo electrónico'),
                      subtitle: Text(_userData['email'] ?? 'No disponible'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información personal
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Teléfono', _userData['telefono'] ?? 'No disponible', Icons.phone),
                    const SizedBox(height: 12),
                    _buildInfoRow('Dirección', _userData['direccion'] ?? 'No disponible', Icons.location_on),
                    const SizedBox(height: 12),
                    _buildInfoRow('Profesión', _userData['profesion'] ?? 'No disponible', Icons.work),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información masónica
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Masónica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Fecha de Ingreso', _userData['fechaIngreso'] ?? 'No disponible', Icons.calendar_today),
                    const SizedBox(height: 12),
                    _buildInfoRow('Último Grado', _userData['fechaUltimoGrado'] ?? 'No disponible', Icons.stars),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Acciones
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.blue),
                      title: const Text('Editar perfil'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edición de perfil no implementada aún')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.password, color: Colors.blue),
                      title: const Text('Cambiar contraseña'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cambio de contraseña no implementado aún')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.blue),
                      title: const Text('Configuración'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Configuración no implementada aún')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Versión
            Center(
              child: Text(
                'Orpheo App v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGradoChip(String grado) {
    Color chipColor;
    
    switch (grado.toLowerCase()) {
      case 'maestro':
        chipColor = Colors.blue;
        break;
      case 'compañero':
      case 'companero':
        chipColor = Colors.green;
        break;
      case 'aprendiz':
      default:
        chipColor = Colors.amber;
        break;
    }
    
    return Chip(
      label: Text(grado),
      backgroundColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
    );
  }
  
  Widget _buildCargoChip(String cargo) {
    return Chip(
      label: Text(cargo),
      backgroundColor: Colors.purple.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}