// lib/presentation/bloc/documentos/documentos_event.dart

import 'package:equatable/equatable.dart';

abstract class DocumentosEvent extends Equatable {
  const DocumentosEvent();

  @override
  List<Object?> get props => [];
}

// Evento para cargar todos los documentos
class LoadDocumentos extends DocumentosEvent {
  final String categoria;
  
  const LoadDocumentos({this.categoria = 'todos'});
  
  @override
  List<Object?> get props => [categoria];
}

// Evento para buscar documentos
class SearchDocumentos extends DocumentosEvent {
  final String query;
  final String categoria;
  
  const SearchDocumentos({
    required this.query,
    this.categoria = 'todos',
  });
  
  @override
  List<Object?> get props => [query, categoria];
}

// Evento para filtrar documentos por categoría
class FilterDocumentosByCategoria extends DocumentosEvent {
  final String categoria;
  
  const FilterDocumentosByCategoria({required this.categoria});
  
  @override
  List<Object?> get props => [categoria];
}

// Evento para obtener detalles de un documento específico
class GetDocumentoDetails extends DocumentosEvent {
  final int documentoId;
  
  const GetDocumentoDetails({required this.documentoId});
  
  @override
  List<Object?> get props => [documentoId];
}

// Evento para descargar un documento
class DownloadDocumento extends DocumentosEvent {
  final int documentoId;
  
  const DownloadDocumento({required this.documentoId});
  
  @override
  List<Object?> get props => [documentoId];
}

// Evento para subir un nuevo documento
class UploadDocumento extends DocumentosEvent {
  final Map<String, dynamic> documentoData;
  final String filePath;
  
  const UploadDocumento({
    required this.documentoData,
    required this.filePath,
  });
  
  @override
  List<Object?> get props => [documentoData, filePath];
}

// Evento para eliminar un documento
class DeleteDocumento extends DocumentosEvent {
  final int documentoId;
  
  const DeleteDocumento({required this.documentoId});
  
  @override
  List<Object?> get props => [documentoId];
}