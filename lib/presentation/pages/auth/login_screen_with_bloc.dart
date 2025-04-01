// lib/presentation/pages/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_event.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bienvenido, ${state.user.memberFullName ?? state.user.username}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
            
            // Navegar a la página principal
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: state is AuthLoading 
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                width: screenSize.width * 0.3,
                                height: screenSize.width * 0.3,
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
                            ),
                            const SizedBox(height: 24),
                            
                            // Título
                            const Text(
                              'Orpheo App',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Formulario
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su nombre de usuario';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su contraseña';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            
                            // Opciones adicionales
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Opción "Recordarme"
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                    ),
                                    const Text('Recordarme'),
                                  ],
                                ),
                                
                                // Olvidó contraseña
                                TextButton(
                                  onPressed: () {
                                    // Implementar después
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Función no implementada aún'),
                                      ),
                                    );
                                  },
                                  child: const Text('¿Olvidó su contraseña?'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Botón de login
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Disparar evento de login en el Bloc
                                    context.read<AuthBloc>().add(
                                      LoggedIn(
                                        username: _usernameController.text,
                                        password: _passwordController.text,
                                        rememberMe: _rememberMe,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Link a registro
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('¿No tiene una cuenta?'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: const Text('Regístrese'),
                                ),
                              ],
                            ),
                            
                            // Versión
                            const SizedBox(height: 16),
                            Text(
                              'Orpheo App v1.0.0',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            // Credenciales para test
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () => _showTestCredentialsDialog(context),
                              child: const Text('Ver credenciales de prueba'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
  
  void _showTestCredentialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Credenciales de Prueba'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Administrador:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Usuario: admin'),
                Text('• Contraseña: admin123'),
                SizedBox(height: 10),
                Text('Maestro:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Usuario: maestro'),
                Text('• Contraseña: maestro123'),
                SizedBox(height: 10),
                Text('Compañero:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Usuario: companero'),
                Text('• Contraseña: companero123'),
                SizedBox(height: 10),
                Text('Aprendiz:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Usuario: aprendiz'),
                Text('• Contraseña: aprendiz123'),
                SizedBox(height: 10),
                Text('Secretario:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Usuario: secretario'),
                Text('• Contraseña: secretario123'),
                SizedBox(height: 10),
                Text('Tesorero:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Usuario: tesorero'),
                Text('• Contraseña: tesorero123'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}