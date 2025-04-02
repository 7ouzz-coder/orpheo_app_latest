// lib/domain/entities/documento.dart

import 'package:equatable/equatable.dart';

class Documento extends Equatable {
  final int id;
  final String nombre;
  final String tipo;
  final String? descripcion;
  final String? tamano;
  final String? url;
  final String? localPath;
  
  // Clasificación
  final String categoria; // "aprendiz", "companero", "maestro", "general", etc.
  final String? subcategoria;
  final String? palabrasClave;
  
  // Si es plancha
  final bool esPlancha;
  final String? planchaId;
  final String? planchaEstado; // "pendiente", "aprobada", "rechazada"
  
  // Autor y subido por
  final int? autorId;
  final String? autorNombre;
  final int subidoPorId;
  final String? subidoPorNombre;
  
  // Fechas
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Documento({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.descripcion,
    this.tamano,
    this.url,
    this.localPath,
    required this.categoria,
    this.subcategoria,
    this.palabrasClave,
    this.esPlancha = false,
    this.planchaId,
    this.planchaEstado,
    this.autorId,
    this.autorNombre,
    required this.subidoPorId,
    this.subidoPorNombre,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    nombre,
    tipo,
    categoria,
    esPlancha,
    subidoPorId,
    createdAt,
  ];
  
  // Método para crear una copia del objeto con algunos campos modificados
  Documento copyWith({
    int? id,
    String? nombre,
    String? tipo,
    String? descripcion,
    String? tamano,
    String? url,
    String? localPath,
    String? categoria,
    String? subcategoria,
    String? palabrasClave,
    bool? esPlancha,
    String? planchaId,
    String? planchaEstado,
    int? autorId,
    String? autorNombre,
    int? subidoPorId,
    String? subidoPorNombre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Documento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      tamano: tamano ?? this.tamano,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      palabrasClave: palabrasClave ?? this.palabrasClave,
      esPlancha: esPlancha ?? this.esPlancha,
      planchaId: planchaId ?? this.planchaId,
      planchaEstado: planchaEstado ?? this.planchaEstado,
      autorId: autorId ?? this.autorId,
      autorNombre: autorNombre ?? this.autorNombre,
      subidoPorId: subidoPorId ?? this.subidoPorId,
      subidoPorNombre: subidoPorNombre ?? this.subidoPorNombre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}