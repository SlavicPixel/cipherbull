import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/entry.dart';

class DatabaseHelper {
  Database? _database;
  final String? dbName;
  final String? dbPassword;

  DatabaseHelper({required this.dbName, required this.dbPassword});

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final directory = await getApplicationDocumentsDirectory();

    String path = join(directory.path, '$dbName.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      password: dbPassword,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        username TEXT,
        password TEXT
      )
    ''');
  }

  Future<int> insertEntry(Entry entry) async {
    Database db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<List<Entry>> getEntries() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('entries');
    return result.map((map) => Entry.fromMap(map)).toList();
  }

  Future<int> updateEntry(Entry entry) async {
    Database db = await database;
    return await db.update('entries', entry.toMap(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteEntry(int id) async {
    Database db = await database;
    return await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }
}
