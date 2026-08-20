import 'package:flutter/material.dart';
import '../models/book.dart';
import 'book_detail_screen.dart';
import 'my_library_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedGenre = 'All';
  final _genres = ['All', 'Fiction', 'Sci-Fi', 'Self-Help', 'Non-Fiction'];

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _selectedGenre == 'All'
        ? sampleBooks
        : sampleBooks.where((b) => b.genre == _selectedGenre).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookNook'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return OrientationBuilder(
              builder: (context, orientation) {
                final isLandscape = orientation == Orientation.landscape;
                final useGrid = isWide || isLandscape;

                return Column(
                  children: [
                    _GenreFilterRow(
                      genres: _genres,
                      selectedGenre: _selectedGenre,
                      onSelected: (genre) => setState(() => _selectedGenre = genre),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: useGrid
                          ? _BookGrid(
                              books: filteredBooks,
                              crossAxisCount: isWide ? 4 : 3,
                            )
                          : _BookList(books: filteredBooks),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 0) return;
          final pages = [
            const DiscoverScreen(),
            const MyLibraryScreen(),
            const ProgressScreen(),
            const ProfileScreen(),
          ];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => pages[index]),
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), label: 'My Library'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Genre filter chip row — shared by both layouts
class _GenreFilterRow extends StatelessWidget {
  final List<String> genres;
  final String selectedGenre;
  final ValueChanged<String> onSelected;

  const _GenreFilterRow({
    required this.genres,
    required this.selectedGenre,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          return ChoiceChip(
            label: Text(genre),
            selected: genre == selectedGenre,
            onSelected: (_) => onSelected(genre),
          );
        },
      ),
    );
  }
}

/// Portrait / narrow layout — vertical scrollable list with wide cards
class _BookList extends StatelessWidget {
  final List<Book> books;

  const _BookList({required this.books});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openDetail(context, book),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Hero(
                    tag: 'book-cover-${book.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        book.coverUrl,
                        width: 64,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 64,
                          height: 96,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.menu_book_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(book.author,
                            style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${book.rating}'),
                            const SizedBox(width: 12),
                            Chip(
                              label: Text(book.genre, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Landscape / wide layout — grid of cover-forward cards
class _BookGrid extends StatelessWidget {
  final List<Book> books;
  final int crossAxisCount;

  const _BookGrid({required this.books, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetail(context, book),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'book-cover-${book.id}',
                    child: Image.network(
                      book.coverUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.menu_book_outlined),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _openDetail(BuildContext context, Book book) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
  );
}