import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDB('ecoreport.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude TEXT NOT NULL,
        longitude TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        description TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertReport(Map<String, dynamic> row) async {
    final db = await getDatabase();
    return await db.insert('reports', row);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedReports() async {
    final db = await getDatabase();
    return await db.query('reports', where: 'synced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(int id) async {
    final db = await getDatabase();
    return await db.update(
      'reports',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}