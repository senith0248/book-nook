import 'package:flutter/foundation.dart';
import '../models/reading_log.dart';

/// Holds reading log entries and exposes aggregated stats for the
/// Progress screen (books read, pages read, weekly breakdown).
class ProgressProvider extends ChangeNotifier {
  final List<ReadingLog> _logs = [];

  List<ReadingLog> get logs {
    final sorted = List<ReadingLog>.from(_logs);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  void addLog({
    required String bookId,
    required String bookTitle,
    required int pagesRead,
  }) {
    final log = ReadingLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bookId: bookId,
      bookTitle: bookTitle,
      pagesRead: pagesRead,
      timestamp: DateTime.now(),
    );
    _logs.add(log);
    notifyListeners();
  }

  void updateLog(String id, int newPagesRead) {
    final index = _logs.indexWhere((l) => l.id == id);
    if (index == -1) return;
    _logs[index] = ReadingLog(
      id: _logs[index].id,
      bookId: _logs[index].bookId,
      bookTitle: _logs[index].bookTitle,
      pagesRead: newPagesRead,
      timestamp: _logs[index].timestamp,
    );
    notifyListeners();
  }

  void removeLog(String id) {
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  int get totalPagesRead => _logs.fold(0, (sum, log) => sum + log.pagesRead);

  int get distinctBooksLogged =>
      _logs.map((l) => l.bookId).toSet().length;

  /// Returns pages read per day for the last 7 days, oldest first.
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