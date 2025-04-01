// lib/presentation/pages/documentos/documentos_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';

class DocumentosPage extends StatefulWidget {
  const DocumentosPage({Key? key}) : super(key: key);

  @override
  State<DocumentosPage> createState() => _DocumentosPageState();
}

class _DocumentosPageState extends State<DocumentosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userGrado = 'aprendiz';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserGrado();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Documentos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Documentos'),
            Tab(text: 'Planchas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDocumentosList(),
          _buildPlanchasList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDocumentDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildDocumentosList() {
    // Aquí, en una implementación real, cargarías datos desde el backend
    // Por ahora, usamos datos simulados con filtro según el grado del usuario
    
    final List<Map<String, dynamic>> documentosSimulados = [
      {
        'nombre': 'Manual del Aprendiz',
        'tipo': 'pdf',
        'grado': 'aprendiz',
        'fecha': '10/03/2025',
      },
      {
        'nombre': 'Simbolismo del Primer Grado',
        'tipo': 'pdf',
        'grado': 'aprendiz',
        'fecha': '15/02/2025',
      },
      {
        'nombre': 'Manual del Compañero',
        'tipo': 'pdf',
        'grado': 'companero',
        'fecha': '05/01/2025',
      },
      {
        'nombre': 'Simbolismo del Segundo Grado',
        'tipo': 'pdf',
        'grado': 'companero',
        'fecha': '20/02/2025',
      },
      {
        'nombre': 'Manual del Maestro',
        'tipo': 'pdf',
        'grado': 'maestro',
        'fecha': '12/12/2024',
      },
      {
        'nombre': 'Simbolismo del Tercer Grado',
        'tipo': 'pdf',
        'grado': 'maestro',
        'fecha': '30/01/2025',
      },
    ];
    
    // Filtrar documentos según el grado del usuario
    final documentosFiltrados = documentosSimulados.where((doc) {
      switch (_userGrado) {
        case 'maestro':
          return true; // Puede ver todos los documentos
        case 'companero':
          return doc['grado'] == 'aprendiz' || doc['grado'] == 'companero';
        case 'aprendiz':
        default:
          return doc['grado'] == 'aprendiz';
      }
    }).toList();
    
    if (documentosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay documentos disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Para tu grado: $_userGrado',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: documentosFiltrados.length,
      itemBuilder: (context, index) {
        final documento = documentosFiltrados[index];
        return ListTile(
          leading: _getIconForDocumentType(documento['tipo']),
          title: Text(documento['nombre']),
          subtitle: Text('Grado: ${_capitalizeFirstLetter(documento['grado'])} • ${documento['fecha']}'),
          trailing: const Icon(Icons.download),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Visualizando ${documento['nombre']}')),
            );
          },
        );
      },
    );
  }
  
  Widget _buildPlanchasList() {
    // Lista de planchas, similar a documentos pero con un tipo diferente
    final List<Map<String, dynamic>> planchasSimuladas = [
      {
        'nombre': 'Plancha sobre Historia',
        'autor': 'Juan Pérez',
        'grado': 'aprendiz',
        'fecha': '05/03/2025',
        'estado': 'aprobada',
      },
      {
        'nombre': 'Plancha sobre Simbolismo',
        'autor': 'Carlos Rodríguez',
        'grado': 'aprendiz',
        'fecha': '10/02/2025',
        'estado': 'pendiente',
      },
      {
        'nombre': 'Plancha sobre Filosofía',
        'autor': 'Roberto Gómez',
        'grado': 'companero',
        'fecha': '15/02/2025',
        'estado': 'aprobada',
      },
      {
        'nombre': 'Plancha sobre Arte y Masonería',
        'autor': 'Miguel Sánchez',
        'grado': 'maestro',
        'fecha': '20/01/2025',
        'estado': 'aprobada',
      },
    ];
    
    // Filtrar planchas según el grado del usuario
    final planchasFiltradas = planchasSimuladas.where((plancha) {
      switch (_userGrado) {
        case 'maestro':
          return true; // Puede ver todas las planchas
        case 'companero':
          return plancha['grado'] == 'aprendiz' || plancha['grado'] == 'companero';
        case 'aprendiz':
        default:
          return plancha['grado'] == 'aprendiz';
      }
    }).toList();
    
    if (planchasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay planchas disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: planchasFiltradas.length,
      itemBuilder: (context, index) {
        final plancha = planchasFiltradas[index];
        return ListTile(
          leading: const Icon(Icons.article),
          title: Text(plancha['nombre']),
          subtitle: Text('Por: ${plancha['autor']} • ${plancha['fecha']}'),
          trailing: _getChipForEstado(plancha['estado']),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Visualizando ${plancha['nombre']}')),
            );
          },
        );
      },
    );
  }
  
  Widget _getIconForDocumentType(String tipo) {
    switch (tipo) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }
  
  Widget _getChipForEstado(String estado) {
    Color chipColor;
    IconData iconData;
    
    switch (estado) {
      case 'aprobada':
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'pendiente':
        chipColor = Colors.amber;
        iconData = Icons.pending;
        break;
      case 'rechazada':
        chipColor = Colors.red;
        iconData = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey;
        iconData = Icons.help;
    }
    
    return Chip(
      label: Text(_capitalizeFirstLetter(estado)),
      backgroundColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
      avatar: Icon(iconData, color: chipColor, size: 16),
    );
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  void _showAddDocumentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subir Documento'),
        content: const Text('Esta funcionalidad será implementada próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}