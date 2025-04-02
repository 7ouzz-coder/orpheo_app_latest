// lib/domain/entities/miembro.dart

import 'package:equatable/equatable.dart';

class Miembro extends Equatable {
  final int id;
  final String nombres;
  final String apellidos;
  final String rut;
  final String grado;
  final String? cargo;
  final bool vigente;
  
  // Información de contacto
  final String? email;
  final String? telefono;
  final String? direccion;
  
  // Información profesional
  final String? profesion;
  final String? ocupacion;
  final String? trabajoNombre;
  final String? trabajoDireccion;
  final String? trabajoTelefono;
  final String? trabajoEmail;
  
  // Información familiar
  final String? parejaNombre;
  final String? parejaTelefono;
  final String? contactoEmergenciaNombre;
  final String? contactoEmergenciaTelefono;
  
  // Fechas importantes
  final DateTime? fechaNacimiento;
  final DateTime? fechaIniciacion;
  final DateTime? fechaAumentoSalario;
  final DateTime? fechaExaltacion;
  
  // Salud
  final String? situacionSalud;
  
  // Para mostrar en la UI
  String get nombreCompleto => '$nombres $apellidos';
  
  const Miembro({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.rut,
    required this.grado,
    this.cargo,
    this.vigente = true,
    this.email,
    this.telefono,
    this.direccion,
    this.profesion,
    this.ocupacion,
    this.trabajoNombre,
    this.trabajoDireccion,
    this.trabajoTelefono,
    this.trabajoEmail,
    this.parejaNombre,
    this.parejaTelefono,
    this.contactoEmergenciaNombre,
    this.contactoEmergenciaTelefono,
    this.fechaNacimiento,
    this.fechaIniciacion,
    this.fechaAumentoSalario,
    this.fechaExaltacion,
    this.situacionSalud,
  });
  
  @override
  List<Object?> get props => [
    id, 
    nombres, 
    apellidos,
    rut,
    grado,
    cargo,
    vigente,
    email,
    telefono,
  ];
  
  // Método para crear una copia del objeto con algunos campos modificados
  Miembro copyWith({
    int? id,
    String? nombres,
    String? apellidos,
    String? rut,
    String? grado,
    String? cargo,
    bool? vigente,
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
  }) {
    return Miembro(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      rut: rut ?? this.rut,
      grado: grado ?? this.grado,
      cargo: cargo ?? this.cargo,
      vigente: vigente ?? this.vigente,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      profesion: profesion ?? this.profesion,
      ocupacion: ocupacion ?? this.ocupacion,
      trabajoNombre: trabajoNombre ?? this.trabajoNombre,
      trabajoDireccion: trabajoDireccion ?? this.trabajoDireccion,
      trabajoTelefono: trabajoTelefono ?? this.trabajoTelefono,
      trabajoEmail: trabajoEmail ?? this.trabajoEmail,
      parejaNombre: parejaNombre ?? this.parejaNombre,
      parejaTelefono: parejaTelefono ?? this.parejaTelefono,
      contactoEmergenciaNombre: contactoEmergenciaNombre ?? this.contactoEmergenciaNombre,
      contactoEmergenciaTelefono: contactoEmergenciaTelefono ?? this.contactoEmergenciaTelefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      fechaIniciacion: fechaIniciacion ?? this.fechaIniciacion,
      fechaAumentoSalario: fechaAumentoSalario ?? this.fechaAumentoSalario,
      fechaExaltacion: fechaExaltacion ?? this.fechaExaltacion,
      situacionSalud: situacionSalud ?? this.situacionSalud,
    );
  }
}