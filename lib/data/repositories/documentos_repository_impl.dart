// lib/data/repositories/documentos_repository_impl.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:orpheo_app/core/errors/exceptions.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/data/datasources/local/secure_storage_helper.dart';
import 'package:orpheo_app/data/datasources/remote/documentos_remote_datasource.dart';
import 'package:orpheo_app/domain/entities/documento.dart';
import 'package:orpheo_app/domain/repositories/documentos_repository.dart';

class DocumentosRepositoryImpl implements DocumentosRepository {
  final DocumentosRemoteDataSource remoteDataSource;
  final SecureStorageHelper secureStorage;
  
  DocumentosRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });
  
  @override
  Future<Either<Failure, List<Documento>>> getDocumentos() async {
    try {
      final documentos = await remoteDataSource.getDocumentos();
      return Right(documentos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Documento>>> getDocumentosByCategoria(String categoria) async {
    try {
      final documentos = await remoteDataSource.getDocumentosByCategoria(categoria);
      return Right(documentos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Documento>> getDocumentoById(int id) async {
    try {
      final documento = await remoteDataSource.getDocumentoById(id);
      return Right(documento);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Documento>>> searchDocumentos(String query, {String categoria = 'todos'}) async {
    try {
      final documentos = await remoteDataSource.searchDocumentos(query, categoria: categoria);
      return Right(documentos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, String>> downloadDocumento(int id) async {
    try {
      final localPath = await remoteDataSource.downloadDocumento(id);
      return Right(localPath);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Documento>> uploadDocumento(Map<String, dynamic> data, String filePath) async {
    try {
      final documento = await remoteDataSource.uploadDocumento(data, filePath);
      return Right(documento);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deleteDocumento(int id) async {
    try {
      await remoteDataSource.deleteDocumento(id);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No hay conexión a internet'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}