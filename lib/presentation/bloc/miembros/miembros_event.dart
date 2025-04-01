// lib/presentation/bloc/miembros/miembros_event.dart

import 'package:equatable/equatable.dart';

abstract class MiembrosEvent extends Equatable {
  const MiembrosEvent();

  @override
  List<Object?> get props => [];
}

// Evento para cargar todos los miembros
class LoadMiembros extends MiembrosEvent {
  final String grado;
  
  const LoadMiembros({this.grado = 'todos'});
  
  @override
  List<Object?> get props => [grado];
}

// Evento para buscar miembros
class SearchMiembros extends MiembrosEvent {
  final String query;
  final String grado;
  
  const SearchMiembros({
    required this.query,
    this.grado = 'todos',
  });
  
  @override
  List<Object?> get props => [query, grado];
}

// Evento para filtrar miembros
class FilterMiembrosByGrado extends MiembrosEvent {
  final String grado;
  
  const FilterMiembrosByGrado({required this.grado});
  
  @override
  List<Object?> get props => [grado];
}

// Evento para actualizar un miembro (por ejemplo, cambiar grado)
class UpdateMiembro extends MiembrosEvent {
  final int miembroId;
  final Map<String, dynamic> data;
  
  const UpdateMiembro({
    required this.miembroId,
    required this.data,
  });
  
  @override
  List<Object?> get props => [miembroId, data];
}

// Evento para agregar un nuevo miembro
class AddMiembro extends MiembrosEvent {
  final Map<String, dynamic> data;
  
  const AddMiembro({required this.data});
  
  @override
  List<Object?> get props => [data];
}

// Evento para obtener detalles de un miembro específico
class GetMiembroDetails extends MiembrosEvent {
  final int miembroId;
  
  const GetMiembroDetails({required this.miembroId});
  
  @override
  List<Object?> get props => [miembroId];
}