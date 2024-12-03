import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final _databaseName = "MiBaseDeDatos.db";
  static final _databaseVersion = 1;

  static final table = 'mi_tabla';
  static final columnId = '_id';
  static final columnNombre = 'nombre';
  static final columnApellido = 'apellido';
  static final columnMatricula = 'matricula';
  static final columnDescripcion = 'descripcion';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    // Inicializar la base de datos si aún no lo está
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    //Reuta donde se almacena la base de datos
    String path = join(await getDatabasesPath(), _databaseName);

    // Abrir/crear la base de datos
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnNombre TEXT NOT NULL,
            $columnApellido TEXT NOT NULL,
            $columnMatricula TEXT NOT NULL,
            $columnDescripcion TEXT NOT NULL
          )
          ''');
  }

  // Métodos CRUD...

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!
        .update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
