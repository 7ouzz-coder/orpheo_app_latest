// lib/presentation/bloc/documentos/documentos_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orpheo_app/core/errors/failures.dart';
import 'package:orpheo_app/domain/repositories/documentos_repository.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_event.dart';
import 'package:orpheo_app/presentation/bloc/documentos/documentos_state.dart';

class DocumentosBloc extends Bloc<DocumentosEvent, DocumentosState> {
  final DocumentosRepository documentosRepository;
  
  DocumentosBloc({required this.documentosRepository}) : super(DocumentosInitial()) {
    on<LoadDocumentos>(_onLoadDocumentos);
    on<SearchDocumentos>(_onSearchDocumentos);
    on<FilterDocumentosByCategoria>(_onFilterDocumentosByCategoria);
    on<GetDocumentoDetails>(_onGetDocumentoDetails);
    on<DownloadDocumento>(_onDownloadDocumento);
    on<UploadDocumento>(_onUploadDocumento);
    on<DeleteDocumento>(_onDeleteDocumento);
  }
  
  Future<void> _onLoadDocumentos(LoadDocumentos event, Emitter<DocumentosState> emit) async {
    emit(DocumentosLoading());
    
    try {
      final result = event.categoria == 'todos'
          ? await documentosRepository.getDocumentos()
          : await documentosRepository.getDocumentosByCategoria(event.categoria);
      
      result.fold(
        (failure) => emit(DocumentosError(message: _mapFailureToMessage(failure))),
        (documentos) => emit(DocumentosLoaded(
          documentos: documentos,
          filtroCategoria: event.categoria,
          searchQuery: '',
        )),
      );
    } catch (e) {
      emit(DocumentosError(message: 'Error al cargar documentos: ${e.toString()}'));
    }
  }
  
  Future<void> _onSearchDocumentos(SearchDocumentos event, Emitter<DocumentosState> emit) async {
    // Solo emitir estado de carga si no estamos en un estado cargado
    // para evitar parpadeos al buscar en una lista ya cargada
    if (state is! DocumentosLoaded) {
      emit(DocumentosLoading());
    }
    
    try {
      final result = await documentosRepository.searchDocumentos(
        event.query,
        categoria: event.categoria,
      );
      
      result.fold(
        (failure) => emit(DocumentosError(message: _mapFailureToMessage(failure))),
        (documentos) => emit(DocumentosLoaded(
          documentos: documentos,
          filtroCategoria: event.categoria,
          searchQuery: event.query,
        )),
      );
    } catch (e) {
      emit(DocumentosError(message: 'Error en la búsqueda: ${e.toString()}'));
    }
  }
  
  Future<void> _onFilterDocumentosByCategoria(FilterDocumentosByCategoria event, Emitter<DocumentosState> emit) async {
    // Si ya tenemos un estado cargado y una consulta de búsqueda, aplicamos tanto
    // el filtro de categoría como la búsqueda
    if (state is DocumentosLoaded) {
      final currentState = state as DocumentosLoaded;
      if (currentState.searchQuery.isNotEmpty) {
        add(SearchDocumentos(
          query: currentState.searchQuery,
          categoria: event.categoria,
        ));
        return;
      }
    }
    
    // Si no hay búsqueda activa, solo cargamos por categoría
    add(LoadDocumentos(categoria: event.categoria));
  }
  
  Future<void> _onGetDocumentoDetails(GetDocumentoDetails event, Emitter<DocumentosState> emit) async {
    emit(DocumentosLoading());
    
    try {
      final result = await documentosRepository.getDocumentoById(event.documentoId);
      
      result.fold(
        (failure) => emit(DocumentosError(message: _mapFailureToMessage(failure))),
        (documento) => emit(DocumentoDetailsLoaded(documento: documento)),
      );
    } catch (e) {
      emit(DocumentosError(message: 'Error al cargar detalles del documento: ${e.toString()}'));
    }
  }
  
  Future<void> _onDownloadDocumento(DownloadDocumento event, Emitter<DocumentosState> emit) async {
    emit(DocumentoDownloading(documentoId: event.documentoId));
    
    try {
      final result = await documentosRepository.downloadDocumento(event.documentoId);
      
      result.fold(
        (failure) => emit(DocumentosError(message: _mapFailureToMessage(failure))),
        (localPath) => emit(DocumentoDownloaded(
          documentoId: event.documentoId,
          localPath: localPath,
        )),
      );
    } catch (e) {
      emit(DocumentosError(message: 'Error al descargar documento: ${e.toString()}'));
    }
  }
  
  Future<void> _onUploadDocumento(UploadDocumento event, Emitter<DocumentosState> emit) async {
    emit(const DocumentoUploading());
    
    try {
      final result = await documentosRepository.uploadDocumento(
        event.documentoData,
        event.filePath,
      );
      
      result.fold(
        (failure) => emit(DocumentosError(message: _mapFailureToMessage(failure))),
        (documento) {
          emit(DocumentoUploaded(documento: documento));
          
          // Después de subir, recargamos la lista de documentos
          if (state is DocumentosLoaded) {
            final prevState = state as DocumentosLoaded;
            add(LoadDocumentos(categoria: prevState.filtroCategoria));
          } else {
            add(const LoadDocumentos());
          }
        },
      );
    } catch (e) {
      emit(DocumentosError(message: 'Error al subir documento: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeleteDocumento(DeleteDocumento event, Emitter<DocumentosState> emit) async {
    emit(DocumentosLoading());
    
    try {
      final result = await documentosRepository.deleteDocumento(event.documentoId);
      
      result.fold(
        (failure) => emit(DocumentosError(message: _mapFailureToMessage(failure))),
        (success) {
          emit(DocumentoDeleted(documentoId: event.documentoId));
          
          // Después de eliminar, recargamos la lista
          if (state is DocumentosLoaded) {
            final prevState = state as DocumentosLoaded;
            add(LoadDocumentos(categoria: prevState.filtroCategoria));
          } else {
            add(const LoadDocumentos());
          }
        },
      );
    } catch (e) {
      emit(DocumentosError(message: 'Error al eliminar documento: ${e.toString()}'));
    }
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'No hay conexión a internet';
      case NotFoundFailure:
        return 'Documento no encontrado';
      case ValidationFailure:
        return failure.message;
      case AuthFailure:
        return 'Error de autenticación: ${failure.message}';
      default:
        return 'Error inesperado';
    }
  }
}