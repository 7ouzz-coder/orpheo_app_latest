// lib/presentation/pages/programas/programas_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:intl/intl.dart';

class ProgramasPage extends StatefulWidget {
  const ProgramasPage({Key? key}) : super(key: key);

  @override
  State<ProgramasPage> createState() => _ProgramasPageState();
}

class _ProgramasPageState extends State<ProgramasPage> with SingleTickerProviderStateMixin {
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
        title: const Text('Programas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Próximos'),
            Tab(text: 'Pasados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgramasList(true), // Próximos
          _buildProgramasList(false), // Pasados
        ],
      ),
      floatingActionButton: _userGrado == 'maestro' ? FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función de crear programa no implementada aún')),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }
  
  Widget _buildProgramasList(bool proximos) {
    // Aquí, en una implementación real, cargarías datos desde el backend
    // Por ahora, usamos datos simulados
    
    final ahora = DateTime.now();
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final formatoHora = DateFormat('HH:mm');
    
    final List<Map<String, dynamic>> programasSimulados = [
      {
        'id': 1,
        'tema': 'Tenida de Primer Grado',
        'fecha': DateTime.now().add(const Duration(days: 7)),
        'ubicacion': 'Templo Principal',
        'grado': 'aprendiz',
        'encargado': 'Juan Pérez',
        'descripcion': 'Tenida regular de primer grado con trabajo de aprendiz.',
      },
      {
        'id': 2,
        'tema': 'Tenida de Instrucción',
        'fecha': DateTime.now().add(const Duration(days: 14)),
        'ubicacion': 'Templo Principal',
        'grado': 'aprendiz',
        'encargado': 'Carlos Rodríguez',
        'descripcion': 'Instrucción sobre simbolismo del primer grado.',
      },
      {
        'id': 3,
        'tema': 'Tenida de Segundo Grado',
        'fecha': DateTime.now().add(const Duration(days: 10)),
        'ubicacion': 'Templo Principal',
        'grado': 'companero',
        'encargado': 'Roberto Gómez',
        'descripcion': 'Tenida regular de segundo grado con trabajo de compañero.',
      },
      {
        'id': 4,
        'tema': 'Tenida de Maestría',
        'fecha': DateTime.now().add(const Duration(days: 21)),
        'ubicacion': 'Templo Principal',
        'grado': 'maestro',
        'encargado': 'Miguel Sánchez',
        'descripcion': 'Tenida regular de tercer grado con trabajo de maestro.',
      },
      {
        'id': 5,
        'tema': 'Tenida Administrativa',
        'fecha': DateTime.now().subtract(const Duration(days: 5)),
        'ubicacion': 'Cámara del Medio',
        'grado': 'maestro',
        'encargado': 'Eduardo Martínez',
        'descripcion': 'Reunión administrativa para tratar asuntos de la logia.',
      },
      {
        'id': 6,
        'tema': 'Tenida de Primer Grado',
        'fecha': DateTime.now().subtract(const Duration(days: 12)),
        'ubicacion': 'Templo Principal',
        'grado': 'aprendiz',
        'encargado': 'Juan Pérez',
        'descripcion': 'Tenida regular de primer grado con trabajo de aprendiz.',
      },
    ];
    
    // Filtrar por fecha (próximos o pasados)
    final programasFiltradosPorFecha = programasSimulados.where((programa) {
      final fechaPrograma = programa['fecha'] as DateTime;
      return proximos ? fechaPrograma.isAfter(ahora) : fechaPrograma.isBefore(ahora);
    }).toList();
    
    // Filtrar por grado del usuario
    final programasFiltrados = programasFiltradosPorFecha.where((programa) {
      switch (_userGrado) {
        case 'maestro':
          return true; // Puede ver todos los programas
        case 'companero':
          return programa['grado'] == 'aprendiz' || programa['grado'] == 'companero';
        case 'aprendiz':
        default:
          return programa['grado'] == 'aprendiz';
      }
    }).toList();
    
    // Ordenar cronológicamente
    programasFiltrados.sort((a, b) {
      final fechaA = a['fecha'] as DateTime;
      final fechaB = b['fecha'] as DateTime;
      return proximos ? fechaA.compareTo(fechaB) : fechaB.compareTo(fechaA);
    });
    
    if (programasFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              proximos ? 'No hay programas próximos' : 'No hay programas pasados',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: programasFiltrados.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final programa = programasFiltrados[index];
        final fecha = programa['fecha'] as DateTime;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con fecha
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _getColorForGrado(programa['grado'] as String),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      formatoFecha.format(fecha),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatoHora.format(fecha),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programa['tema'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(Icons.location_on, programa['ubicacion'] as String),
                    const SizedBox(height: 4),
                    _buildInfoItem(Icons.person, 'Encargado: ${programa['encargado'] as String}'),
                    const SizedBox(height: 4),
                    _buildInfoItem(Icons.group, 'Grado: ${_capitalizeFirstLetter(programa['grado'] as String)}'),
                    const SizedBox(height: 8),
                    Text(
                      programa['descripcion'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Acciones
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (proximos) ...[
                      TextButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirmar'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Asistencia confirmada para: ${programa['tema']}')),
                          );
                        },
                      ),
                    ],
                    TextButton.icon(
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Detalles'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detalles de: ${programa['tema']}')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
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
}