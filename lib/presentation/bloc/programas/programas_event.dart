// lib/presentation/bloc/programas/programas_event.dart

import 'package:equatable/equatable.dart';

abstract class ProgramasEvent extends Equatable {
  const ProgramasEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar todos los programas
class LoadProgramas extends ProgramasEvent {
  const LoadProgramas();
}

/// Evento para cargar programas próximos
class LoadProximosProgramas extends ProgramasEvent {
  const LoadProximosProgramas();
}

/// Evento para cargar programas pasados
class LoadProgramasPasados extends ProgramasEvent {
  const LoadProgramasPasados();
}

/// Evento para filtrar programas por grado
class FilterProgramasByGrado extends ProgramasEvent {
  final String grado;
  
  const FilterProgramasByGrado({required this.grado});
  
  @override
  List<Object?> get props => [grado];
}

/// Evento para filtrar programas por estado
class FilterProgramasByEstado extends ProgramasEvent {
  final String estado;
  
  const FilterProgramasByEstado({required this.estado});
  
  @override
  List<Object?> get props => [estado];
}

/// Evento para obtener los detalles de un programa
class GetProgramaDetails extends ProgramasEvent {
  final int programaId;
  
  const GetProgramaDetails({required this.programaId});
  
  @override
  List<Object?> get props => [programaId];
}

/// Evento para crear un nuevo programa
class CreatePrograma extends ProgramasEvent {
  final Map<String, dynamic> data;
  
  const CreatePrograma({required this.data});
  
  @override
  List<Object?> get props => [data];
}

/// Evento para actualizar un programa
class UpdatePrograma extends ProgramasEvent {
  final int programaId;
  final Map<String, dynamic> data;
  
  const UpdatePrograma({
    required this.programaId,
    required this.data,
  });
  
  @override
  List<Object?> get props => [programaId, data];
}

/// Evento para eliminar un programa
class DeletePrograma extends ProgramasEvent {
  final int programaId;
  
  const DeletePrograma({required this.programaId});
  
  @override
  List<Object?> get props => [programaId];
}

/// Evento para cargar la lista de asistencia de un programa
class LoadAsistencia extends ProgramasEvent {
  final int programaId;
  
  const LoadAsistencia({required this.programaId});
  
  @override
  List<Object?> get props => [programaId];
}

/// Evento para registrar asistencia
class RegisterAsistencia extends ProgramasEvent {
  final Map<String, dynamic> data;
  
  const RegisterAsistencia({required this.data});
  
  @override
  List<Object?> get props => [data];
}

/// Evento para actualizar un registro de asistencia
class UpdateAsistencia extends ProgramasEvent {
  final int asistenciaId;
  final Map<String, dynamic> data;
  
  const UpdateAsistencia({
    required this.asistenciaId,
    required this.data,
  });
  
  @override
  List<Object?> get props => [asistenciaId, data];
}