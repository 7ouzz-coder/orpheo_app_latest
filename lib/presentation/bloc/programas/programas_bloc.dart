// lib/presentation/bloc/programas/programas_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/domain/repositories/programas_repository.dart';
import 'package:orpheo_app/presentation/bloc/programas/programas_event.dart';
import 'package:orpheo_app/presentation/bloc/programas/programas_state.dart';

class ProgramasBloc extends Bloc<ProgramasEvent, ProgramasState> {
  final ProgramasRepository programasRepository;
  
  ProgramasBloc({required this.programasRepository}) : super(ProgramasInitial()) {
    on<LoadProgramas>(_onLoadProgramas);
    on<LoadProximosProgramas>(_onLoadProximosProgramas);
    on<LoadProgramasPasados>(_onLoadProgramasPasados);
    on<FilterProgramasByGrado>(_onFilterProgramasByGrado);
    on<FilterProgramasByEstado>(_onFilterProgramasByEstado);
    on<GetProgramaDetails>(_onGetProgramaDetails);
    on<CreatePrograma>(_onCreatePrograma);
    on<UpdatePrograma>(_onUpdatePrograma);
    on<DeletePrograma>(_onDeletePrograma);
    on<LoadAsistencia>(_onLoadAsistencia);
    on<RegisterAsistencia>(_onRegisterAsistencia);
    on<UpdateAsistencia>(_onUpdateAsistencia);
  }
  
  Future<void> _onLoadProgramas(LoadProgramas event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.getProgramas();
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (programas) => emit(ProgramasLoaded(programas: programas)),
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al cargar programas: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoadProximosProgramas(LoadProximosProgramas event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.getProximosProgramas();
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (programas) => emit(ProgramasLoaded(
          programas: programas,
          soloProximos: true,
        )),
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al cargar programas próximos: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoadProgramasPasados(LoadProgramasPasados event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.getProgramasPasados();
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (programas) => emit(ProgramasLoaded(
          programas: programas,
          soloProximos: false,
        )),
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al cargar programas pasados: ${e.toString()}'));
    }
  }
  
  Future<void> _onFilterProgramasByGrado(FilterProgramasByGrado event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.getProgramasByGrado(event.grado);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (programas) => emit(ProgramasLoaded(
          programas: programas,
          filtroGrado: event.grado,
        )),
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al filtrar programas: ${e.toString()}'));
    }
  }
  
  Future<void> _onFilterProgramasByEstado(FilterProgramasByEstado event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.getProgramasByEstado(event.estado);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (programas) => emit(ProgramasLoaded(
          programas: programas,
          filtroEstado: event.estado,
        )),
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al filtrar programas: ${e.toString()}'));
    }
  }
  
  Future<void> _onGetProgramaDetails(GetProgramaDetails event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.getProgramaById(event.programaId);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (programa) => emit(ProgramaDetailsLoaded(programa: programa)),
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al cargar detalles del programa: ${e.toString()}'));
    }
  }
  
  Future<void> _onCreatePrograma(CreatePrograma event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.createPrograma(event.data);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (programa) {
          emit(ProgramaCreated(programa: programa));
          
          // Después de crear un programa, recargar la lista de programas
          if (state is ProgramasLoaded) {
            final currentState = state as ProgramasLoaded;
            if (currentState.soloProximos) {
              add(const LoadProximosProgramas());
            } else {
              add(const LoadProgramas());
            }
          } else {
            add(const LoadProgramas());
          }
        },
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al crear programa: ${e.toString()}'));
    }
  }
  
  Future<void> _onUpdatePrograma(UpdatePrograma event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.updatePrograma(event.programaId, event.data);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (programa) {
          emit(ProgramaUpdated(programa: programa));
          
          // Después de actualizar un programa, recargar la lista o los detalles según corresponda
          if (state is ProgramaDetailsLoaded) {
            add(GetProgramaDetails(programaId: event.programaId));
          } else if (state is ProgramasLoaded) {
            final currentState = state as ProgramasLoaded;
            if (currentState.soloProximos) {
              add(const LoadProximosProgramas());
            } else {
              add(const LoadProgramas());
            }
          } else {
            add(const LoadProgramas());
          }
        },
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al actualizar programa: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeletePrograma(DeletePrograma event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.deletePrograma(event.programaId);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (_) {
          emit(ProgramaDeleted(programaId: event.programaId));
          
          // Después de eliminar un programa, recargar la lista
          if (state is ProgramasLoaded) {
            final currentState = state as ProgramasLoaded;
            if (currentState.soloProximos) {
              add(const LoadProximosProgramas());
            } else {
              add(const LoadProgramas());
            }
          } else {
            add(const LoadProgramas());
          }
        },
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al eliminar programa: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoadAsistencia(LoadAsistencia event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.getAsistenciaByPrograma(event.programaId);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (asistencia) => emit(AsistenciaLoaded(
          asistencia: asistencia,
          programaId: event.programaId,
        )),
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al cargar asistencia: ${e.toString()}'));
    }
  }
  
  Future<void> _onRegisterAsistencia(RegisterAsistencia event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.registrarAsistencia(event.data);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (asistencia) {
          emit(AsistenciaRegistered(asistencia: asistencia));
          
          // Después de registrar asistencia, recargar la lista de asistencia
          if (state is AsistenciaLoaded) {
            final currentState = state as AsistenciaLoaded;
            add(LoadAsistencia(programaId: currentState.programaId));
          }
        },
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al registrar asistencia: ${e.toString()}'));
    }
  }
  
  Future<void> _onUpdateAsistencia(UpdateAsistencia event, Emitter<ProgramasState> emit) async {
    emit(ProgramasLoading());
    
    try {
      final result = await programasRepository.updateAsistencia(event.asistenciaId, event.data);
      
      result.fold(
        (failure) => emit(ProgramasError(message: _mapFailureToMessage(failure))),
        (asistencia) {
          emit(AsistenciaUpdated(asistencia: asistencia));
          
          // Después de actualizar asistencia, recargar la lista de asistencia
          if (state is AsistenciaLoaded) {
            final currentState = state as AsistenciaLoaded;
            add(LoadAsistencia(programaId: currentState.programaId));
          }
        },
      );
    } catch (e) {
      emit(ProgramasError(message: 'Error al actualizar asistencia: ${e.toString()}'));
    }
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'No hay conexión a internet';
      case NotFoundFailure:
        return 'Programa no encontrado';
      case ValidationFailure:
        return failure.message;
      case AuthFailure:
        return 'Error de autenticación: ${failure.message}';
      default:
        return 'Error inesperado';
    }
  }
}