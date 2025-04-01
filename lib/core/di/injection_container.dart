// lib/core/di/injection_container.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:orpheo_app/data/repositories/auth_repository_impl.dart';
import 'package:orpheo_app/domain/repositories/auth_repository.dart';
import 'package:orpheo_app/presentation/bloc/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      authRemoteDataSource: sl(),
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
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(client: sl()),
  );
  
  sl.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper(sl()),
  );
  
  //! Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  
  //! External
  sl.registerLazySingleton(() => http.Client());
}