// lib/domain/repositories/documentos_repository.dart

import 'package:dartz/dartz.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/domain/entities/documento.dart';

abstract class DocumentosRepository {
  /// Obtiene todos los documentos
  Future<Either<Failure, List<Documento>>> getDocumentos();
  
  /// Obtiene los documentos filtrados por categoría
  Future<Either<Failure, List<Documento>>> getDocumentosByCategoria(String categoria);
  
  /// Obtiene un documento por su ID
  Future<Either<Failure, Documento>> getDocumentoById(int id);
  
  /// Busca documentos por texto de búsqueda y opcionalmente por categoría
  Future<Either<Failure, List<Documento>>> searchDocumentos(String query, {String categoria = 'todos'});
  
  /// Descarga un documento y lo guarda localmente
  Future<Either<Failure, String>> downloadDocumento(int id);
  
  /// Sube un nuevo documento
  Future<Either<Failure, Documento>> uploadDocumento(Map<String, dynamic> data, String filePath);
  
  /// Elimina un documento
  Future<Either<Failure, bool>> deleteDocumento(int id);
}