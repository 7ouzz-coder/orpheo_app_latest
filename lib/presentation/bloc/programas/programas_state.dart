// lib/presentation/bloc/programas/programas_state.dart

import 'package:equatable/equatable.dart';
import 'package:orpheo_app/domain/entities/asistencia.dart';
import 'package:orpheo_app/domain/entities/programa.dart';

abstract class ProgramasState extends Equatable {
  const ProgramasState();
  
  @override
  List<Object?> get props => [];
}

/// Estado inicial cuando se carga el módulo de programas
class ProgramasInitial extends ProgramasState {}

/// Estado de carga mientras se obtienen programas
class ProgramasLoading extends ProgramasState {}

/// Estado cuando se han cargado los programas exitosamente
class ProgramasLoaded extends ProgramasState {
  final List<Programa> programas;
  final String? filtroGrado;
  final String? filtroEstado;
  final bool soloProximos;
  
  const ProgramasLoaded({
    required this.programas,
    this.filtroGrado,
    this.filtroEstado,
    this.soloProximos = false,
  });
  
  @override
  List<Object?> get props => [programas, filtroGrado, filtroEstado, soloProximos];
  
  ProgramasLoaded copyWith({
    List<Programa>? programas,
    String? filtroGrado,
    String? filtroEstado,
    bool? soloProximos,
  }) {
    return ProgramasLoaded(
      programas: programas ?? this.programas,
      filtroGrado: filtroGrado ?? this.filtroGrado,
      filtroEstado: filtroEstado ?? this.filtroEstado,
      soloProximos: soloProximos ?? this.soloProximos,
    );
  }
}

/// Estado cuando se han cargado los detalles de un programa específico
class ProgramaDetailsLoaded extends ProgramasState {
  final Programa programa;
  
  const ProgramaDetailsLoaded({required this.programa});
  
  @override
  List<Object?> get props => [programa];
}

/// Estado cuando se ha cargado la lista de asistencia de un programa
class AsistenciaLoaded extends ProgramasState {
  final List<Asistencia> asistencia;
  final int programaId;
  
  const AsistenciaLoaded({
    required this.asistencia,
    required this.programaId,
  });
  
  @override
  List<Object?> get props => [asistencia, programaId];
}

/// Estado de error al obtener programas
class ProgramasError extends ProgramasState {
  final String message;
  
  const ProgramasError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Estado cuando se ha creado un programa exitosamente
class ProgramaCreated extends ProgramasState {
  final Programa programa;
  final String message;
  
  const ProgramaCreated({
    required this.programa,
    this.message = 'Programa creado correctamente',
  });
  
  @override
  List<Object?> get props => [programa, message];
}

/// Estado cuando se ha actualizado un programa exitosamente
class ProgramaUpdated extends ProgramasState {
  final Programa programa;
  final String message;
  
  const ProgramaUpdated({
    required this.programa,
    this.message = 'Programa actualizado correctamente',
  });
  
  @override
  List<Object?> get props => [programa, message];
}

/// Estado cuando se ha eliminado un programa exitosamente
class ProgramaDeleted extends ProgramasState {
  final int programaId;
  final String message;
  
  const ProgramaDeleted({
    required this.programaId,
    this.message = 'Programa eliminado correctamente',
  });
  
  @override
  List<Object?> get props => [programaId, message];
}

/// Estado cuando se ha registrado asistencia exitosamente
class AsistenciaRegistered extends ProgramasState {
  final Asistencia asistencia;
  final String message;
  
  const AsistenciaRegistered({
    required this.asistencia,
    this.message = 'Asistencia registrada correctamente',
  });
  
  @override
  List<Object?> get props => [asistencia, message];
}

/// Estado cuando se ha actualizado un registro de asistencia exitosamente
class AsistenciaUpdated extends ProgramasState {
  final Asistencia asistencia;
  final String message;
  
  const AsistenciaUpdated({
    required this.asistencia,
    this.message = 'Asistencia actualizada correctamente',
  });
  
  @override
  List<Object?> get props => [asistencia, message];
}