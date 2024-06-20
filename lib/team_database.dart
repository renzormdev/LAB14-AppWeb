import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TeamDatabase {
  static final TeamDatabase instance = TeamDatabase._internal();
  static Database? _database;

  TeamDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'teams.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        foundingYear INTEGER NOT NULL,
        lastChampDate TEXT NOT NULL
      )
    ''');
  }

  Future<int> create(Map<String, dynamic> team) async {
    final db = await instance.database;
    return await db.insert('teams', team);
  }

  Future<Map<String, dynamic>?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query('teams', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    return await db.query('teams');
  }

  Future<int> update(int id, Map<String, dynamic> team) async {
    final db = await instance.database;
    return await db.update('teams', team, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('teams', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  static String dateTimeToString(DateTime? date) {
    return date?.toIso8601String().split('T')[0] ?? '';
  }

  static DateTime? stringToDateTime(String? date) {
    return date != null && date.isNotEmpty ? DateTime.parse(date) : null;
  }
}
