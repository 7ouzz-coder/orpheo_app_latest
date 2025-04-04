// lib/data/models/programas/programa_model.dart

import 'package:orpheo_app/domain/entities/programa.dart';

class ProgramaModel extends Programa {
  const ProgramaModel({
    required int id,
    required String tema,
    required DateTime fecha,
    required String encargado,
    String? quienImparte,
    String? resumen,
    required String grado,
    required String tipo,
    required String estado,
    String? documentosJson,
    int? responsableId,
    String? responsableNombre,
    String? ubicacion,
    String? detallesAdicionales,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
    id: id,
    tema: tema,
    fecha: fecha,
    encargado: encargado,
    quienImparte: quienImparte,
    resumen: resumen,
    grado: grado,
    tipo: tipo,
    estado: estado,
    documentosJson: documentosJson,
    responsableId: responsableId,
    responsableNombre: responsableNombre,
    ubicacion: ubicacion,
    detallesAdicionales: detallesAdicionales,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory ProgramaModel.fromJson(Map<String, dynamic> json) {
    return ProgramaModel(
      id: json['id'],
      tema: json['tema'],
      fecha: DateTime.parse(json['fecha']),
      encargado: json['encargado'],
      quienImparte: json['quienImparte'],
      resumen: json['resumen'],
      grado: json['grado'],
      tipo: json['tipo'],
      estado: json['estado'],
      documentosJson: json['documentosJson'],
      responsableId: json['responsableId'],
      responsableNombre: json['responsableNombre'],
      ubicacion: json['ubicacion'],
      detallesAdicionales: json['detallesAdicionales'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tema': tema,
      'fecha': fecha.toIso8601String(),
      'encargado': encargado,
      'quienImparte': quienImparte,
      'resumen': resumen,
      'grado': grado,
      'tipo': tipo,
      'estado': estado,
      'documentosJson': documentosJson,
      'responsableId': responsableId,
      'responsableNombre': responsableNombre,
      'ubicacion': ubicacion,
      'detallesAdicionales': detallesAdicionales,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Convertir una lista de JSON a una lista de modelos
  static List<ProgramaModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProgramaModel.fromJson(json)).toList();
  }
}