class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String genre;
  final double rating;
  final String description;
  final int pageCount;
  final int publishYear;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.genre,
    required this.rating,
    required this.description,
    required this.pageCount,
    required this.publishYear,
  });

  /// Parses a single result from Open Library's /search.json response.
  factory Book.fromSearchJson(Map<String, dynamic> json) {
    final coverId = json['cover_i'];
    final authors = json['author_name'] as List<dynamic>?;
    final subjects = json['subject'] as List<dynamic>?;

    return Book(
      id: (json['key'] as String).replaceAll('/works/', ''),
      title: json['title'] as String? ?? 'Untitled',
      author: authors != null && authors.isNotEmpty
          ? authors.first as String
          : 'Unknown author',
      coverUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
          : 'https://covers.openlibrary.org/b/id/0-L.jpg',
      genre: subjects != null && subjects.isNotEmpty
          ? subjects.first as String
          : 'General',
      rating: 4.0, // Open Library search doesn't return ratings directly
      description: 'Tap to view more details about this book.',
      pageCount: json['number_of_pages_median'] as int? ?? 0,
      publishYear: json['first_publish_year'] as int? ?? 0,
    );
  }

  /// Parses a book from the bundled offline JSON asset.
  factory Book.fromOfflineJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['coverUrl'] as String,
      genre: json['genre'] as String,
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] as String,
      pageCount: json['pageCount'] as int,
      publishYear: json['publishYear'] as int,
    );
  }
}

// Kept as a fallback / initial reference list.
final sampleBooks = [
  const Book(
    id: '1',
    title: 'Atomic Habits',
    author: 'James Clear',
    coverUrl: 'https://covers.openlibrary.org/b/id/8231856-L.jpg',
    genre: 'Self-Help',
    rating: 4.5,
    description:
        'An easy and proven way to build good habits and break bad ones, '
        'focused on tiny changes that compound into remarkable results.',
    pageCount: 320,
    publishYear: 2018,
  ),
  const Book(
    id: '2',
    title: 'Dune',
    author: 'Frank Herbert',
    coverUrl: 'https://covers.openlibrary.org/b/id/8109669-L.jpg',
    genre: 'Sci-Fi',
    rating: 4.8,
    description:
        'Set on the desert planet Arrakis, Dune is the story of Paul '
        'Atreides and the struggle for control of the universe\'s most '
        'valuable resource.',
    pageCount: 412,
    publishYear: 1965,
  ),
  const Book(
    id: '3',
    title: 'Project Hail Mary',
    author: 'Andy Weir',
    coverUrl: 'https://covers.openlibrary.org/b/id/10521270-L.jpg',
    genre: 'Sci-Fi',
    rating: 4.7,
    description:
        'A lone astronaut must save the earth from disaster in this '
        'incredible new science-based thriller.',
    pageCount: 476,
    publishYear: 2021,
  ),
  const Book(
    id: '4',
    title: 'The Midnight Library',
    author: 'Matt Haig',
    coverUrl: 'https://covers.openlibrary.org/b/id/10389359-L.jpg',
    genre: 'Fiction',
    rating: 4.2,
    description:
        'Between life and death there is a library, and within that '
        'library, the shelves go on forever, each book giving the reader '
        'a chance to try another life.',
    pageCount: 288,
    publishYear: 2020,
  ),
];