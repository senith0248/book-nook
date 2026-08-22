import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/db_helper.dart';
import '../models/library_entry.dart';

class LibraryProvider extends ChangeNotifier {
  List<LibraryEntry> _entries = [];

  List<LibraryEntry> get entries => List.unmodifiable(_entries);

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  bool isSaved(String bookId) => _entries.any((e) => e.bookId == bookId);

  Future<void> loadEntries() async {
    final userId = _currentUserId;
    if (userId == null) {
      _entries = [];
      notifyListeners();
      return;
    }

    final db = await DBHelper.instance.database;
    final maps = await db.query(
      'library_entries',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    _entries = maps.map((map) => LibraryEntry.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addBook({
    required String bookId,
    required String title,
    required String author,
    required String coverUrl,
  }) async {
    final userId = _currentUserId;
    if (userId == null || isSaved(bookId)) return;

    final entry = LibraryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
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