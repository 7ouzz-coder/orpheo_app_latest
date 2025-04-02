// lib/data/models/documentos/documento_model.dart

import 'package:orpheo_app/domain/entities/documento.dart';

class DocumentoModel extends Documento {
  const DocumentoModel({
    required int id,
    required String nombre,
    required String tipo,
    String? descripcion,
    String? tamano,
    String? url,
    String? localPath,
    required String categoria,
    String? subcategoria,
    String? palabrasClave,
    bool esPlancha = false,
    String? planchaId,
    String? planchaEstado,
    int? autorId,
    String? autorNombre,
    required int subidoPorId,
    String? subidoPorNombre,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
    id: id,
    nombre: nombre,
    tipo: tipo,
    descripcion: descripcion,
    tamano: tamano,
    url: url,
    localPath: localPath,
    categoria: categoria,
    subcategoria: subcategoria,
    palabrasClave: palabrasClave,
    esPlancha: esPlancha,
    planchaId: planchaId,
    planchaEstado: planchaEstado,
    autorId: autorId,
    autorNombre: autorNombre,
    subidoPorId: subidoPorId,
    subidoPorNombre: subidoPorNombre,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory DocumentoModel.fromJson(Map<String, dynamic> json) {
    return DocumentoModel(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      tamano: json['tamano'],
      url: json['url'],
      localPath: json['localPath'],
      categoria: json['categoria'],
      subcategoria: json['subcategoria'],
      palabrasClave: json['palabrasClave'],
      esPlancha: json['esPlancha'] ?? false,
      planchaId: json['planchaId'],
      planchaEstado: json['planchaEstado'],
      autorId: json['autorId'],
      autorNombre: json['autorNombre'],
      subidoPorId: json['subidoPorId'],
      subidoPorNombre: json['subidoPorNombre'],
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
      'nombre': nombre,
      'tipo': tipo,
      'descripcion': descripcion,
      'tamano': tamano,
      'url': url,
      'localPath': localPath,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'palabrasClave': palabrasClave,
      'esPlancha': esPlancha,
      'planchaId': planchaId,
      'planchaEstado': planchaEstado,
      'autorId': autorId,
      'autorNombre': autorNombre,
      'subidoPorId': subidoPorId,
      'subidoPorNombre': subidoPorNombre,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Convertir una lista de JSON a una lista de modelos
  static List<DocumentoModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DocumentoModel.fromJson(json)).toList();
  }
}