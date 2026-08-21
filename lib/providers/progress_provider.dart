import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/reading_log.dart';

/// Manages reading log entries, backed by the SQLite reading_logs
/// table, and exposes aggregated stats for the Progress screen.
class ProgressProvider extends ChangeNotifier {
  List<ReadingLog> _logs = [];

  List<ReadingLog> get logs {
    final sorted = List<ReadingLog>.from(_logs);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  /// Loads all logs from SQLite. Call this once at startup.
  Future<void> loadLogs() async {
    final db = await DBHelper.instance.database;
    final maps = await db.query('reading_logs');
    _logs = maps.map((map) => ReadingLog.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addLog({
    required String bookId,
    required String bookTitle,
    required int pagesRead,
  }) async {
    final log = ReadingLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bookId: bookId,
      bookTitle: bookTitle,
      pagesRead: pagesRead,
      timestamp: DateTime.now(),
    );

    final db = await DBHelper.instance.database;
    await db.insert('reading_logs', log.toMap());

    _logs.add(log);
    notifyListeners();
  }

  Future<void> updateLog(String id, int newPagesRead) async {
    final index = _logs.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final updated = ReadingLog(
      id: _logs[index].id,
      bookId: _logs[index].bookId,
      bookTitle: _logs[index].bookTitle,
      pagesRead: newPagesRead,
      timestamp: _logs[index].timestamp,
    );

    final db = await DBHelper.instance.database;
    await db.update(
      'reading_logs',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    _logs[index] = updated;
    notifyListeners();
  }

  Future<void> removeLog(String id) async {
    final db = await DBHelper.instance.database;
    await db.delete('reading_logs', where: 'id = ?', whereArgs: [id]);

    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  int get totalPagesRead => _logs.fold(0, (sum, log) => sum + log.pagesRead);

  int get distinctBooksLogged => _logs.map((l) => l.bookId).toSet().length;

  List<int> get weeklyPages {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    return days.map((day) {
      return _logs
          .where((log) =>
              log.timestamp.year == day.year &&
              log.timestamp.month == day.month &&
              log.timestamp.day == day.day)
          .fold(0, (sum, log) => sum + log.pagesRead);
    }).toList();
  }
}