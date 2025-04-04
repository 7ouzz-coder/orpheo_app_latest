// lib/data/repositories/programas_repository_impl.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/core/network/network_info.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/programas_remote_datasource.dart';
import 'package:orpheo_app/domain/entities/asistencia.dart';
import 'package:orpheo_app/domain/entities/programa.dart';
import 'package:orpheo_app/domain/repositories/programas_repository.dart';

class ProgramasRepositoryImpl implements ProgramasRepository {
  final ProgramasRemoteDataSource remoteDataSource;
  final SecureStorageHelper secureStorage;
  final NetworkInfo networkInfo;
  
  ProgramasRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Programa>>> getProgramas() async {
    if (await networkInfo.isConnected) {
      try {
        final programas = await remoteDataSource.getProgramas();
        return Right(programas);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, List<Programa>>> getProgramasByGrado(String grado) async {
    if (await networkInfo.isConnected) {
      try {
        final programas = await remoteDataSource.getProgramasByGrado(grado);
        return Right(programas);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, List<Programa>>> getProgramasByEstado(String estado) async {
    if (await networkInfo.isConnected) {
      try {
        final programas = await remoteDataSource.getProgramasByEstado(estado);
        return Right(programas);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, List<Programa>>> getProximosProgramas() async {
    if (await networkInfo.isConnected) {
      try {
        final programas = await remoteDataSource.getProximosProgramas();
        return Right(programas);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, List<Programa>>> getProgramasPasados() async {
    if (await networkInfo.isConnected) {
      try {
        final programas = await remoteDataSource.getProgramasPasados();
        return Right(programas);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, Programa>> getProgramaById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final programa = await remoteDataSource.getProgramaById(id);
        return Right(programa);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, Programa>> createPrograma(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final programa = await remoteDataSource.createPrograma(data);
        return Right(programa);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, Programa>> updatePrograma(int id, Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final programa = await remoteDataSource.updatePrograma(id, data);
        return Right(programa);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deletePrograma(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deletePrograma(id);
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, List<Asistencia>>> getAsistenciaByPrograma(int programaId) async {
    if (await networkInfo.isConnected) {
      try {
        final asistencias = await remoteDataSource.getAsistenciaByPrograma(programaId);
        return Right(asistencias);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, Asistencia>> registrarAsistencia(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final asistencia = await remoteDataSource.registrarAsistencia(data);
        return Right(asistencia);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
  
  @override
  Future<Either<Failure, Asistencia>> updateAsistencia(int id, Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        final asistencia = await remoteDataSource.updateAsistencia(id, data);
        return Right(asistencia);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
}