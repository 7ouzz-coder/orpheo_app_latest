// lib/data/models/miembros/miembro_model.dart

import 'package:orpheo_app/domain/entities/miembro.dart';

class MiembroModel extends Miembro {
  const MiembroModel({
    required int id,
    required String nombres,
    required String apellidos,
    required String rut,
    required String grado,
    String? cargo,
    bool vigente = true,
    String? email,
    String? telefono,
    String? direccion,
    String? profesion,
    String? ocupacion,
    String? trabajoNombre,
    String? trabajoDireccion,
    String? trabajoTelefono,
    String? trabajoEmail,
    String? parejaNombre,
    String? parejaTelefono,
    String? contactoEmergenciaNombre,
    String? contactoEmergenciaTelefono,
    DateTime? fechaNacimiento,
    DateTime? fechaIniciacion,
    DateTime? fechaAumentoSalario,
    DateTime? fechaExaltacion,
    String? situacionSalud,
  }) : super(
    id: id,
    nombres: nombres,
    apellidos: apellidos,
    rut: rut,
    grado: grado,
    cargo: cargo,
    vigente: vigente,
    email: email,
    telefono: telefono,
    direccion: direccion,
    profesion: profesion,
    ocupacion: ocupacion,
    trabajoNombre: trabajoNombre,
    trabajoDireccion: trabajoDireccion,
    trabajoTelefono: trabajoTelefono,
    trabajoEmail: trabajoEmail,
    parejaNombre: parejaNombre,
    parejaTelefono: parejaTelefono,
    contactoEmergenciaNombre: contactoEmergenciaNombre,
    contactoEmergenciaTelefono: contactoEmergenciaTelefono,
    fechaNacimiento: fechaNacimiento,
    fechaIniciacion: fechaIniciacion,
    fechaAumentoSalario: fechaAumentoSalario,
    fechaExaltacion: fechaExaltacion,
    situacionSalud: situacionSalud,
  );
  
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