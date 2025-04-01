// lib/presentation/pages/notificaciones/notificaciones_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({Key? key}) : super(key: key);

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  bool _isLoading = true;
  String _userGrado = 'aprendiz';
  List<Map<String, dynamic>> _notificaciones = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final secureStorage = SecureStorageHelper(const FlutterSecureStorage());
      final grado = await secureStorage.getValueOrDefault('grado', 'grado', defaultValue: 'aprendiz');
      
      // Simulamos la carga de notificaciones
      await Future.delayed(const Duration(seconds: 1));
      
      // Creamos notificaciones simuladas
      final notificacionesSimuladas = [
        {
          'id': 1,
          'titulo': 'Nueva plancha disponible',
          'mensaje': 'Se ha publicado una nueva plancha sobre simbolismo.',
          'fecha': '2025-03-18T10:30:00',
          'leido': false,
          'tipo': 'documento',
          'grado': 'aprendiz',
        },
        {
          'id': 2,
          'titulo': 'Próxima tenida',
          'mensaje': 'Recuerda la tenida programada para el próximo viernes.',
          'fecha': '2025-03-17T15:45:00',
          'leido': true,
          'tipo': 'evento',
          'grado': 'aprendiz',
        },
        {
          'id': 3,
          'titulo': 'Actualización de documentos',
          'mensaje': 'Se ha actualizado el manual del compañero.',
          'fecha': '2025-03-16T09:20:00',
          'leido': false,
          'tipo': 'documento',
          'grado': 'companero',
        },
        {
          'id': 4,
          'titulo': 'Actualización de documentos',
          'mensaje': 'Se ha actualizado el manual del maestro.',
          'fecha': '2025-03-15T14:10:00',
          'leido': false,
          'tipo': 'documento',
          'grado': 'maestro',
        },
        {
          'id': 5,
          'titulo': 'Mensaje del Venerable Maestro',
          'mensaje': 'Mensaje importante para todos los hermanos.',
          'fecha': '2025-03-14T11:05:00',
          'leido': true,
          'tipo': 'mensaje',
          'grado': 'aprendiz',
        },
      ];

      // Filtrar notificaciones según el grado del usuario
      final notificacionesFiltradas = notificacionesSimuladas.where((notif) {
        switch (grado) {
          case 'maestro':
            return true; // Puede ver todas las notificaciones
          case 'companero':
            return notif['grado'] == 'aprendiz' || notif['grado'] == 'companero';
          case 'aprendiz':
          default:
            return notif['grado'] == 'aprendiz';
        }
      }).toList();
      
      setState(() {
        _userGrado = grado;
        _notificaciones = notificacionesFiltradas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar notificaciones: $e')),
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
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Marcar todas como leídas',
            onPressed: () {
              setState(() {
                for (var notif in _notificaciones) {
                  notif['leido'] = true;
                }
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todas las notificaciones marcadas como leídas')),
              );
            },
          ),
        ],
      ),
      body: _notificaciones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes notificaciones',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: ListView.builder(
                itemCount: _notificaciones.length,
                itemBuilder: (context, index) {
                  final notif = _notificaciones[index];
                  final fecha = DateTime.parse(notif['fecha'] as String);
                  final ahora = DateTime.now();
                  final diferencia = ahora.difference(fecha);
                  
                  String fechaFormateada;
                  if (diferencia.inDays == 0) {
                    fechaFormateada = 'Hoy ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
                  } else if (diferencia.inDays == 1) {
                    fechaFormateada = 'Ayer ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
                  } else {
                    fechaFormateada = '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
                  }
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    color: notif['leido'] as bool ? null : Colors.blue.shade50,
                    child: ListTile(
                      leading: _getIconForType(notif['tipo'] as String),
                      title: Text(
                        notif['titulo'] as String,
                        style: TextStyle(
                          fontWeight: notif['leido'] as bool ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif['mensaje'] as String),
                          const SizedBox(height: 4),
                          Text(
                            fechaFormateada,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        setState(() {
                          notif['leido'] = true;
                        });
                        
                        // Aquí iría la navegación al detalle de la notificación
                        // o a la pantalla relacionada
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Notificación: ${notif['titulo']}')),
                        );
                      },
                      trailing: !notif['leido'] as bool
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
  
  Widget _getIconForType(String tipo) {
    switch (tipo) {
      case 'documento':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.description, color: Colors.orange),
        );
      case 'evento':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.event, color: Colors.green),
        );
      case 'mensaje':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.message, color: Colors.purple),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications, color: Colors.blue),
        );
    }
  }
}