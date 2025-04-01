// lib/presentation/bloc/auth/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Evento para verificar el estado de autenticación al iniciar la app
class AppStarted extends AuthEvent {}

// Evento para realizar el inicio de sesión
class LoggedIn extends AuthEvent {
  final String username;
  final String password;
  final bool rememberMe;

  const LoggedIn({
    required this.username, 
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [username, password, rememberMe];
}

// Evento para registrar un nuevo usuario
class RegisterUser extends AuthEvent {
  final Map<String, dynamic> userData;

  const RegisterUser({required this.userData});

  @override
  List<Object?> get props => [userData];
}

// Evento para cerrar sesión
class LoggedOut extends AuthEvent {}