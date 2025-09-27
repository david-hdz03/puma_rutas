import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pumabus_routes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabla para las bases de salida
    await db.execute('''
    CREATE TABLE bases (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    )
    ''');

    // Tabla para las rutas
    await db.execute('''
    CREATE TABLE routes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      color INTEGER NOT NULL,
      base_id INTEGER NOT NULL,
      FOREIGN KEY (base_id) REFERENCES bases (id)
    )
    ''');

    // Nueva tabla para almacenar todas las estaciones únicas
    await db.execute('''
    CREATE TABLE stations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    )
    ''');

    // Nueva tabla de unión para la relación muchos-a-muchos entre rutas y estaciones
    await db.execute('''
    CREATE TABLE route_stations (
      route_id INTEGER NOT NULL,
      station_id INTEGER NOT NULL,
      stop_order INTEGER NOT NULL,
      FOREIGN KEY (route_id) REFERENCES routes (id),
      FOREIGN KEY (station_id) REFERENCES stations (id),
      PRIMARY KEY (route_id, stop_order)
    )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // --- INSERTAR BASES ---
    // Usamos `insert` con `conflictAlgorithm: ConflictAlgorithm.ignore` para evitar errores si la base ya existe.
    await db.insert('bases', {'name': 'Metro Universidad'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('bases', {'name': 'Estadio Olímpico'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('bases', {'name': 'Metrobús CU'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('bases', {'name': 'E.N.A.L.L.T. / Anexo de Filosofía'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('bases', {'name': 'Zona Cultural'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('bases', {'name': 'Metrobús CU-2'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('bases', {'name': 'Facultad de Filosofía'}, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Obtenemos los IDs de las bases para usarlos en las rutas
    final bases = await db.query('bases');
    final baseMap = {for (var base in bases) base['name']: base['id'] as int};

    final metroUniversidadId = baseMap['Metro Universidad']!;
    final estadioId = baseMap['Estadio Olímpico']!;
    final metrobusCUId = baseMap['Metrobús CU']!;
    final enalltId = baseMap['E.N.A.L.L.T. / Anexo de Filosofía']!;
    final metrobusCU2Id = baseMap['Metrobús CU-2']!;
    final filosofiaId = baseMap['Facultad de Filosofía']!;


    // --- INSERTAR RUTAS ---
    final routesData = [
      {'name': '1', 'color': 0xFF118642, 'base_id': metroUniversidadId, 'stops': [
        'CENDI', 'Psiquiatría y Salud Mental', 'Facultad de Química', 'ENALLT Edif. A y B', 'Facultad de Ingeniería',
        'Facultad de Arquitectura', 'Rectoría', 'Psicología', 'Facultad de Filosofía', 'Facultad de Derecho',
        'Facultad de Economía', 'Facultad de Odontología', 'Facultad de Medicina', 'Facultad de Veterinaria',
        'Instituto de Geofísica', 'Química Conjunto D y E'
      ]},
      {'name': '2', 'color': 0xFFF0FF17, 'base_id': metroUniversidadId, 'stops': [
        'Química Conjunto D y E', 'Facultad de Ciencias Alumnos', 'Facultad de Ciencias Camino Verde', 'Facultad de Contaduría y Administración',
        'Escuela de Trabajo Social', 'Base Metrobús CU', 'Metrobús CU', 'Educación a Distancia', 'DGTIC', 'Facultad de Ciencias'
      ]},
      {'name': '3', 'color': 0xFF0B552A, 'base_id': metroUniversidadId, 'stops': [
        'Química Conjunto D y E', 'Tienda UNAM 2', 'Facultad de Ciencias Políticas', 'Investigaciones Jurídicas 2', 'Biblioteca Nacional 2',
        'Zona Cultural', 'Unidad de Posgrado', 'Posgrado de Economía', 'DGIRE', 'DGAPA', 'Archivo General', 'Avenida IMAN',
        'Investigaciones Filosóficas', 'Investigaciones Filológicas', 'Coordinación de Humanidades', 'UNIVERSUM',
        'Teatro y Danza', 'MUAC', 'Biblioteca Nacional', 'Espacio Escultórico', 'Investigaciones Jurídicas', 'T.V. UNAM',
        'CUEC', 'DGSA', 'Tienda UNAM'
      ]},
      {'name': '4', 'color': 0xFF52240A, 'base_id': metroUniversidadId, 'stops': [
        'Química Conjunto D y E', 'Facultad de Ciencias Alumnos', 'Facultad de Ciencias Camino Verde', 'Facultad de Contaduría y Administración',
        'Escuela de Trabajo Social', 'Base Metrobús CU', 'Estadio de Prácticas', 'Campos de futbol I', 'Jardín Botánico',
        'Campos de futbol II', 'Metrobús CU', 'Educación a Distancia', 'D.G.T.I.C', 'Facultad de Ciencias'
      ]},
      {'name': '5', 'color': 0xFF1493C5, 'base_id': metroUniversidadId, 'stops': [
        'CENDI', 'Psiquiatría y Salud Mental', 'Medicina', 'Odontología', 'Economía', 'Av. Universidad', 'Derecho',
        'Filosofía', 'Facultad de Psicología', 'Psicología', 'Facultad de Filosofía', 'Facultad de Derecho',
        'Facultad de Economía', 'Facultad de Odontología', 'Facultad de Medicina', 'Facultad de Veterinaria',
        'Instituto de Geofísica', 'Química Conjunto D y E'
      ]},
      {'name': '6', 'color': 0xFFE5652E, 'base_id': estadioId, 'stops': [
        'Campos de futbol I', 'Pista de calentamiento I', 'Pumitas', 'Pista de calentamiento II', 'Pumitas', 'Jardín Botánico',
        'Campos de futbol II', 'Investigaciones Biomédicas', 'Metrobús CU-2', 'Metrobús CU', 'Educación a Distancia', 'DGTIC',
        'Facultad de Ciencias Profesores', 'Investigación Científica', 'Ciencias del Mar', 'Invernadero', 'Anexo de Ingeniería',
        'Camino Verde', 'Facultad de Contaduría y Administración', 'Escuela de Trabajo Social', 'Base Metrobús CU',
        'Estadio de Prácticas', 'MUCA', 'Estacionamiento 8', 'Estacionamiento 7', 'Estacionamiento 6', 'Estacionamiento 4',
        'Estacionamiento 3', 'Estacionamiento 2'
      ]},
      {'name': '7', 'color': 0xFFACA003, 'base_id': estadioId, 'stops': [
        'Facultad de Psicología', 'Facultad de Filosofía', 'Facultad de Derecho', 'Facultad de Economía', 'Facultad de Odontología',
        'Facultad de Medicina', 'Facultad de Química', 'ENALLT Edif. A y B', 'Facultad de Ingeniería', 'Facultad de Arquitectura',
        'Estacionamiento 8', 'Estacionamiento 7', 'Estacionamiento 6', 'Estacionamiento 4', 'Estacionamiento 3', 'Estacionamiento 2'
      ]},
      {'name': '8', 'color': 0xFF080050, 'base_id': estadioId, 'stops': [
        'Centro Médico', 'Alberca', 'Ingeniería', 'Frontones', 'IIMAS', 'Invernadero', 'Anexo de Ingeniería', 'Camino Verde',
        'Facultad de Contaduría y Administración', 'Escuela de Trabajo Social', 'Base Metrobús CU', 'Estadio de Prácticas',
        'MUCA', 'Estacionamiento 8', 'Estacionamiento 7', 'Estacionamiento 6', 'Estacionamiento 4', 'Estacionamiento 3', 'Estacionamiento 2'
      ]},
      {'name': '9', 'color': 0xFF991B33, 'base_id': metrobusCUId, 'stops': [
        'Estadio de Prácticas', 'MUCA', 'Rectoría', 'Psicología', 'Facultad de Filosofía', 'Facultad de Derecho',
        'Facultad de Economía', 'Facultad de Odontología', 'Facultad de Medicina', 'Invernadero', 'Anexo de Ingeniería',
        'Camino Verde', 'Facultad de Contaduría y Administración', 'Escuela de Trabajo Social'
      ]},
      {'name': '10', 'color': 0xFF5D3929, 'base_id': metrobusCU2Id, 'stops': [
        'Campos de futbol I', 'Jardín Botánico', 'Campos de futbol II', 'Investigaciones Biomédicas', 'Biblioteca Nacional 2',
        'Zona Cultural', 'Unidad de Posgrado', 'Posgrado de Economía', 'D.G.I.R.E', 'D.G.A.P.A', 'Archivo General', 'Avenida IMAN',
        'Investigaciones Filosóficas', 'Investigaciones Filológicas', 'Coordinación de Humanidades', 'UNIVERSUM',
        'Teatro y Danza', 'MUAC', 'Biblioteca Nacional', 'Espacio Escultórico', 'Investigaciones Jurídicas', 'T.V. UNAM',
        'CUEC', 'DGSA', 'Tienda UNAM 2', 'Facultad de Ciencias Políticas', 'Investigaciones Jurídicas 2'
      ]},
      {'name': '11', 'color': 0xFF5F329A, 'base_id': metrobusCUId, 'stops': [
        'Estadio de Prácticas', 'MUCA', 'Estacionamiento 8', 'Estacionamiento 7', 'Relaciones Laborales', 'Dirección General de Obras/Proveeduría',
        'AAPAUNAM', 'Posgrado de Filosofía', 'Pista de calentamiento II', 'Pumitas', 'Jardín Botánico', 'Campos de futbol II'
      ]},
      {'name': '12', 'color': 0xFF500852, 'base_id': enalltId, 'stops': [
        'Psicología', 'Facultad de Filosofía', 'Facultad de Derecho', 'Facultad de Economía', 'Facultad de Odontología',
        'Facultad de Medicina', 'Facultad de Química', 'ENALLT Edif. A y B', 'Facultad de Ingeniería', 'Facultad de Arquitectura',
        'Estacionamiento 8', 'Estacionamiento 7', 'Relaciones laborales', 'Dirección General de Obras/Proveeduría',
        'AAPAUNAM', 'Anexo de Filosofía', 'Estacionamiento 6', 'Estacionamiento 4', 'Estacionamiento 3', 'Estacionamiento 2'
      ]},
      {'name': '13', 'color': 0xFF35A9AD, 'base_id': filosofiaId, 'stops': [
        'Facultad de Derecho', 'Camino Verde', 'Biblioteca Nacional 2', 'Unidad de Posgrado', 'Coordinación de Humanidades',
        'Facultad de Ciencias Políticas', 'Investigaciones Jurídicas 2', 'Metrobús CU-2', 'Estadio de Prácticas'
      ]},
    ];
    
    final stationIdCache = <String, int>{};

    for (final route in routesData) {
      final routeId = await db.insert('routes', {
        'name': route['name'],
        'color': route['color'],
        'base_id': route['base_id'],
      });

      final stops = route['stops'] as List<String>;
      for (int i = 0; i < stops.length; i++) {
        final stopName = stops[i];
        int stationId;

        if (stationIdCache.containsKey(stopName)) {
          stationId = stationIdCache[stopName]!;
        } else {
          stationId = await db.insert('stations', {'name': stopName}, conflictAlgorithm: ConflictAlgorithm.ignore);
          stationIdCache[stopName] = stationId;
        }

        await db.insert('route_stations', {
          'route_id': routeId,
          'station_id': stationId,
          'stop_order': i + 1, // El orden de la parada
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> getBases() async {
    final db = await instance.database;
    return await db.query('bases', orderBy: 'id');
  }

  Future<List<Map<String, dynamic>>> getRoutesForBase(int baseId) async {
    final db = await instance.database;
    return await db.query(
      'routes',
      where: 'base_id = ?',
      whereArgs: [baseId],
      orderBy: 'id',
    );
  }

  // Nuevo método para obtener las estaciones de una ruta específica
  Future<List<Map<String, dynamic>>> getStationsForRoute(int routeId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT s.name
      FROM stations s
      INNER JOIN route_stations rs ON s.id = rs.station_id
      WHERE rs.route_id = ?
      ORDER BY rs.stop_order
    ''', [routeId]);
    return result;
  }
}