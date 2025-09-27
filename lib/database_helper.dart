
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('routes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE bases (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE routes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      color INTEGER NOT NULL,
      base_id INTEGER NOT NULL,
      FOREIGN KEY (base_id) REFERENCES bases (id)
    )
    ''');
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Insert Bases
    int metroUniversidadId = await db.insert('bases', {'name': 'Metro Universidad'});
    int estadioId = await db.insert('bases', {'name': 'Estadio'});
    int metrobusCUId = await db.insert('bases', {'name': 'Metrobus CU'});

    // Insert Routes
    await db.insert('routes', {'name': '1', 'color': 0xFF118642, 'base_id': metroUniversidadId});
    await db.insert('routes', {'name': '2', 'color': 0xFFF0FF17, 'base_id': metroUniversidadId});
    await db.insert('routes', {'name': '3', 'color': 0xFF0B552A, 'base_id': metroUniversidadId});
    await db.insert('routes', {'name': '4', 'color': 0xFF52240A, 'base_id': metroUniversidadId});
    await db.insert('routes', {'name': '5', 'color': 0xFF1493C5, 'base_id': metroUniversidadId});

    await db.insert('routes', {'name': '6', 'color': 0xFF861111, 'base_id': estadioId});
    await db.insert('routes', {'name': '7', 'color': 0xFFACA003, 'base_id': estadioId});
    await db.insert('routes', {'name': '8', 'color': 0xFF080050, 'base_id': estadioId});

    await db.insert('routes', {'name': '9', 'color': 0xFFD824B1, 'base_id': metrobusCUId});
    await db.insert('routes', {'name': '10', 'color': 0xFF000000, 'base_id': metrobusCUId});
    await db.insert('routes', {'name': '11', 'color': 0xFF750996, 'base_id': metrobusCUId});
    await db.insert('routes', {'name': '12', 'color': 0xFFae86b1, 'base_id': metrobusCUId});
    await db.insert('routes', {'name': '13', 'color': 0xFF8ed2ce, 'base_id': metrobusCUId});
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
}
