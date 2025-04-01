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
    
    // Después de inicializar el TabController, cargar los miembros
    context.read<MiembrosBloc>().add(const LoadMiembros(grado: 'aprendiz'));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MiembrosBloc>(),
      child: Builder(
        builder: (context) {
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
                              _onSearchCleared(context);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) => _onSearch(context, value),
                      ),
                    ),
                    
                    // Tabs para filtrar por grado
                    TabBar(
                      controller: _tabController,
                      tabs: _buildTabs(),
                      onTap: (index) => _onTabSelected(context, index),
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: _buildTabViews(context),
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
      ),
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
  
  List<Widget> _buildTabViews(BuildContext context) {
    final views = <Widget>[];
    
    // Aprendices (visible para todos)
    views.add(_buildMiembrosListView(context, 'aprendiz'));
    
    // Compañeros (visible para compañeros y maestros)
    if (_userGrado == 'companero' || _userGrado == 'maestro') {
      views.add(_buildMiembrosListView(context, 'companero'));
    }
    
    // Maestros (visible solo para maestros)
    if (_userGrado == 'maestro') {
      views.add(_buildMiembrosListView(context, 'maestro'));
    }
    
    return views;
  }
  
  void _onTabSelected(BuildContext context, int index) {
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
  
  void _onSearch(BuildContext context, String query) {
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
      }
      
      context.read<MiembrosBloc>().add(SearchMiembros(
        query: query,
        grado: grado,
      ));
    } else if (query.isEmpty) {
      _onSearchCleared(context);
    }
  }
  
  void _onSearchCleared(BuildContext context) {
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
    }
    
    context.read<MiembrosBloc>().add(LoadMiembros(grado: grado));
  }
  
  Widget _buildMiembrosListView(BuildContext context, String grado) {
    return BlocBuilder<MiembrosBloc, MiembrosState>(
      builder: (context, state) {
        if (state is MiembrosInitial) {
          // Disparar evento para cargar miembros al iniciar
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
          // Filtramos los miembros según el grado actual
          final miembrosFiltrados = state.miembros.where((m) => m.grado == grado).toList();
          
          if (miembrosFiltrados.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
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
        
        // Estado no manejado
        return const Center(child: Text('Estado no manejado'));
      },
    );
  }
  
  Widget _buildMiembroCard(BuildContext context, Miembro miembro) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: CircleAvatar(
          backgroundColor: _getColorForGrado(miembro.grado),
          radius: 28,
          child: Text(
            miembro.nombres.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          miembro.nombreCompleto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Grado: ${_capitalizeFirstLetter(miembro.grado)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (miembro.cargo != null && miembro.cargo!.isNotEmpty)
              Text(
                'Cargo: ${_capitalizeFirstLetter(miembro.cargo!)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navegar a la página de detalles del miembro
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
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }