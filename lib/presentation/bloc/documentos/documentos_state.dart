// lib/presentation/bloc/documentos/documentos_state.dart

import 'package:equatable/equatable.dart';
import 'package:orpheo_app/domain/entities/documento.dart';

abstract class DocumentosState extends Equatable {
  const DocumentosState();
  
  @override
  List<Object?> get props => [];
}

// Estado inicial cuando se carga el módulo de documentos
class DocumentosInitial extends DocumentosState {}

// Estado de carga mientras se obtienen documentos
class DocumentosLoading extends DocumentosState {}

// Estado cuando se han cargado los documentos exitosamente
class DocumentosLoaded extends DocumentosState {
  final List<Documento> documentos;
  final String filtroCategoria;
  final String searchQuery;
  
  const DocumentosLoaded({
    required this.documentos,
    this.filtroCategoria = 'todos',
    this.searchQuery = '',
  });
  
  @override
  List<Object?> get props => [documentos, filtroCategoria, searchQuery];
  
  DocumentosLoaded copyWith({
    List<Documento>? documentos,
    String? filtroCategoria,
    String? searchQuery,
  }) {
    return DocumentosLoaded(
      documentos: documentos ?? this.documentos,
      filtroCategoria: filtroCategoria ?? this.filtroCategoria,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Estado cuando se han cargado los detalles de un documento específico
class DocumentoDetailsLoaded extends DocumentosState {
  final Documento documento;
  
  const DocumentoDetailsLoaded({required this.documento});
  
  @override
  List<Object?> get props => [documento];
}

// Estado de error al obtener documentos
class DocumentosError extends DocumentosState {
  final String message;
  
  const DocumentosError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// Estado cuando se ha iniciado una descarga
class DocumentoDownloading extends DocumentosState {
  final int documentoId;
  final double progress;
  
  const DocumentoDownloading({
    required this.documentoId,
    this.progress = 0.0,
  });
  
  @override
  List<Object?> get props => [documentoId, progress];
}

// Estado cuando se ha completado una descarga
class DocumentoDownloaded extends DocumentosState {
  final int documentoId;
  final String localPath;
  final String message;
  
  const DocumentoDownloaded({
    required this.documentoId,
    required this.localPath,
    this.message = 'Documento descargado correctamente',
  });
  
  @override
  List<Object?> get props => [documentoId, localPath, message];
}

// Estado cuando se está subiendo un documento
class DocumentoUploading extends DocumentosState {
  final double progress;
  
  const DocumentoUploading({this.progress = 0.0});
  
  @override
  List<Object?> get props => [progress];
}

// Estado cuando se ha subido un documento correctamente
class DocumentoUploaded extends DocumentosState {
  final Documento documento;
  final String message;
  
  const DocumentoUploaded({
    required this.documento,
    this.message = 'Documento subido correctamente',
  });
  
  @override
  List<Object?> get props => [documento, message];
}

// Estado cuando se ha eliminado un documento correctamente
class DocumentoDeleted extends DocumentosState {
  final int documentoId;
  final String message;
  
  const DocumentoDeleted({
    required this.documentoId,
    this.message = 'Documento eliminado correctamente',
  });
  
  @override
  List<Object?> get props => [documentoId, message];
}