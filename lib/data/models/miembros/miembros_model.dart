// lib/data/models/miembros/miembro_model.dart

import 'package:orpheo_app/domain/entities/miembro.dart';

class MiembroModel extends Miembro {
  const MiembroModel({
    required super.id,
    required super.nombres,
    required super.apellidos,
    required super.rut,
    required super.grado,
    super.cargo,
    super.vigente = true,
    super.email,
    super.telefono,
    super.direccion,
    super.profesion,
    super.ocupacion,
    super.trabajoNombre,
    super.trabajoDireccion,
    super.trabajoTelefono,
    super.trabajoEmail,
    super.parejaNombre,
    super.parejaTelefono,
    super.contactoEmergenciaNombre,
    super.contactoEmergenciaTelefono,
    super.fechaNacimiento,
    super.fechaIniciacion,
    super.fechaAumentoSalario,
    super.fechaExaltacion,
    super.situacionSalud,
  });
  
  factory MiembroModel.fromJson(Map<String, dynamic> json) {
    return MiembroModel(
      id: json['id'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      rut: json['rut'],
      grado: json['grado'],
      cargo: json['cargo'],
      vigente: json['vigente'] ?? true,
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      profesion: json['profesion'],
      ocupacion: json['ocupacion'],
      trabajoNombre: json['trabajoNombre'],
      trabajoDireccion: json['trabajoDireccion'],
      trabajoTelefono: json['trabajoTelefono'],
      trabajoEmail: json['trabajoEmail'],
      parejaNombre: json['parejaNombre'],
      parejaTelefono: json['parejaTelefono'],
      contactoEmergenciaNombre: json['contactoEmergenciaNombre'],
      contactoEmergenciaTelefono: json['contactoEmergenciaTelefono'],
      fechaNacimiento: json['fechaNacimiento'] != null 
          ? DateTime.parse(json['fechaNacimiento']) 
          : null,
      fechaIniciacion: json['fechaIniciacion'] != null 
          ? DateTime.parse(json['fechaIniciacion']) 
          : null,
      fechaAumentoSalario: json['fechaAumentoSalario'] != null 
          ? DateTime.parse(json['fechaAumentoSalario']) 
          : null,
      fechaExaltacion: json['fechaExaltacion'] != null 
          ? DateTime.parse(json['fechaExaltacion']) 
          : null,
      situacionSalud: json['situacionSalud'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'rut': rut,
      'grado': grado,
      'cargo': cargo,
      'vigente': vigente,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'profesion': profesion,
      'ocupacion': ocupacion,
      'trabajoNombre': trabajoNombre,
      'trabajoDireccion': trabajoDireccion,
      'trabajoTelefono': trabajoTelefono,
      'trabajoEmail': trabajoEmail,
      'parejaNombre': parejaNombre,
      'parejaTelefono': parejaTelefono,
      'contactoEmergenciaNombre': contactoEmergenciaNombre,
      'contactoEmergenciaTelefono': contactoEmergenciaTelefono,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'fechaIniciacion': fechaIniciacion?.toIso8601String(),
      'fechaAumentoSalario': fechaAumentoSalario?.toIso8601String(),
      'fechaExaltacion': fechaExaltacion?.toIso8601String(),
      'situacionSalud': situacionSalud,
    };
  }
  
  // Convertir una lista de JSON a una lista de modelos
  static List<MiembroModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MiembroModel.fromJson(json)).toList();
  }
}