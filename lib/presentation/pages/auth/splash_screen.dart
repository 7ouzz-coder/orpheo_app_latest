// lib/presentation/pages/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }
  
  Future<void> _checkAuthentication() async {
    // Esperar un poco para mostrar la pantalla de splash
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      final secureStorage = SecureStorageHelper(const FlutterSecureStorage());
      final token = await secureStorage.getToken();
      
      if (mounted) {
        if (token != null && token.isNotEmpty) {
          // Usuario autenticado, ir a home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // No autenticado, ir a login
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      // Error, ir a login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance, 
                size: 60, 
                color: Colors.blue
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Orpheo App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}