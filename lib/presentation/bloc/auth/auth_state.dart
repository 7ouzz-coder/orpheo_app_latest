// lib/presentation/bloc/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:orpheo_app/data/models/auth/login_response_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

// Estado inicial - No sabemos si el usuario está autenticado
class AuthInitial extends AuthState {}

// Estado de carga mientras verificamos autenticación
class AuthLoading extends AuthState {}

// Estado de autenticación exitosa
class AuthAuthenticated extends AuthState {
  final UserModel user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

// Estado de no autenticado
class AuthUnauthenticated extends AuthState {}

// Estado de error en autenticación
class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Estado de registro exitoso
class AuthRegistrationSuccess extends AuthState {
  final String message;
  
  const AuthRegistrationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Estado de error en registro
class AuthRegistrationError extends AuthState {
  final String message;
  
  const AuthRegistrationError(this.message);
  
  @override
  List<Object?> get props => [message];
}