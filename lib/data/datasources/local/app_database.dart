// lib/data/datasources/local/app_database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Importar tablas
import 'package:orpheo_app/data/datasources/local/tables/miembros_table.dart';
import 'package:orpheo_app/data/datasources/local/tables/documentos_table.dart';
import 'package:orpheo_app/data/datasources/local/tables/programas_table.dart';
import 'package:orpheo_app/data/datasources/local/tables/asistencias_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    MiembrosTable, 
    DocumentosTable, 
    ProgramasTable, 
    AsistenciasTable
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Aquí se añadirían los cambios de esquema en actualizaciones futuras
      },
      // Borrar todo antes de recrear las tablas para debug (solo en desarrollo)
      // beforeOpen: (details) async {
      //   if (details.wasCreated) {
      //     // Inicializar datos si es necesario
      //   }
      // },
    );
  }
  
  //
  // Operaciones de Miembros
  //
  
  // Obtener todos los miembros
  Future<List<MiembroData>> getAllMiembros() => select(miembrosTable).get();
  
  // Obtener miembros por grado
  Future<List<MiembroData>> getMiembrosByGrado(String grado) =>
      (select(miembrosTable)..where((m) => m.grado.equals(grado))).get();
  
  // Obtener un miembro por ID
  Future<MiembroData?> getMiembroById(int id) =>
      (select(miembrosTable)..where((m) => m.id.equals(id))).getSingleOrNull();
  
  // Buscar miembros
  Future<List<MiembroData>> searchMiembros(String query, {String? grado}) {
    final queryLower = '%${query.toLowerCase()}%';
    
    final q = select(miembrosTable)
      ..where((m) {
        final nombreLike = m.nombres.lower.like(queryLower) | m.apellidos.lower.like(queryLower);
        if (grado != null && grado != 'todos') {
          return nombreLike & m.grado.equals(grado);
        }
        return nombreLike;
      });
    
    return q.get();
  }
  
  // Guardar un miembro (insertar o actualizar)
  Future<int> saveMiembro(MiembrosTableCompanion entry) {
    return into(miembrosTable).insertOnConflictUpdate(entry);
  }
  
  // Guardar múltiples miembros (batch)
  Future<void> saveMiembros(List<MiembrosTableCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(miembrosTable, entries);
    });
  }
  
  // Eliminar un miembro
  Future<int> deleteMiembro(int id) =>
      (delete(miembrosTable)..where((m) => m.id.equals(id))).go();
  
  //
  // Operaciones de Documentos
  //
  
  // Obtener todos los documentos
  Future<List<DocumentoData>> getAllDocumentos() => select(documentosTable).get();
  
  // Obtener documentos por categoría
  Future<List<DocumentoData>> getDocumentosByCategoria(String categoria) =>
      (select(documentosTable)..where((d) => d.categoria.equals(categoria))).get();
  
  // Obtener un documento por ID
  Future<DocumentoData?> getDocumentoById(int id) =>
      (select(documentosTable)..where((d) => d.id.equals(id))).getSingleOrNull();
  
  // Buscar documentos
  Future<List<DocumentoData>> searchDocumentos(String query, {String? categoria}) {
    final queryLower = '%${query.toLowerCase()}%';
    
    final q = select(documentosTable)
      ..where((d) {
        final nombreLike = d.nombre.lower.like(queryLower) | 
                          d.descripcion.lower.like(queryLower);
        if (categoria != null && categoria != 'todos') {
          return nombreLike & d.categoria.equals(categoria);
        }
        return nombreLike;
      });
    
    return q.get();
  }
  
  // Guardar un documento (insertar o actualizar)
  Future<int> saveDocumento(DocumentosTableCompanion entry) {
    return into(documentosTable).insertOnConflictUpdate(entry);
  }
  
  // Guardar múltiples documentos (batch)
  Future<void> saveDocumentos(List<DocumentosTableCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(documentosTable, entries);
    });
  }
  
  // Eliminar un documento
  Future<int> deleteDocumento(int id) =>
      (delete(documentosTable)..where((d) => d.id.equals(id))).go();
  
  //
  // Operaciones de Programas
  //
  
  // Obtener todos los programas
  Future<List<ProgramaData>> getAllProgramas() => select(programasTable).get();
  
  // Obtener programas por grado
  Future<List<ProgramaData>> getProgramasByGrado(String grado) =>
      (select(programasTable)..where((p) => p.grado.equals(grado))).get();
  
  // Obtener programas por estado
  Future<List<ProgramaData>> getProgramasByEstado(String estado) =>
      (select(programasTable)..where((p) => p.estado.equals(estado))).get();
  
  // Obtener programas próximos (futuros)
  Future<List<ProgramaData>> getProximosProgramas() {
    final now = DateTime.now();
    return (select(programasTable)
      ..where((p) => p.fecha.isBiggerThanValue(now))
      ..orderBy([(p) => OrderingTerm.asc(p.fecha)])).get();
  }
  
  // Obtener programas pasados
  Future<List<ProgramaData>> getProgramasPasados() {
    final now = DateTime.now();
    return (select(programasTable)
      ..where((p) => p.fecha.isSmallerThanValue(now))
      ..orderBy([(p) => OrderingTerm.desc(p.fecha)])).get();
  }
  
  // Obtener un programa por ID
  Future<ProgramaData?> getProgramaById(int id) =>
      (select(programasTable)..where((p) => p.id.equals(id))).getSingleOrNull();
  
  // Guardar un programa (insertar o actualizar)
  Future<int> savePrograma(ProgramasTableCompanion entry) {
    return into(programasTable).insertOnConflictUpdate(entry);
  }
  
  // Guardar múltiples programas (batch)
  Future<void> saveProgramas(List<ProgramasTableCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(programasTable, entries);
    });
  }
  
  // Eliminar un programa
  Future<int> deletePrograma(int id) =>
      (delete(programasTable)..where((p) => p.id.equals(id))).go();
  
  //
  // Operaciones de Asistencias
  //
  
  // Obtener asistencias por programa
  Future<List<AsistenciaData>> getAsistenciasByPrograma(int programaId) =>
      (select(asistenciasTable)..where((a) => a.programaId.equals(programaId))).get();
  
  // Guardar una asistencia (insertar o actualizar)
  Future<int> saveAsistencia(AsistenciasTableCompanion entry) {
    return into(asistenciasTable).insertOnConflictUpdate(entry);
  }
  
  // Guardar múltiples asistencias (batch)
  Future<void> saveAsistencias(List<AsistenciasTableCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(asistenciasTable, entries);
    });
  }
  
  // Eliminar asistencias de un programa
  Future<int> deleteAsistenciasByPrograma(int programaId) =>
      (delete(asistenciasTable)..where((a) => a.programaId.equals(programaId))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'orpheo_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}