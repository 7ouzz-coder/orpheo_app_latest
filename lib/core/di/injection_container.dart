// lib/core/di/injection_container.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:orpheo_app/core/network/http_service.dart';
import 'package:orpheo_app/core/network/network_info.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:orpheo_app/data/datasources/remote/documentos_remote_datasource.dart';
import 'package:orpheo_app/data/datasources/remote/miembros_remote_datasource.dart';
import 'package:orpheo_app/data/datasources/remote/programas_remote_datasource.dart';
import 'package:orpheo_app/data/repositories/auth_repository_impl.dart';
import 'package:orpheo_app/data/repositories/documentos_repository_impl.dart';
import 'package:orpheo_app/data/repositories/miembros_repository_impl.dart';
import 'package:orpheo_app/data/repositories/programas_repository_impl.dart';
import 'package:orpheo_app/domain/repositories/auth_repository.dart';
import 'package:orpheo_app/domain/repositories/documentos_repository.dart';
import 'package:orpheo_app/domain/repositories/miembros_repository.dart';
import 'package:orpheo_app/domain/repositories/programas_repository.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_bloc.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_bloc.dart';
import 'package:orpheo_app/presentation/bloc/programas/programas_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  
  //! Helpers
  sl.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper(sl()),
  );
  
  //! Core
  // Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );
  
  // HTTP Service
  sl.registerLazySingleton<HttpService>(
    () => HttpService(
      client: sl(),
      secureStorage: sl(),
    ),
  );

  //! Features - Auth
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      httpService: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Bloc
  sl.registerFactory(
  () => AuthBloc(
    authRepository: sl(),
    authRemoteDataSource: sl(),
    secureStorage: sl(),
  ),
);
  
  //! Features - Miembros
  // Data sources
  sl.registerLazySingleton<MiembrosRemoteDataSource>(
    () => MiembrosRemoteDataSource(
      httpService: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<MiembrosRepository>(
    () => MiembrosRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Bloc
  sl.registerFactory(
    () => MiembrosBloc(
      miembrosRepository: sl(),
    ),
  );
  
  //! Features - Documentos
  // Data sources
  sl.registerLazySingleton<DocumentosRemoteDataSource>(
    () => DocumentosRemoteDataSource(
      httpService: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<DocumentosRepository>(
    () => DocumentosRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Bloc
  sl.registerFactory(
    () => DocumentosBloc(
      documentosRepository: sl(),
    ),
  );
  
  //! Features - Programas
  // Data sources
  sl.registerLazySingleton<ProgramasRemoteDataSource>(
    () => ProgramasRemoteDataSource(
      httpService: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<ProgramasRepository>(
    () => ProgramasRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Bloc
  sl.registerFactory(
    () => ProgramasBloc(
      programasRepository: sl(),
    ),
  );
}