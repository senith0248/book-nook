import 'package:flutter/foundation.dart';
import '../models/library_entry.dart';

/// Holds the user's saved books in memory and notifies listeners
/// whenever the list changes. This is the Create/Read/Update/Delete
/// layer for "My Library".
class LibraryProvider extends ChangeNotifier {
  final List<LibraryEntry> _entries = [];

  List<LibraryEntry> get entries => List.unmodifiable(_entries);

  bool isSaved(String bookId) => _entries.any((e) => e.bookId == bookId);

  void addBook({
    required String bookId,
    required String title,
    required String author,
    required String coverUrl,
  }) {
    if (isSaved(bookId)) return; // avoid duplicates

    final entry = LibraryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bookId: bookId,
      title: title,
      author: author,
      coverUrl: coverUrl,
      dateAdded: DateTime.now(),
    );

    _entries.add(entry);
    notifyListeners();
  }

  void updateEntry(String id, {double? rating, String? note}) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    if (rating != null) _entries[index].rating = rating;
    if (note != null) _entries[index].note = note;
    notifyListeners();
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}