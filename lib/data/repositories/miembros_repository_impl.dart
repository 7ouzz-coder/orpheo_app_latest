// lib/data/repositories/miembros_repository_impl.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/core/network/network_info.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/miembros_remote_datasource.dart';
import 'package:orpheo_app/domain/entities/miembro.dart';
import 'package:orpheo_app/domain/repositories/miembros_repository.dart';

class MiembrosRepositoryImpl implements MiembrosRepository {
  final MiembrosRemoteDataSource remoteDataSource;
  final SecureStorageHelper secureStorage;
  final NetworkInfo networkInfo;
  
  MiembrosRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Miembro>>> getMiembros() async {
    if (await networkInfo.isConnected) {
      try {
        final miembros = await remoteDataSource.getMiembros();
        return Right(miembros);
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
  Future<Either<Failure, List<Miembro>>> getMiembrosByGrado(String grado) async {
    if (await networkInfo.isConnected) {
      try {
        final miembros = await remoteDataSource.getMiembrosByGrado(grado);
        return Right(miembros);
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
  Future<Either<Failure, Miembro>> getMiembroById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final miembro = await remoteDataSource.getMiembroById(id);
        return Right(miembro);
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
  Future<Either<Failure, bool>> updateMiembro(int id, Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateMiembro(id, data);
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
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
  Future<Either<Failure, bool>> createMiembro(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.createMiembro(data);
        return const Right(true);
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
  Future<Either<Failure, List<Miembro>>> searchMiembros(String query, {String grado = 'todos'}) async {
    if (await networkInfo.isConnected) {
      try {
        final miembros = await remoteDataSource.searchMiembros(query, grado: grado);
        return Right(miembros);
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
}