import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Central SQLite database helper. Creates and manages two tables:
/// library_entries and reading_logs. All CRUD in the app goes through
/// this single database instance.
class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'booknook.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE library_entries (
            id TEXT PRIMARY KEY,
            bookId TEXT,
            title TEXT,
            author TEXT,
            coverUrl TEXT,
            rating REAL,
            note TEXT,
            dateAdded TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE reading_logs (
            id TEXT PRIMARY KEY,
            bookId TEXT,
            bookTitle TEXT,
            pagesRead INTEGER,
            timestamp TEXT
          )
        ''');
      },
    );
  }
}