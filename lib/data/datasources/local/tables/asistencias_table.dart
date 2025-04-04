// lib/data/datasources/local/tables/asistencias_table.dart

import 'package:drift/drift.dart';

@DataClassName('AsistenciaData')
class AsistenciasTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programaId => integer()();
  IntColumn get miembroId => integer()();
  BoolColumn get asistio => boolean()();
  TextColumn get justificacion => text().nullable()();
  
  // Registro
  IntColumn get registradoPorId => integer().nullable()();
  TextColumn get registradoPorNombre => text().nullable()();
  DateTimeColumn get horaRegistro => dateTime()();
  
  // Metadatos
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Datos adicionales para UI (opcional)
  TextColumn get nombreMiembro => text().nullable()();
  TextColumn get gradoMiembro => text().nullable()();
  
  // Sincronización
  BoolColumn get syncedWithServer => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column<Object>>? get primaryKey => {id};
  
  @override
  List<String> get customConstraints => [
    'UNIQUE (programa_id, miembro_id)',
  ];
}