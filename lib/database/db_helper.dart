import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Central SQLite database helper. Creates and manages two tables:
/// library_entries and reading_logs. All CRUD in the app goes through
/// this single database instance. Each row is tagged with a userId so
/// that data is scoped to the currently logged-in Firebase user.
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
      version: 2, // bumped
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE library_entries (
            id TEXT PRIMARY KEY,
            userId TEXT,
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
            userId TEXT,
            bookId TEXT,
            bookTitle TEXT,
            pagesRead INTEGER,
            timestamp TEXT,
            latitude REAL,
            longitude REAL,
            locationName TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE reading_logs ADD COLUMN latitude REAL');
          await db.execute('ALTER TABLE reading_logs ADD COLUMN longitude REAL');
          await db.execute('ALTER TABLE reading_logs ADD COLUMN locationName TEXT');
        }
      },
    );
  }
}