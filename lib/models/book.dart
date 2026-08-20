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
}

// Static sample data used for the UI-only prototype stage.
final sampleBooks = [
  const Book(
    id: '1',
    title: 'Atomic Habits',
    author: 'James Clear',
    coverUrl: 'https://covers.openlibrary.org/b/id/15217381-L.jpg',
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
