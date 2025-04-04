// lib/domain/repositories/programas_repository.dart

import 'package:dartz/dartz.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/domain/entities/programa.dart';
import 'package:orpheo_app/domain/entities/asistencia.dart';

abstract class ProgramasRepository {
  /// Obtiene todos los programas
  Future<Either<Failure, List<Programa>>> getProgramas();
  
  /// Obtiene los programas filtrados por grado
  Future<Either<Failure, List<Programa>>> getProgramasByGrado(String grado);
  
  /// Obtiene los programas filtrados por estado
  Future<Either<Failure, List<Programa>>> getProgramasByEstado(String estado);
  
  /// Obtiene los programas próximos (futuros)
  Future<Either<Failure, List<Programa>>> getProximosProgramas();
  
  /// Obtiene los programas pasados (históricos)
  Future<Either<Failure, List<Programa>>> getProgramasPasados();
  
  /// Obtiene un programa por su ID
  Future<Either<Failure, Programa>> getProgramaById(int id);
  
  /// Crea un nuevo programa
  Future<Either<Failure, Programa>> createPrograma(Map<String, dynamic> data);
  
  /// Actualiza un programa existente
  Future<Either<Failure, Programa>> updatePrograma(int id, Map<String, dynamic> data);
  
  /// Elimina un programa
  Future<Either<Failure, bool>> deletePrograma(int id);
  
  /// Obtiene la lista de asistencia para un programa
  Future<Either<Failure, List<Asistencia>>> getAsistenciaByPrograma(int programaId);
  
  /// Registra asistencia para un miembro en un programa
  Future<Either<Failure, Asistencia>> registrarAsistencia(Map<String, dynamic> data);
  
  /// Actualiza un registro de asistencia
  Future<Either<Failure, Asistencia>> updateAsistencia(int id, Map<String, dynamic> data);
}