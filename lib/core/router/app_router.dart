import 'package:flutter/material.dart';
import 'package:orpheo_app/presentation/pages/auth/login_screen.dart';
import 'package:orpheo_app/presentation/pages/auth/register_screen.dart';
import 'package:orpheo_app/presentation/pages/auth/splash_screen.dart';
import 'package:orpheo_app/presentation/pages/grados/home_page.dart';

// Importar las nuevas páginas que vamos a crear
import 'package:orpheo_app/presentation/pages/miembros/miembros_page.dart';
import 'package:orpheo_app/presentation/pages/documentos/documentos_page.dart';
import 'package:orpheo_app/presentation/pages/programas/programas_page.dart';
import 'package:orpheo_app/presentation/pages/notificaciones/notificaciones_page.dart';
import 'package:orpheo_app/presentation/pages/perfil/perfil_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      // Main Routes
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      // Feature Routes
      case '/miembros':
        return MaterialPageRoute(builder: (_) => const MiembrosPage());
      case '/documentos':
        return MaterialPageRoute(builder: (_) => const DocumentosPage());
      case '/programas':
        return MaterialPageRoute(builder: (_) => const ProgramasPage());
      case '/notificaciones':
        return MaterialPageRoute(builder: (_) => const NotificacionesPage());
      case '/perfil':
        return MaterialPageRoute(builder: (_) => const PerfilPage());
        
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