// lib/presentation/pages/miembros/miembros_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/core/di/injection_container.dart';
import 'package:orpheo_app/domain/entities/miembro.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_state.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_bloc.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_event.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_state.dart';
import 'package:orpheo_app/presentation/pages/miembros/miembro_detail_page.dart';

class MiembrosPage extends StatefulWidget {
  const MiembrosPage({Key? key}) : super(key: key);

  @override
  State<MiembrosPage> createState() => _MiembrosPageState();
}

class _MiembrosPageState extends State<MiembrosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userGrado = 'aprendiz';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadUserGrado();
    _tabController = TabController(length: 1, vsync: this); // Inicializado con 1, se actualizará después
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadUserGrado() {
    // Obtenemos el grado del usuario del AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _userGrado = authState.user.grado;
        _initTabController();
      });
    }
  }
  
  void _initTabController() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar miembros',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        // _onSearchCleared(context);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  // onChanged: (value) => _onSearch(context, value),
                ),
              ),
              
              // Tabs para filtrar por grado
              TabBar(
                controller: _tabController,
                tabs: _buildTabs(),
                // onTap: (index) => _onTabSelected(context, index),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _buildTabViews(),
      ),
      floatingActionButton: _userGrado == 'maestro' ? FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de agregar miembro
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMiembroPage()));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función de agregar miembro no implementada aún')),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }
  
  // Métodos para manejo de tabs y eventos
  
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
    views.add(_buildMiembrosListView('aprendiz'));
    
    // Compañeros (visible para compañeros y maestros)
    if (_userGrado == 'companero' || _userGrado == 'maestro') {
      views.add(_buildMiembrosListView('companero'));
    }
    
    // Maestros (visible solo para maestros)
    if (_userGrado == 'maestro') {
      views.add(_buildMiembrosListView('maestro'));
    }
    
    return views;
  }
  
  Widget _buildMiembrosListView(String grado) {
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