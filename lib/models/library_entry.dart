class LibraryEntry {
  final String id;
  final String bookId;
  final String title;
  final String author;
  final String coverUrl;
  double? rating;
  String? note;
  final DateTime dateAdded;

  LibraryEntry({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.rating,
    this.note,
    required this.dateAdded,
  });
}