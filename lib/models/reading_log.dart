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
}