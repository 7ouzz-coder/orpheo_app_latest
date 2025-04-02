// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orpheo_app/presentation/pages/auth/login_screen.dart';
import 'package:orpheo_app/presentation/pages/auth/register_screen.dart';
import 'package:orpheo_app/presentation/pages/auth/splash_screen.dart';
import 'package:orpheo_app/presentation/pages/grados/home_page.dart';
import 'package:orpheo_app/presentation/pages/programas/programas_page.dart';

class AppRouter {
  // Un método simple para generar rutas a través de MaterialPageRoute
  // Esto es lo que usamos actualmente en nuestra aplicación
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
      case '/programas':
        return MaterialPageRoute(builder: (_) => const ProgramasPage());
      
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
  
  // Una configuración de GoRouter para futuras implementaciones
  // No se usa actualmente, pero está lista para ser implementada
  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Auth Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      
      // Feature Routes
      GoRoute(
        path: '/programas',
        builder: (context, state) => const ProgramasPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}