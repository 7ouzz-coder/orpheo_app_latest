// lib/data/datasources/local/tables/miembros_table.dart

import 'package:drift/drift.dart';

@DataClassName('MiembroData')
class MiembrosTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombres => text()();
  TextColumn get apellidos => text()();
  TextColumn get rut => text()();
  TextColumn get grado => text()();
  TextColumn get cargo => text().nullable()();
  BoolColumn get vigente => boolean().withDefault(const Constant(true))();
  
  // Información de contacto
  TextColumn get email => text().nullable()();
  TextColumn get telefono => text().nullable()();
  TextColumn get direccion => text().nullable()();
  
  // Información profesional
  TextColumn get profesion => text().nullable()();
  TextColumn get ocupacion => text().nullable()();
  TextColumn get trabajoNombre => text().nullable()();
  TextColumn get trabajoDireccion => text().nullable()();
  TextColumn get trabajoTelefono => text().nullable()();
  TextColumn get trabajoEmail => text().nullable()();
  
  // Información familiar
  TextColumn get parejaNombre => text().nullable()();
  TextColumn get parejaTelefono => text().nullable()();
  TextColumn get contactoEmergenciaNombre => text().nullable()();
  TextColumn get contactoEmergenciaTelefono => text().nullable()();
  
  // Fechas importantes
  DateTimeColumn get fechaNacimiento => dateTime().nullable()();
  DateTimeColumn get fechaIniciacion => dateTime().nullable()();
  DateTimeColumn get fechaAumentoSalario => dateTime().nullable()();
  DateTimeColumn get fechaExaltacion => dateTime().nullable()();
  
  // Salud
  TextColumn get situacionSalud => text().nullable()();
  
  // Metadatos
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get syncedWithServer => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column<Object>>? get primaryKey => {id};
  
  @override
  List<String> get customConstraints => [
    'UNIQUE (rut)',
  ];
}