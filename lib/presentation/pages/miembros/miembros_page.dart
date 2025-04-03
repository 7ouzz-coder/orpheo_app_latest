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
    
    // Tras inicializar el TabController, cargar la lista inicial de miembros
    if (context.read<MiembrosBloc>().state is! MiembrosLoaded) {
      context.read<MiembrosBloc>().add(const LoadMiembros(grado: 'aprendiz'));
    }
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
                        _onSearchCleared();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _onSearch,
                ),
              ),
              
              // Tabs para filtrar por grado
              TabBar(
                controller: _tabController,
                tabs: _buildTabs(),
                onTap: _onTabSelected,
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
  
  void _onTabSelected(int index) {
    String grado;
    
    switch(index) {
      case 0:
        grado = 'aprendiz';
        break;
      case 1:
        grado = 'companero';
        break;
      case 2:
        grado = 'maestro';
        break;
      default:
        grado = 'aprendiz';
        break;
    }
    
    // Si hay texto en la búsqueda, filtrar por búsqueda y grado
    if (_searchController.text.isNotEmpty) {
      context.read<MiembrosBloc>().add(SearchMiembros(
        query: _searchController.text,
        grado: grado,
      ));
    } else {
      // Si no hay búsqueda, solo filtrar por grado
      context.read<MiembrosBloc>().add(LoadMiembros(grado: grado));
    }
  }
  
  void _onSearch(String query) {
    if (query.length >= 3) {
      // Solo buscar si hay al menos 3 caracteres
      final currentTabIndex = _tabController.index;
      String grado;
      
      switch(currentTabIndex) {
        case 0:
          grado = 'aprendiz';
          break;
        case 1:
          grado = 'companero';
          break;
        case 2:
          grado = 'maestro';
          break;
        default:
          grado = 'aprendiz';
          break;
      }
      
      context.read<MiembrosBloc>().add(SearchMiembros(
        query: query,
        grado: grado,
      ));
    } else if (query.isEmpty) {
      _onSearchCleared();
    }
  }
  
  void _onSearchCleared() {
    final currentTabIndex = _tabController.index;
    String grado;
    
    switch(currentTabIndex) {
      case 0:
        grado = 'aprendiz';
        break;
      case 1:
        grado = 'companero';
        break;
      case 2:
        grado = 'maestro';
        break;
      default:
        grado = 'aprendiz';
        break;
    }
    
    context.read<MiembrosBloc>().add(LoadMiembros(grado: grado));
  }
  
  Widget _buildMiembrosListView(String grado) {
    return BlocBuilder<MiembrosBloc, MiembrosState>(
      builder: (context, state) {
        if (state is MiembrosInitial) {
          // Cargar miembros al iniciar
          context.read<MiembrosBloc>().add(LoadMiembros(grado: grado));
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is MiembrosLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is MiembrosError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MiembrosBloc>().add(LoadMiembros(grado: grado));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        if (state is MiembrosLoaded) {
          // Filtrar miembros por grado actual
          final miembrosFiltrados = state.miembros
              .where((miembro) => miembro.grado == grado)
              .toList();
          
          if (miembrosFiltrados.isEmpty) {
            // Mostrar mensaje cuando no hay miembros
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'No se encontraron miembros para: "${state.searchQuery}"'
                        : 'No hay miembros disponibles',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<MiembrosBloc>().add(LoadMiembros(grado: grado));
            },
            child: ListView.builder(
              itemCount: miembrosFiltrados.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final miembro = miembrosFiltrados[index];
                return _buildMiembroCard(context, miembro);
              },
            ),
          );
        }
        
        // En caso de usar datos de prueba mientras no hay conexión
        if (_tabController.index == _getTabIndexForGrado(grado)) {
          return _buildMockMiembrosList(grado);
        }
        
        return const Center(child: Text('Estado no manejado'));
      },
    );
  }
  
  Widget _buildMiembroCard(BuildContext context, Miembro miembro) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForGrado(miembro.grado),
          child: Text(
            miembro.nombres.isNotEmpty ? miembro.nombres[0].toUpperCase() : 'M',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(miembro.nombreCompleto),
        subtitle: miembro.cargo != null && miembro.cargo!.isNotEmpty 
            ? Text(miembro.cargo!) 
            : (miembro.email != null ? Text(miembro.email!) : null),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => MiembroDetailPage(miembroId: miembro.id),
            ),
          );
        },
      ),
    );
  }
  
  // Datos simulados para pruebas sin backend
  Widget _buildMockMiembrosList(String grado) {
    final List<Map<String, dynamic>> miembrosSimulados = [
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
              SnackBar(content: Text('Perfil de ${miembro['nombre']} - Modo Prueba')),
            );
          },
        );
      },
    );
  }
  
  int _getTabIndexForGrado(String grado) {
    switch(grado) {
      case 'aprendiz':
        return 0;
      case 'companero':
        return _userGrado == 'maestro' ? 1 : 0;
      case 'maestro':
        return _userGrado == 'maestro' ? 2 : 0;
      default:
        return 0;
    }
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