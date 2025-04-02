// lib/core/di/injection_container.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:orpheo_app/data/datasources/remote/documentos_remote_datasource.dart';
import 'package:orpheo_app/data/datasources/remote/miembros_remote_datasource.dart';
import 'package:orpheo_app/data/repositories/auth_repository_impl.dart';
// Comentar o corregir rutas que den error:
// import 'package:orpheo_app/data/repositories/documentos_repository_impl.dart';
import 'package:orpheo_app/data/repositories/miembros_repository_impl.dart';
import 'package:orpheo_app/domain/repositories/auth_repository.dart';
import 'package:orpheo_app/domain/repositories/documentos_repository.dart';
import 'package:orpheo_app/domain/repositories/miembros_repository.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_bloc.dart';
// import 'package:orpheo_app/presentation/bloc/documentos/documentos_bloc.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      authRemoteDataSource: sl(),
      secureStorage: sl(),
      authRepository: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(client: sl()),
  );
  
  //! Features - Miembros
  // Bloc
  sl.registerFactory(
    () => MiembrosBloc(
      miembrosRepository: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<MiembrosRepository>(
    () => MiembrosRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<MiembrosRemoteDataSource>(
    () => MiembrosRemoteDataSource(
      client: sl(),
      secureStorage: sl(),
    ),
  );
  
  //! Features - Documentos
  // Comenta temporalmente lo que dé error
  // Bloc
  /*sl.registerFactory(
    () => DocumentosBloc(
      documentosRepository: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<DocumentosRepository>(
    () => DocumentosRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<DocumentosRemoteDataSource>(
    () => DocumentosRemoteDataSource(
      client: sl(),
      secureStorage: sl(),
    ),
  );*/
  
  //! Shared
  sl.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper(sl()),
  );
  
  //! Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  
  //! External
  sl.registerLazySingleton(() => http.Client());
}