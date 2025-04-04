// lib/data/models/programas/asistencia_model.dart

import 'package:orpheo_app/domain/entities/asistencia.dart';

class AsistenciaModel extends Asistencia {
  const AsistenciaModel({
    required int id,
    required int programaId,
    required int miembroId,
    required bool asistio,
    String? justificacion,
    int? registradoPorId,
    String? registradoPorNombre,
    required DateTime horaRegistro,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Datos adicionales para UI
    String? nombreMiembro,
    String? gradoMiembro,
  }) : super(
    id: id,
    programaId: programaId,
    miembroId: miembroId,
    asistio: asistio,
    justificacion: justificacion,
    registradoPorId: registradoPorId,
    registradoPorNombre: registradoPorNombre,
    horaRegistro: horaRegistro,
    createdAt: createdAt,
    updatedAt: updatedAt,
    nombreMiembro: nombreMiembro,
    gradoMiembro: gradoMiembro,
  );
  
  factory AsistenciaModel.fromJson(Map<String, dynamic> json) {
    return AsistenciaModel(
      id: json['id'],
      programaId: json['programaId'],
      miembroId: json['miembroId'],
      asistio: json['asistio'],
      justificacion: json['justificacion'],
      registradoPorId: json['registradoPorId'],
      registradoPorNombre: json['registradoPorNombre'],
      horaRegistro: DateTime.parse(json['horaRegistro']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      nombreMiembro: json['nombreMiembro'],
      gradoMiembro: json['gradoMiembro'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'programaId': programaId,
      'miembroId': miembroId,
      'asistio': asistio,
      'justificacion': justificacion,
      'registradoPorId': registradoPorId,
      'horaRegistro': horaRegistro.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Convertir una lista de JSON a una lista de modelos
  static List<AsistenciaModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AsistenciaModel.fromJson(json)).toList();
  }
}