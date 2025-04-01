// lib/presentation/pages/documentos/documentos_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/core/di/injection_container.dart';
import 'package:orpheo_app/domain/entities/documento.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_state.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_bloc.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_event.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_state.dart';
import 'package:orpheo_app/presentation/pages/documentos/documento_detail_page.dart';
import 'package:orpheo_app/presentation/pages/documentos/upload_documento_page.dart';
import 'package:intl/intl.dart';

class DocumentosPage extends StatefulWidget {
  const DocumentosPage({Key? key}) : super(key: key);

  @override
  State<DocumentosPage> createState() => _DocumentosPageState();
}

class _DocumentosPageState extends State<DocumentosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userGrado = 'aprendiz';
  final TextEditingController _searchController = TextEditingController();
  bool _showPlanchas = false;
  
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
    
    // Después de inicializar el TabController, cargar los documentos
    context.read<DocumentosBloc>().add(const LoadDocumentos(categoria: 'aprendiz'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
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
                    hintText: 'Buscar documentos',
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
              
              // Tabs para filtrar por categoría según el grado
              TabBar(
                controller: _tabController,
                tabs: _buildTabs(),
                onTap: (index) => _onTabSelected(context, index),
              ),
            ],
          ),
        ),
        actions: [
          // Botón para alternar entre documentos y planchas
          IconButton(
            icon: Icon(_showPlanchas ? Icons.description : Icons.assignment),
            tooltip: _showPlanchas ? 'Ver documentos' : 'Ver planchas',
            onPressed: () {
              setState(() {
                _showPlanchas = !_showPlanchas;
              });
              
              // Recargar con el nuevo filtro
              _onTabSelected(context, _tabController.index);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _buildTabViews(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de subir documento
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadDocumentoPage(
                categoria: _getCategoriaForCurrentTab(),
                esPlancha: _showPlanchas,
              ),
            ),
          ).then((_) {
            // Recargar documentos cuando regresemos
            _onTabSelected(context, _tabController.index);
          });
        },
        child: const Icon(Icons.add),
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
    views.add(_buildDocumentosListView(context, 'aprendiz'));
    
    // Compañeros (visible para compañeros y maestros)
    if (_userGrado == 'companero' || _userGrado == 'maestro') {
      views.add(_buildDocumentosListView(context, 'companero'));
    }
    
    // Maestros (visible solo para maestros)
    if (_userGrado == 'maestro') {
      views.add(_buildDocumentosListView(context, 'maestro'));
    }
    
    return views;
  }
  
  String _getCategoriaForCurrentTab() {
    switch(_tabController.index) {
      case 0:
        return 'aprendiz';
      case 1:
        return 'companero';
      case 2:
        return 'maestro';
      default:
        return 'aprendiz';
    }
  }
  
  void _onTabSelected(BuildContext context, int index) {
    String categoria;
    
    switch(index) {
      case 0:
        categoria = 'aprendiz';
        break;
      case 1:
        categoria = 'companero';
        break;
      case 2:
        categoria = 'maestro';
        break;
      default:
        categoria = 'aprendiz';
    }
    
    // Si hay texto en la búsqueda, filtrar por búsqueda y categoría
    if (_searchController.text.isNotEmpty) {
      context.read<DocumentosBloc>().add(SearchDocumentos(
        query: _searchController.text,
        categoria: categoria,
      ));
    } else {
      // Si no hay búsqueda, solo filtrar por categoría
      context.read<DocumentosBloc>().add(LoadDocumentos(categoria: categoria));
    }
  }
  
  void _onSearch(BuildContext context, String query) {
    if (query.length >= 3) {
      // Solo buscar si hay al menos 3 caracteres
      final currentTabIndex = _tabController.index;
      String categoria;
      
      switch(currentTabIndex) {
        case 0:
          categoria = 'aprendiz';
          break;
        case 1:
          categoria = 'companero';
          break;
        case 2:
          categoria = 'maestro';
          break;
        default:
          categoria = 'aprendiz';
      }
      
      context.read<DocumentosBloc>().add(SearchDocumentos(
        query: query,
        categoria: categoria,
      ));
    } else if (query.isEmpty) {
      _onSearchCleared(context);
    }
  }
  
  void _onSearchCleared(BuildContext context) {
    final currentTabIndex = _tabController.index;
    String categoria;
    
    switch(currentTabIndex) {
      case 0:
        categoria = 'aprendiz';
        break;
      case 1:
        categoria = 'companero';
        break;
      case 2:
        categoria = 'maestro';
        break;
      default:
        categoria = 'aprendiz';
    }
    
    context.read<DocumentosBloc>().add(LoadDocumentos(categoria: categoria));
  }
  
  Widget _buildDocumentosListView(BuildContext context, String categoria) {
    return BlocBuilder<DocumentosBloc, DocumentosState>(
      builder: (context, state) {
        if (state is DocumentosInitial) {
          // Disparar evento para cargar documentos al iniciar
          context.read<DocumentosBloc>().add(LoadDocumentos(categoria: categoria));
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is DocumentosLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is DocumentosError) {
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
                    context.read<DocumentosBloc>().add(LoadDocumentos(categoria: categoria));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        if (state is DocumentosLoaded) {
          // Filtrar documentos por categoría y por tipo (documentos/planchas)
          final documentosFiltrados = state.documentos
              .where((doc) => doc.categoria == categoria)
              .where((doc) => doc.esPlancha == _showPlanchas)
              .toList();
          
          if (documentosFiltrados.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showPlanchas ? Icons.assignment_outlined : Icons.folder_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'No se encontraron ${_showPlanchas ? "planchas" : "documentos"} para: "${state.searchQuery}"'
                        : 'No hay ${_showPlanchas ? "planchas" : "documentos"} disponibles',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadDocumentoPage(
                            categoria: categoria,
                            esPlancha: _showPlanchas,
                          ),
                        ),
                      ).then((_) {
                        // Recargar documentos cuando regresemos
                        _onTabSelected(context, _tabController.index);
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: Text('Subir ${_showPlanchas ? "plancha" : "documento"}'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DocumentosBloc>().add(LoadDocumentos(categoria: categoria));
            },
            child: ListView.builder(
              itemCount: documentosFiltrados.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final documento = documentosFiltrados[index];
                return _buildDocumentoCard(context, documento);
              },
            ),
          );
        }
        
        // Estado no manejado
        return const Center(child: Text('Estado no manejado'));
      },
    );
  }
  
  Widget _buildDocumentoCard(BuildContext context, Documento documento) {
    // Formato de fecha
    final dateFormat = DateFormat('dd/MM/yyyy');
    final fechaFormateada = dateFormat.format(documento.createdAt);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: _getTipoDocumentoIcon(documento.tipo),
        title: Text(
          documento.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (documento.descripcion != null && documento.descripcion!.isNotEmpty)
              Text(
                documento.descripcion!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  fechaFormateada,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                if (documento.autorNombre != null) ...[
                  const Icon(Icons.person, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Por: ${documento.autorNombre}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Si es plancha, mostrar estado
            if (documento.esPlancha && documento.planchaEstado != null)
              _getPlanchaEstadoChip(documento.planchaEstado!),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          // Navegar a la página de detalles del documento
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentoDetailPage(documentoId: documento.id),
            ),
          );
        },
      ),
    );
  }
  
  Widget _getTipoDocumentoIcon(String tipo) {
    IconData iconData;
    Color iconColor;
    
    switch (tipo.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case 'ppt':
      case 'pptx':
        iconData = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.image;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 28,
      ),
    );
  }
  
  Widget _getPlanchaEstadoChip(String estado) {
    Color chipColor;
    String label;
    
    switch (estado.toLowerCase()) {
      case 'aprobada':
        chipColor = Colors.green;
        label = 'Aprobada';
        break;
      case 'rechazada':
        chipColor = Colors.red;
        label = 'Rechazada';
        break;
      case 'pendiente':
      default:
        chipColor = Colors.amber;
        label = 'Pendiente';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
        ),
      ),
    );
  }
}