import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/library_entry.dart';

/// Manages the user's saved books, backed by the SQLite
/// library_entries table. All Create/Read/Update/Delete operations
/// go through DBHelper, and notifyListeners() keeps the UI reactive.
class LibraryProvider extends ChangeNotifier {
  List<LibraryEntry> _entries = [];

  List<LibraryEntry> get entries => List.unmodifiable(_entries);

  bool isSaved(String bookId) => _entries.any((e) => e.bookId == bookId);

  /// Loads all saved entries from SQLite. Call this once at startup.
  Future<void> loadEntries() async {
    final db = await DBHelper.instance.database;
    final maps = await db.query('library_entries');
    _entries = maps.map((map) => LibraryEntry.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addBook({
    required String bookId,
    required String title,
    required String author,
    required String coverUrl,
  }) async {
    if (isSaved(bookId)) return;

    final entry = LibraryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bookId: bookId,
      title: title,
      author: author,
      coverUrl: coverUrl,
      dateAdded: DateTime.now(),
    );

    final db = await DBHelper.instance.database;
    await db.insert('library_entries', entry.toMap());

    _entries.add(entry);
    notifyListeners();
  }

  Future<void> updateEntry(String id, {double? rating, String? note}) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    if (rating != null) _entries[index].rating = rating;
    if (note != null) _entries[index].note = note;

    final db = await DBHelper.instance.database;
    await db.update(
      'library_entries',
      _entries[index].toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
  }

  Future<void> removeEntry(String id) async {
    final db = await DBHelper.instance.database;
    await db.delete('library_entries', where: 'id = ?', whereArgs: [id]);

    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}