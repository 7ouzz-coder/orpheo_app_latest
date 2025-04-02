// lib/presentation/bloc/miembros/miembros_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/domain/repositories/miembros_repository.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_event.dart';
import 'package:orpheo_app/presentation/bloc/miembros/miembros_state.dart';

class MiembrosBloc extends Bloc<MiembrosEvent, MiembrosState> {
  final MiembrosRepository miembrosRepository;
  
  MiembrosBloc({required this.miembrosRepository}) : super(MiembrosInitial()) {
    on<LoadMiembros>(_onLoadMiembros);
    on<SearchMiembros>(_onSearchMiembros);
    on<FilterMiembrosByGrado>(_onFilterMiembrosByGrado);
    on<GetMiembroDetails>(_onGetMiembroDetails);
    on<UpdateMiembro>(_onUpdateMiembro);
    on<AddMiembro>(_onAddMiembro);
  }
  
  Future<void> _onLoadMiembros(LoadMiembros event, Emitter<MiembrosState> emit) async {
    emit(MiembrosLoading());
    
    try {
      final result = event.grado == 'todos'
          ? await miembrosRepository.getMiembros()
          : await miembrosRepository.getMiembrosByGrado(event.grado);
      
      result.fold(
        (failure) => emit(MiembrosError(message: _mapFailureToMessage(failure))),
        (miembros) => emit(MiembrosLoaded(
          miembros: miembros,
          filtroGrado: event.grado,
          searchQuery: '',
        )),
      );
    } catch (e) {
      emit(MiembrosError(message: 'Error al cargar miembros: ${e.toString()}'));
    }
  }
  
  Future<void> _onSearchMiembros(SearchMiembros event, Emitter<MiembrosState> emit) async {
    // Solo emitir estado de carga si no estamos en un estado cargado
    // para evitar parpadeos al buscar en una lista ya cargada
    if (state is! MiembrosLoaded) {
      emit(MiembrosLoading());
    }
    
    try {
      final result = await miembrosRepository.searchMiembros(
        event.query,
        grado: event.grado,
      );
      
      result.fold(
        (failure) => emit(MiembrosError(message: _mapFailureToMessage(failure))),
        (miembros) => emit(MiembrosLoaded(
          miembros: miembros,
          filtroGrado: event.grado,
          searchQuery: event.query,
        )),
      );
    } catch (e) {
      emit(MiembrosError(message: 'Error en la búsqueda: ${e.toString()}'));
    }
  }
  
  Future<void> _onFilterMiembrosByGrado(FilterMiembrosByGrado event, Emitter<MiembrosState> emit) async {
    // Si ya tenemos un estado cargado y una consulta de búsqueda, aplicamos tanto
    // el filtro de grado como la búsqueda
    if (state is MiembrosLoaded) {
      final currentState = state as MiembrosLoaded;
      if (currentState.searchQuery.isNotEmpty) {
        add(SearchMiembros(
          query: currentState.searchQuery,
          grado: event.grado,
        ));
        return;
      }
    }
    
    // Si no hay búsqueda activa, solo cargamos por grado
    add(LoadMiembros(grado: event.grado));
  }
  
  Future<void> _onGetMiembroDetails(GetMiembroDetails event, Emitter<MiembrosState> emit) async {
    emit(MiembrosLoading());
    
    try {
      final result = await miembrosRepository.getMiembroById(event.miembroId);
      
      result.fold(
        (failure) => emit(MiembrosError(message: _mapFailureToMessage(failure))),
        (miembro) => emit(MiembroDetailsLoaded(miembro: miembro)),
      );
    } catch (e) {
      emit(MiembrosError(message: 'Error al cargar detalles del miembro: ${e.toString()}'));
    }
  }
  
  Future<void> _onUpdateMiembro(UpdateMiembro event, Emitter<MiembrosState> emit) async {
    emit(MiembrosLoading());
    
    try {
      final result = await miembrosRepository.updateMiembro(event.miembroId, event.data);
      
      result.fold(
        (failure) => emit(MiembrosError(message: _mapFailureToMessage(failure))),
        (success) {
          emit(const MiembroUpdated(message: 'Miembro actualizado correctamente'));
          
          // Después de actualizar, recargamos la lista
          if (state is MiembrosLoaded) {
            final prevState = state as MiembrosLoaded;
            add(LoadMiembros(grado: prevState.filtroGrado));
          } else {
            add(const LoadMiembros());
          }
        },
      );
    } catch (e) {
      emit(MiembrosError(message: 'Error al actualizar miembro: ${e.toString()}'));
    }
  }
  
  Future<void> _onAddMiembro(AddMiembro event, Emitter<MiembrosState> emit) async {
    emit(MiembrosLoading());
    
    try {
      final result = await miembrosRepository.createMiembro(event.data);
      
      result.fold(
        (failure) => emit(MiembrosError(message: _mapFailureToMessage(failure))),
        (success) {
          emit(const MiembroAdded(message: 'Miembro agregado correctamente'));
          
          // Después de agregar, recargamos la lista
          if (state is MiembrosLoaded) {
            final prevState = state as MiembrosLoaded;
            add(LoadMiembros(grado: prevState.filtroGrado));
          } else {
            add(const LoadMiembros());
          }
        },
      );
    } catch (e) {
      emit(MiembrosError(message: 'Error al agregar miembro: ${e.toString()}'));
    }
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'No hay conexión a internet';
      case NotFoundFailure:
        return 'Miembro no encontrado';
      case ValidationFailure:
        return failure.message;
      case AuthFailure:
        return 'Error de autenticación: ${failure.message}';
      default:
        return 'Error inesperado';
    }
  }
}