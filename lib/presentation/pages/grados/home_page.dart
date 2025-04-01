// lib/presentation/pages/grados/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_event.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_state.dart';
import 'package:orpheo_app/presentation/pages/miembros/miembros_page.dart';
import 'package:orpheo_app/presentation/pages/documentos/documentos_page.dart';
import 'package:orpheo_app/presentation/pages/notificaciones/notificaciones_page.dart';
import 'package:orpheo_app/presentation/pages/perfil/perfil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  // Páginas que se mostrarán según la navegación
  late final List<Widget> _pages = [
    const _HomeContent(), // Contenido principal de la página Home
    const MiembrosPage(),
    const DocumentosPage(),
    const NotificacionesPage(),
    const PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Si el usuario no está autenticado, redirigir al login
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Miembros',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Contenido',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notificaciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Cabecera del drawer
                  UserAccountsDrawerHeader(
                    accountName: Text(state.user.memberFullName ?? state.user.username),
                    accountEmail: Text(state.user.email ?? ''),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        (state.user.memberFullName?.isNotEmpty ?? false)
                          ? state.user.memberFullName![0].toUpperCase()
                          : state.user.username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 36, color: Colors.blue),
                      ),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                    ),
                    otherAccountsPictures: [
                      _buildGradoIcon(state.user.grado),
                    ],
                  ),
                  
                  // Opciones del menu
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Inicio'),
                    selected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Miembros'),
                    selected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text('Documentos'),
                    selected: _currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Programas'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/programas');
                    },
                  ),
                  const Divider(),
                  
                  // Admin panel para usuarios con rol admin
                  if (state.user.role == 'admin') ...[
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Administración'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Panel de administración no implementado aún')),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                  
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Configuración'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configuración no implementada aún')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar Sesión'),
                    onTap: () {
                      Navigator.pop(context);
                      // Disparar evento de logout
                      context.read<AuthBloc>().add(LoggedOut());
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          // Mientras carga o si hay un error
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
  
  Widget _buildGradoIcon(String grado) {
    IconData icon;
    Color color;
    
    switch (grado.toLowerCase()) {
      case 'maestro':
        icon = Icons.star;
        color = Colors.blue;
        break;
      case 'companero':
        icon = Icons.star_half;
        color = Colors.green;
        break;
      case 'aprendiz':
      default:
        icon = Icons.star_border;
        color = Colors.amber;
        break;
    }
    
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: Icon(icon, color: color),
    );
  }
}

// Widget para el contenido principal de la página de inicio
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final username = state.user.memberFullName ?? state.user.username;
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Orpheo App'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Implementar notificaciones
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notificaciones no implementadas aún')),
                    );
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                // Implementar recarga de datos
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de bienvenida
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade700, Colors.blue.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Bienvenido, $username!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Accede a toda la información y recursos de la organización',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Resto del contenido es idéntico al HomeContent original
                    // ...
                    
                    // Resumen de estado
                    const Text(
                      'Resumen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tarjetas de estadísticas
                    Row(
                      children: [
                        _buildStatCard(
                          title: 'Miembros',
                          value: '45',
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          title: 'Programas',
                          value: '12',
                          icon: Icons.calendar_today,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        _buildStatCard(
                          title: 'Documentos',
                          value: '78',
                          icon: Icons.book,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          title: 'Notificaciones',
                          value: '3',
                          icon: Icons.notifications,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Próximas actividades
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Próximas Actividades',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar a listado completo
                            Navigator.pushNamed(context, '/programas');
                          },
                          child: const Text('Ver más'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Lista de actividades (simulada)
                    for (int i = 0; i < 3; i++)
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.event, color: Colors.blue),
                          ),
                          title: Text('Actividad ${i + 1}'),
                          subtitle: Text('Fecha: ${DateTime.now().add(Duration(days: i + 1)).toString().substring(0, 10)}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navegar a detalle de actividad
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Detalle de actividad no implementado aún')),
                            );
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Documentos recientes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Documentos Recientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar a documentos
                            final bottomNavBar = Scaffold.of(context).widget.bottomNavigationBar as BottomNavigationBar;
                            bottomNavBar.onTap!(2); // Índice 2 para Documentos
                          },
                          child: const Text('Ver más'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Lista de documentos (simulada)
                    for (int i = 0; i < 3; i++)
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.description, color: Colors.orange),
                          ),
                          title: Text('Documento ${i + 1}'),
                          subtitle: const Text('Tipo: PDF'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navegar a detalle de documento
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Detalle de documento no implementado aún')),
                            );
                          },
                        ),
                      ),
                    
                    // Sección de novedades
                    const SizedBox(height: 24),
                    const Text(
                      'Novedades',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bienvenido a la nueva versión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Esta aplicación está en desarrollo. Implementación con BLoC completa.',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Función no implementada aún')),
                                );
                              },
                              child: const Text('Saber más'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Pie de página
                    Center(
                      child: Text(
                        'Orpheo App v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
  
  // Método para construir tarjetas de estadísticas
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}