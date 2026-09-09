import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/db_helper.dart';
import '../models/reading_log.dart';

class ProgressProvider extends ChangeNotifier {
  List<ReadingLog> _logs = [];

  List<ReadingLog> get logs {
    final sorted = List<ReadingLog>.from(_logs);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadLogs() async {
    final userId = _currentUserId;
    if (userId == null) {
      _logs = [];
      notifyListeners();
      return;
    }

    final db = await DBHelper.instance.database;
    final maps = await db.query(
      'reading_logs',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    _logs = maps.map((map) => ReadingLog.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addLog({
    required String bookId,
    required String bookTitle,
    required int pagesRead,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final log = ReadingLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      bookId: bookId,
      bookTitle: bookTitle,
      pagesRead: pagesRead,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );

    final db = await DBHelper.instance.database;
    await db.insert('reading_logs', log.toMap());

    _logs.add(log);
    notifyListeners();
  }

  /// Updates just the location fields on an existing log, without
  /// blocking the initial save — used so location can be fetched
  /// in the background after the log is already saved.
  Future<void> attachLocation(String logId, double lat, double lng, String? name) async {
    final index = _logs.indexWhere((l) => l.id == logId);
    if (index == -1) return;

    final updated = ReadingLog(
      id: _logs[index].id,
      userId: _logs[index].userId,
      bookId: _logs[index].bookId,
      bookTitle: _logs[index].bookTitle,
      pagesRead: _logs[index].pagesRead,
      timestamp: _logs[index].timestamp,
      latitude: lat,
      longitude: lng,
      locationName: name,
    );

    final db = await DBHelper.instance.database;
    await db.update(
      'reading_logs',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [logId],
    );

    _logs[index] = updated;
    notifyListeners();
  }

  Future<void> updateLog(String id, int newPagesRead) async {
    final index = _logs.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final updated = ReadingLog(
      id: _logs[index].id,
      userId: _logs[index].userId,
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