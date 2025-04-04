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
      beforeOpen: (details) async {
        if (details.wasCreated) {
          // Puedes inicializar datos si es necesario cuando la BD se crea por primera vez
        }
      },
    );
  }
  
  // --------------------------
  // Operaciones de Miembros
  // --------------------------
  
  // Obtener todos los miembros
  Future<List<MiembroData>> getAllMiembros() => 
      select(miembrosTable).get();
  
  // Obtener miembros por grado
  Future<List<MiembroData>> getMiembrosByGrado(String grado) =>
      (select(miembrosTable)..where((m) => m.grado.equals(grado))).get();
  
  // Obtener un miembro por ID
  Future<MiembroData?> getMiembroById(int id) =>
      (select(miembrosTable)..where((m) => m.id.equals(id))).getSingleOrNull();
  
  // Buscar miembros
  Future<List<MiembroData>> searchMiembros(String query, {String? grado}) {
    final queryLower = '%${query.toLowerCase()}%';
    
    final q = select(miembrosTable);
    q.where((m) {
      final nombreLike = m.nombres.lower.like(queryLower) | 
                        m.apellidos.lower.like(queryLower);
      if (grado != null && grado != 'todos') {
        return nombreLike & m.grado.equals(grado);
      }
      return nombreLike;
    });
    
    return q.get();
  }
  
  // Insertar un nuevo miembro (devuelve el ID)
  Future<int> insertMiembro(MiembrosTableCompanion miembro) {
    return into(miembrosTable).insert(miembro);
  }
  
  // Actualizar un miembro existente
  Future<bool> updateMiembro(MiembrosTableCompanion miembro) {
    return update(miembrosTable).replace(miembro);
  }
  
  // Guardar un miembro (insertar o actualizar)
  Future<int> saveMiembro(MiembrosTableCompanion miembro) {
    return into(miembrosTable).insertOnConflictUpdate(miembro);
  }
  
  // Guardar múltiples miembros (batch)
  Future<void> saveMiembros(List<MiembrosTableCompanion> miembros) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(miembrosTable, miembros);
    });
  }
  
  // Eliminar un miembro
  Future<int> deleteMiembro(int id) =>
      (delete(miembrosTable)..where((m) => m.id.equals(id))).go();
  
  // --------------------------
  // Operaciones de Documentos
  // --------------------------
  
  // Obtener todos los documentos
  Future<List<DocumentoData>> getAllDocumentos() => 
      select(documentosTable).get();
  
  // Obtener documentos por categoría
  Future<List<DocumentoData>> getDocumentosByCategoria(String categoria) =>
      (select(documentosTable)..where((d) => d.categoria.equals(categoria))).get();
  
  // Obtener documentos por tipo (plancha o no)
  Future<List<DocumentoData>> getDocumentosByTipo(bool esPlancha) =>
      (select(documentosTable)..where((d) => d.esPlancha.equals(esPlancha))).get();
  
  // Obtener un documento por ID
  Future<DocumentoData?> getDocumentoById(int id) =>
      (select(documentosTable)..where((d) => d.id.equals(id))).getSingleOrNull();
  
  // Buscar documentos
  Future<List<DocumentoData>> searchDocumentos(String query, {String? categoria}) {
    final queryLower = '%${query.toLowerCase()}%';
    
    final q = select(documentosTable);
    q.where((d) {
      final nombreLike = d.nombre.lower.like(queryLower) | 
                        (d.descripcion.isNotNull() & d.descripcion.lower.like(queryLower));
      if (categoria != null && categoria != 'todos') {
        return nombreLike & d.categoria.equals(categoria);
      }
      return nombreLike;
    });
    
    return q.get();
  }
  
  // Insertar un nuevo documento
  Future<int> insertDocumento(DocumentosTableCompanion documento) {
    return into(documentosTable).insert(documento);
  }
  
  // Actualizar un documento existente
  Future<bool> updateDocumento(DocumentosTableCompanion documento) {
    return update(documentosTable).replace(documento);
  }
  
  // Guardar un documento (insertar o actualizar)
  Future<int> saveDocumento(DocumentosTableCompanion documento) {
    return into(documentosTable).insertOnConflictUpdate(documento);
  }
  
  // Guardar múltiples documentos (batch)
  Future<void> saveDocumentos(List<DocumentosTableCompanion> documentos) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(documentosTable, documentos);
    });
  }
  
  // Eliminar un documento
  Future<int> deleteDocumento(int id) =>
      (delete(documentosTable)..where((d) => d.id.equals(id))).go();
  
  // Marcar documentos como sincronizados
  Future<int> markDocumentosSynced(List<int> ids) {
    return (update(documentosTable)
      ..where((d) => d.id.isIn(ids)))
      .write(const DocumentosTableCompanion(
        syncedWithServer: Value(true)
      ));
  }
  
  // --------------------------
  // Operaciones de Programas
  // --------------------------
  
  // Obtener todos los programas
  Future<List<ProgramaData>> getAllProgramas() => 
      select(programasTable).get();
  
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
  
  // Insertar un nuevo programa
  Future<int> insertPrograma(ProgramasTableCompanion programa) {
    return into(programasTable).insert(programa);
  }
  
  // Actualizar un programa existente
  Future<bool> updatePrograma(ProgramasTableCompanion programa) {
    return update(programasTable).replace(programa);
  }
  
  // Guardar un programa (insertar o actualizar)
  Future<int> savePrograma(ProgramasTableCompanion programa) {
    return into(programasTable).insertOnConflictUpdate(programa);
  }
  
  // Guardar múltiples programas (batch)
  Future<void> saveProgramas(List<ProgramasTableCompanion> programas) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(programasTable, programas);
    });
  }
  
  // Eliminar un programa
  Future<int> deletePrograma(int id) =>
      (delete(programasTable)..where((p) => p.id.equals(id))).go();
  
  // --------------------------
  // Operaciones de Asistencias
  // --------------------------
  
  // Obtener asistencias por programa
  Future<List<AsistenciaData>> getAsistenciasByPrograma(int programaId) =>
      (select(asistenciasTable)..where((a) => a.programaId.equals(programaId))).get();
  
  // Obtener asistencias por miembro
  Future<List<AsistenciaData>> getAsistenciasByMiembro(int miembroId) =>
      (select(asistenciasTable)..where((a) => a.miembroId.equals(miembroId))).get();
  
  // Obtener una asistencia específica
  Future<AsistenciaData?> getAsistencia(int programaId, int miembroId) =>
      (select(asistenciasTable)
        ..where((a) => a.programaId.equals(programaId) & a.miembroId.equals(miembroId)))
        .getSingleOrNull();
  
  // Insertar una nueva asistencia
  Future<int> insertAsistencia(AsistenciasTableCompanion asistencia) {
    return into(asistenciasTable).insert(asistencia);
  }
  
  // Actualizar una asistencia existente
  Future<bool> updateAsistencia(AsistenciasTableCompanion asistencia) {
    return update(asistenciasTable).replace(asistencia);
  }
  
  // Guardar una asistencia (insertar o actualizar)
  Future<int> saveAsistencia(AsistenciasTableCompanion asistencia) {
    return into(asistenciasTable).insertOnConflictUpdate(asistencia);
  }
  
  // Guardar múltiples asistencias (batch)
  Future<void> saveAsistencias(List<AsistenciasTableCompanion> asistencias) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(asistenciasTable, asistencias);
    });
  }
  
  // Eliminar una asistencia
  Future<int> deleteAsistencia(int id) =>
      (delete(asistenciasTable)..where((a) => a.id.equals(id))).go();
  
  // Eliminar asistencias por programa
  Future<int> deleteAsistenciasByPrograma(int programaId) =>
      (delete(asistenciasTable)..where((a) => a.programaId.equals(programaId))).go();
  
  // --------------------------
  // Operaciones de sincronización
  // --------------------------
  
  // Obtener todos los elementos no sincronizados de cada tabla
  Future<Map<String, dynamic>> getUnsyncedData() async {
    final miembros = await (select(miembrosTable)
      ..where((m) => m.syncedWithServer.equals(false)))
      .get();
    
    final documentos = await (select(documentosTable)
      ..where((d) => d.syncedWithServer.equals(false)))
      .get();
    
    final programas = await (select(programasTable)
      ..where((p) => p.syncedWithServer.equals(false)))
      .get();
    
    final asistencias = await (select(asistenciasTable)
      ..where((a) => a.syncedWithServer.equals(false)))
      .get();
    
    return {
      'miembros': miembros,
      'documentos': documentos,
      'programas': programas,
      'asistencias': asistencias,
    };
  }
  
  // Marcar todos los elementos como sincronizados
  Future<void> markAllSynced() async {
    await (update(miembrosTable)).write(const MiembrosTableCompanion(syncedWithServer: Value(true)));
    await (update(documentosTable)).write(const DocumentosTableCompanion(syncedWithServer: Value(true)));
    await (update(programasTable)).write(const ProgramasTableCompanion(syncedWithServer: Value(true)));
    await (update(asistenciasTable)).write(const AsistenciasTableCompanion(syncedWithServer: Value(true)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Obtener el directorio de la aplicación
    final dbFolder = await getApplicationDocumentsDirectory();
    // Crear la ruta del archivo de la base de datos
    final file = File(p.join(dbFolder.path, 'orpheo_app.sqlite'));
    
    // Configurar la base de datos con opciones de rendimiento y registro
    return NativeDatabase.createInBackground(
      file,
      logStatements: false, // Cambiar a true para depuración
    );
  });
}