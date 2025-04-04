// lib/domain/entities/programa.dart

import 'package:equatable/equatable.dart';

class Programa extends Equatable {
  final int id;
  final String tema;
  final DateTime fecha;
  final String encargado;
  final String? quienImparte;
  final String? resumen;
  
  // Clasificación
  final String grado; // "aprendiz", "companero", "maestro", "general"
  final String tipo; // "camara", "trabajo", "instruccion", etc.
  final String estado; // "Pendiente", "Programado", "Completado", "Cancelado"
  
  // Items relacionados
  final String? documentosJson; // JSON string de documentos asociados
  
  // Responsable
  final int? responsableId;
  final String? responsableNombre;
  
  // Ubicación
  final String? ubicacion;
  
  // Info adicional
  final String? detallesAdicionales;
  
  // Metadatos
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Programa({
    required this.id,
    required this.tema,
    required this.fecha,
    required this.encargado,
    this.quienImparte,
    this.resumen,
    required this.grado,
    required this.tipo,
    required this.estado,
    this.documentosJson,
    this.responsableId,
    this.responsableNombre,
    this.ubicacion,
    this.detallesAdicionales,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    tema,
    fecha,
    encargado,
    grado,
    tipo,
    estado,
  ];
  
  // Método para crear una copia del objeto con algunos campos modificados
  Programa copyWith({
    int? id,
    String? tema,
    DateTime? fecha,
    String? encargado,
    String? quienImparte,
    String? resumen,
    String? grado,
    String? tipo,
    String? estado,
    String? documentosJson,
    int? responsableId,
    String? responsableNombre,
    String? ubicacion,
    String? detallesAdicionales,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Programa(
      id: id ?? this.id,
      tema: tema ?? this.tema,
      fecha: fecha ?? this.fecha,
      encargado: encargado ?? this.encargado,
      quienImparte: quienImparte ?? this.quienImparte,
      resumen: resumen ?? this.resumen,
      grado: grado ?? this.grado,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      documentosJson: documentosJson ?? this.documentosJson,
      responsableId: responsableId ?? this.responsableId,
      responsableNombre: responsableNombre ?? this.responsableNombre,
      ubicacion: ubicacion ?? this.ubicacion,
      detallesAdicionales: detallesAdicionales ?? this.detallesAdicionales,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}