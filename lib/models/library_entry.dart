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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'rating': rating,
      'note': note,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory LibraryEntry.fromMap(Map<String, dynamic> map) {
    return LibraryEntry(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      coverUrl: map['coverUrl'] as String,
      rating: map['rating'] as double?,
      note: map['note'] as String?,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
    );
  }
}