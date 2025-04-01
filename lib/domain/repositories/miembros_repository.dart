// lib/domain/repositories/miembros_repository.dart

import 'package:dartz/dartz.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/domain/entities/miembro.dart';

abstract class MiembrosRepository {
  /// Obtiene todos los miembros
  Future<Either<Failure, List<Miembro>>> getMiembros();
  
  /// Obtiene los miembros filtrados por grado
  Future<Either<Failure, List<Miembro>>> getMiembrosByGrado(String grado);
  
  /// Obtiene un miembro por su ID
  Future<Either<Failure, Miembro>> getMiembroById(int id);
  
  /// Actualiza los datos de un miembro
  Future<Either<Failure, bool>> updateMiembro(int id, Map<String, dynamic> data);
  
  /// Crea un nuevo miembro
  Future<Either<Failure, bool>> createMiembro(Map<String, dynamic> data);
  
  /// Busca miembros por texto de búsqueda y opcionalmente por grado
  Future<Either<Failure, List<Miembro>>> searchMiembros(String query, {String grado = 'todos'});
}