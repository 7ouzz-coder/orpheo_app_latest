import 'package:flutter/material.dart';
// Comenta o corrige las importaciones que causan problemas
// import 'package:orpheo_app/presentation/pages/auth/login_screen.dart';
// import 'package:orpheo_app/presentation/pages/auth/register_screen.dart';
// import 'package:orpheo_app/presentation/pages/auth/splash_screen.dart';
import 'package:orpheo_app/presentation/pages/grados/home_page.dart';

// Importar las nuevas páginas que vamos a crear
// import 'package:orpheo_app/presentation/pages/miembros/miembros_page.dart';
// import 'package:orpheo_app/presentation/pages/documentos/documentos_page.dart';
// import 'package:orpheo_app/presentation/pages/programas/programas_page.dart';
// import 'package:orpheo_app/presentation/pages/notificaciones/notificaciones_page.dart';
// import 'package:orpheo_app/presentation/pages/perfil/perfil_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case '/':
        // return MaterialPageRoute(builder: (_) => const SplashScreen());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('SplashScreen - Pendiente de implementar'),
            ),
          ),
        );
      case '/login':
        // return MaterialPageRoute(builder: (_) => const LoginScreen());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('LoginScreen - Pendiente de implementar'),
            ),
          ),
        );
      case '/register':
        // return MaterialPageRoute(builder: (_) => const RegisterScreen());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('RegisterScreen - Pendiente de implementar'),
            ),
          ),
        );
      
      // Main Routes
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      // Feature Routes
      case '/miembros':
        // return MaterialPageRoute(builder: (_) => const MiembrosPage());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('MiembrosPage - Pendiente de implementar'),
            ),
          ),
        );
      case '/documentos':
        // return MaterialPageRoute(builder: (_) => const DocumentosPage());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('DocumentosPage - Pendiente de implementar'),
            ),
          ),
        );
      case '/programas':
        // return MaterialPageRoute(builder: (_) => const ProgramasPage());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('ProgramasPage - Pendiente de implementar'),
            ),
          ),
        );
      case '/notificaciones':
        // return MaterialPageRoute(builder: (_) => const NotificacionesPage());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('NotificacionesPage - Pendiente de implementar'),
            ),
          ),
        );
      case '/perfil':
        // return MaterialPageRoute(builder: (_) => const PerfilPage());
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('PerfilPage - Pendiente de implementar'),
            ),
          ),
        );
        
      // Default - Invalid route
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}