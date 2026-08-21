class ReadingLog {
  final String id;
  final String bookId;
  final String bookTitle;
  final int pagesRead;
  final DateTime timestamp;

  ReadingLog({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.pagesRead,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'pagesRead': pagesRead,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ReadingLog.fromMap(Map<String, dynamic> map) {
    return ReadingLog(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      bookTitle: map['bookTitle'] as String,
      pagesRead: map['pagesRead'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}