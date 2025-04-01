// lib/presentation/bloc/miembros/miembros_state.dart

import 'package:equatable/equatable.dart';
import 'package:orpheo_app/domain/entities/miembro.dart';

abstract class MiembrosState extends Equatable {
  const MiembrosState();
  
  @override
  List<Object?> get props => [];
}

// Estado inicial cuando se carga el módulo de miembros
class MiembrosInitial extends MiembrosState {}

// Estado de carga mientras se obtienen miembros
class MiembrosLoading extends MiembrosState {}

// Estado cuando se han cargado los miembros exitosamente
class MiembrosLoaded extends MiembrosState {
  final List<Miembro> miembros;
  final String filtroGrado;
  final String searchQuery;
  
  const MiembrosLoaded({
    required this.miembros,
    this.filtroGrado = 'todos',
    this.searchQuery = '',
  });
  
  @override
  List<Object?> get props => [miembros, filtroGrado, searchQuery];
  
  MiembrosLoaded copyWith({
    List<Miembro>? miembros,
    String? filtroGrado,
    String? searchQuery,
  }) {
    return MiembrosLoaded(
      miembros: miembros ?? this.miembros,
      filtroGrado: filtroGrado ?? this.filtroGrado,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Estado cuando se han cargado los detalles de un miembro específico
class MiembroDetailsLoaded extends MiembrosState {
  final Miembro miembro;
  
  const MiembroDetailsLoaded({required this.miembro});
  
  @override
  List<Object?> get props => [miembro];
}

// Estado de error al obtener miembros
class MiembrosError extends MiembrosState {
  final String message;
  
  const MiembrosError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Estado cuando se ha actualizado un miembro exitosamente
class MiembroUpdated extends MiembrosState {
  final String message;
  
  const MiembroUpdated({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Estado cuando se ha agregado un miembro exitosamente
class MiembroAdded extends MiembrosState {
  final String message;
  
  const MiembroAdded({required this.message});
  
  @override
  List<Object?> get props => [message];
}