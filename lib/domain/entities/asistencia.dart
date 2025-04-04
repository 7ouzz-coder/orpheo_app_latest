// lib/domain/entities/asistencia.dart

import 'package:equatable/equatable.dart';

class Asistencia extends Equatable {
  final int id;
  final int programaId;
  final int miembroId;
  final bool asistio;
  final String? justificacion;
  
  // Registro
  final int? registradoPorId;
  final String? registradoPorNombre;
  final DateTime horaRegistro;
  
  // Metadatos
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Datos adicionales para UI (opcional)
  final String? nombreMiembro;
  final String? gradoMiembro;
  
  const Asistencia({
    required this.id,
    required this.programaId,
    required this.miembroId,
    required this.asistio,
    this.justificacion,
    this.registradoPorId,
    this.registradoPorNombre,
    required this.horaRegistro,
    required this.createdAt,
    required this.updatedAt,
    this.nombreMiembro,
    this.gradoMiembro,
  });
  
  @override
  List<Object?> get props => [
    id,
    programaId,
    miembroId,
    asistio,
    horaRegistro,
  ];
  
  // Método para crear una copia del objeto con algunos campos modificados
  Asistencia copyWith({
    int? id,
    int? programaId,
    int? miembroId,
    bool? asistio,
    String? justificacion,
    int? registradoPorId,
    String? registradoPorNombre,
    DateTime? horaRegistro,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombreMiembro,
    String? gradoMiembro,
  }) {
    return Asistencia(
      id: id ?? this.id,
      programaId: programaId ?? this.programaId,
      miembroId: miembroId ?? this.miembroId,
      asistio: asistio ?? this.asistio,
      justificacion: justificacion ?? this.justificacion,
      registradoPorId: registradoPorId ?? this.registradoPorId,
      registradoPorNombre: registradoPorNombre ?? this.registradoPorNombre,
      horaRegistro: horaRegistro ?? this.horaRegistro,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombreMiembro: nombreMiembro ?? this.nombreMiembro,
      gradoMiembro: gradoMiembro ?? this.gradoMiembro,
    );
  }
}