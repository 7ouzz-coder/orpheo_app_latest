import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_event.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource authRemoteDataSource;
  final SecureStorageHelper secureStorage;
  
  AuthBloc({
    required this.authRemoteDataSource,
    required this.secureStorage,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<RegisterUser>(_onRegisterUser);
    on<LoggedOut>(_onLoggedOut);
  }
  
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final token = await secureStorage.getToken();
      
      if (token != null && token.isNotEmpty) {
        // Si tenemos un token, obtenemos los datos del usuario
        final username = await secureStorage.getValueOrDefault('username', 'username');
        final memberFullName = await secureStorage.getValueOrDefault('member_full_name', 'username');
        final grado = await secureStorage.getValueOrDefault('grado', 'grado', defaultValue: 'aprendiz');
        final role = await secureStorage.getValueOrDefault('role', 'role', defaultValue: 'general');
        final cargo = await secureStorage.getValueOrDefault('cargo', 'cargo', defaultValue: '');
        final email = await secureStorage.getValueOrDefault('email', 'email', defaultValue: '');
        final id = await secureStorage.getValueOrDefault('id', 'id', defaultValue: '0');
        final miembroId = await secureStorage.read(key: 'miembro_id') ?? null;
        
        // Reconstruimos el objeto usuario
        final user = UserModel(
          id: int.parse(id),
          username: username,
          email: email,
          role: role,
          grado: grado,
          cargo: cargo.isEmpty ? null : cargo,
          memberFullName: memberFullName,
          miembroId: miembroId != null ? int.parse(miembroId) : null,
        );
        
        // Emitimos estado autenticado
        emit(AuthAuthenticated(user));
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
      final response = await authRemoteDataSource.login(
        event.username,
        event.password,
      );
      
      // Guardar token y datos de usuario
      await secureStorage.saveToken(response.token);
      
      final userData = {
        'id': response.user.id.toString(),
        'username': response.user.username,
        'role': response.user.role,
        'grado': response.user.grado,
        'cargo': response.user.cargo,
        'memberFullName': response.user.memberFullName,
        'miembroId': response.user.miembroId != null 
            ? response.user.miembroId.toString() 
            : null,
        'email': response.user.email,
      };
      
      await secureStorage.saveUserData(userData);
      
      // Si está marcado "recordarme", guardar preferencia
      if (event.rememberMe) {
        try {
          // Si existe el método savePreference
          await secureStorage.savePreference('remember_me', 'true');
        } catch (e) {
          // Si no existe, ignoramos el error
          print('Método savePreference no implementado: $e');
        }
      }
      
      // Emitir estado autenticado
      emit(AuthAuthenticated(response.user));
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
      final response = await authRemoteDataSource.register(event.userData);
      
      if (response.success) {
        emit(AuthRegistrationSuccess(response.message));
      } else {
        emit(AuthRegistrationError('Error en el registro: ${response.message}'));
      }
    } catch (e) {
      emit(AuthRegistrationError('Error en el registro: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await secureStorage.clearAll();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Error al cerrar sesión: ${e.toString()}'));
    }
  }
}