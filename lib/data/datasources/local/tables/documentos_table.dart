// lib/data/datasources/local/tables/documentos_table.dart

import 'package:drift/drift.dart';

@DataClassName('DocumentoData')
class DocumentosTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
  TextColumn get tipo => text()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get tamano => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get localPath => text().nullable()();
  
  // Clasificación
  TextColumn get categoria => text()();
  TextColumn get subcategoria => text().nullable()();
  TextColumn get palabrasClave => text().nullable()();
  
  // Si es plancha
  BoolColumn get esPlancha => boolean().withDefault(const Constant(false))();
  TextColumn get planchaId => text().nullable()();
  TextColumn get planchaEstado => text().nullable()();
  
  // Autor y subido por
  IntColumn get autorId => integer().nullable()();
  TextColumn get autorNombre => text().nullable()();
  IntColumn get subidoPorId => integer()();
  TextColumn get subidoPorNombre => text().nullable()();
  
  // Fechas
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Metadatos para sincronización
  BoolColumn get syncedWithServer => boolean().withDefault(const Constant(false))();
  BoolColumn get localOnly => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column<Object>>? get primaryKey => {id};
}