// lib/presentation/pages/miembros/miembros_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';

class MiembrosPage extends StatefulWidget {
  const MiembrosPage({Key? key}) : super(key: key);

  @override
  State<MiembrosPage> createState() => _MiembrosPageState();
}

class _MiembrosPageState extends State<MiembrosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userGrado = 'aprendiz';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserGrado();
    // Inicializar con 3 tabs por defecto (podría ajustarse basado en el grado)
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserGrado() async {
    try {
      final secureStorage = SecureStorageHelper(const FlutterSecureStorage());
      final grado = await secureStorage.getValueOrDefault('grado', 'grado', defaultValue: 'aprendiz');
      
      setState(() {
        _userGrado = grado;
        _isLoading = false;
      });
      
      // Ajustar el número de tabs según el grado del usuario
      int tabCount;
      switch(_userGrado) {
        case 'maestro':
          tabCount = 3; // Puede ver todos los grados
          break;
        case 'companero':
          tabCount = 2; // Puede ver aprendices y compañeros
          break;
        case 'aprendiz':
        default:
          tabCount = 1; // Solo puede ver aprendices
          break;
      }
      
      _tabController = TabController(length: tabCount, vsync: this);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar información: $e')),
      );
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
        title: const Text('Miembros'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _buildTabs(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _buildTabViews(),
      ),
      floatingActionButton: _userGrado == 'maestro' ? FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función de agregar miembro no implementada aún')),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }
  
  List<Widget> _buildTabs() {
    final tabs = <Widget>[];
    
    // Aprendices (visible para todos)
    tabs.add(const Tab(text: 'Aprendices'));
    
    // Compañeros (visible para compañeros y maestros)
    if (_userGrado == 'companero' || _userGrado == 'maestro') {
      tabs.add(const Tab(text: 'Compañeros'));
    }
    
    // Maestros (visible solo para maestros)
    if (_userGrado == 'maestro') {
      tabs.add(const Tab(text: 'Maestros'));
    }
    
    return tabs;
  }
  
  List<Widget> _buildTabViews() {
    final views = <Widget>[];
    
    // Aprendices (visible para todos)
    views.add(_buildMiembrosList('aprendiz'));
    
    // Compañeros (visible para compañeros y maestros)
    if (_userGrado == 'companero' || _userGrado == 'maestro') {
      views.add(_buildMiembrosList('companero'));
    }
    
    // Maestros (visible solo para maestros)
    if (_userGrado == 'maestro') {
      views.add(_buildMiembrosList('maestro'));
    }
    
    return views;
  }
  
  Widget _buildMiembrosList(String grado) {
    // Aquí, en una implementación real, cargarías datos desde el backend
    // Por ahora, usamos datos simulados
    
    final List<Map<String, String>> miembrosSimulados = [
      {'nombre': 'Juan Pérez', 'cargo': grado == 'maestro' ? 'Venerable Maestro' : ''},
      {'nombre': 'Roberto Gómez', 'cargo': grado == 'maestro' ? 'Primer Vigilante' : ''},
      {'nombre': 'Carlos Rodríguez', 'cargo': grado == 'maestro' ? 'Segundo Vigilante' : ''},
      {'nombre': 'Miguel Sánchez', 'cargo': grado == 'maestro' ? 'Secretario' : ''},
      {'nombre': 'Eduardo Martínez', 'cargo': grado == 'maestro' ? 'Tesorero' : ''},
      {'nombre': 'Andrés López', 'cargo': ''},
      {'nombre': 'Francisco Torres', 'cargo': ''},
      {'nombre': 'Alejandro Díaz', 'cargo': ''},
    ];
    
    return ListView.builder(
      itemCount: miembrosSimulados.length,
      itemBuilder: (context, index) {
        final miembro = miembrosSimulados[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorForGrado(grado),
            child: Text(miembro['nombre']![0]),
          ),
          title: Text(miembro['nombre']!),
          subtitle: miembro['cargo']!.isNotEmpty ? Text(miembro['cargo']!) : null,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Perfil de ${miembro['nombre']}')),
            );
          },
        );
      },
    );
  }
  
  Color _getColorForGrado(String grado) {
    switch(grado) {
      case 'maestro':
        return Colors.blue;
      case 'companero':
        return Colors.green;
      case 'aprendiz':
      default:
        return Colors.amber;
    }
  }
}