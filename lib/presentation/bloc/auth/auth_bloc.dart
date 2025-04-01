import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:orpheo_app/data/models/auth/login_response_model.dart';
import 'package:orpheo_app/domain/repositories/auth_repository.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_event.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource authRemoteDataSource;
  final SecureStorageHelper secureStorage;
  final AuthRepository authRepository;
  
  AuthBloc({
    required this.authRemoteDataSource,
    required this.secureStorage,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<RegisterUser>(_onRegisterUser);
    on<LoggedOut>(_onLoggedOut);
  }
  
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final isAuthenticated = await authRepository.isAuthenticated();
      
      if (isAuthenticated) {
        // Si estamos autenticados, obtenemos los datos del usuario actual
        final userResult = await authRepository.getCurrentUser();
        
        userResult.fold(
          (failure) => emit(AuthUnauthenticated()), 
          (user) => emit(AuthAuthenticated(user))
        );
      } else {
        // No hay token o token inválido
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Error al verificar autenticación
      emit(AuthUnauthenticated());
    }
  }
  
  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final result = await authRepository.login(
        event.username,
        event.password,
      );
      
      result.fold(
        (failure) => emit(AuthError(failure.message)), 
        (loginResponse) {
          // Si está marcado "recordarme", guardar preferencia
          if (event.rememberMe) {
            secureStorage.savePreference('remember_me', 'true');
          }
          
          // Emitir estado autenticado
          emit(AuthAuthenticated(loginResponse.user));
        }
      );
    } catch (e) {
      // Error en inicio de sesión
      String errorMessage = 'Error de inicio de sesión';
      if (e.toString().contains('Credenciales inválidas')) {
        errorMessage = 'Usuario o contraseña incorrectos';
      } else if (e.toString().contains('inactivo')) {
        errorMessage = 'Su cuenta está inactiva o pendiente de aprobación';
      }
      
      emit(AuthError(errorMessage));
    }
  }
  
  Future<void> _onRegisterUser(RegisterUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final result = await authRepository.register(event.userData);
      
      result.fold(
        (failure) => emit(AuthRegistrationError(failure.message)), 
        (success) {
          if (success) {
            emit(const AuthRegistrationSuccess('Registro exitoso. Por favor inicie sesión.'));
          } else {
            emit(const AuthRegistrationError('Error en el registro. Intente nuevamente.'));
          }
        }
      );
    } catch (e) {
      emit(AuthRegistrationError('Error en el registro: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final result = await authRepository.logout();
      
      result.fold(
        (failure) => emit(AuthError(failure.message)), 
        (_) => emit(AuthUnauthenticated())
      );
    } catch (e) {
      emit(AuthError('Error al cerrar sesión: ${e.toString()}'));
    }
  }
}