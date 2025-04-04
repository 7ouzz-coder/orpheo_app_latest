// lib/data/datasources/local/tables/programas_table.dart

import 'package:drift/drift.dart';

@DataClassName('ProgramaData')
class ProgramasTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tema => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get encargado => text()();
  TextColumn get quienImparte => text().nullable()();
  TextColumn get resumen => text().nullable()();
  
  // Clasificación
  TextColumn get grado => text()();
  TextColumn get tipo => text()();
  TextColumn get estado => text()();
  
  // Items relacionados
  TextColumn get documentosJson => text().nullable()();
  
  // Responsable
  IntColumn get responsableId => integer().nullable()();
  TextColumn get responsableNombre => text().nullable()();
  
  // Ubicación
  TextColumn get ubicacion => text().nullable()();
  
  // Info adicional
  TextColumn get detallesAdicionales => text().nullable()();
  
  // Metadatos
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sincronización
  BoolColumn get syncedWithServer => boolean().withDefault(const Constant(false))();
  BoolColumn get localOnly => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column<Object>>? get primaryKey => {id};
}