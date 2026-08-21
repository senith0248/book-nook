import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/book.dart';
import '../repositories/book_repositories.dart';
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
  final _repository = BookRepository();
  final _searchController = TextEditingController();

  List<Book> _books = [];
  bool _isLoading = true;
  bool _isOffline = false;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooks('bestsellers');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasConnection) {
      final offlineBooks = await _repository.loadOfflineBooks();
      setState(() {
        _books = offlineBooks;
        _isOffline = true;
        _isLoading = false;
      });
      return;
    }

    try {
      final results = await _repository.searchBooks(query);
      setState(() {
        _books = results;
        _isOffline = false;
        _isLoading = false;
      });
    } catch (e) {
      final offlineBooks = await _repository.loadOfflineBooks();
      setState(() {
        _books = offlineBooks;
        _isOffline = true;
        _isLoading = false;
        _errorMessage = 'Could not reach the server. Showing offline books.';
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search for a book...',
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) _loadBooks(query.trim());
                },
              )
            : const Text('BookNook'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isOffline)
              Container(
                width: double.infinity,
                color: colorScheme.errorContainer,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, size: 18, color: colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage ?? "You're offline — showing saved books.",
                        style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _books.isEmpty
                      ? const Center(child: Text('No books found'))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 700;
                            return OrientationBuilder(
                              builder: (context, orientation) {
                                final isLandscape =
                                    orientation == Orientation.landscape;
                                final useGrid = isWide || isLandscape;

                                return useGrid
                                    ? _BookGrid(
                                        books: _books,
                                        crossAxisCount: isWide ? 4 : 3,
                                      )
                                    : _BookList(books: _books);
                              },
                            );
                          },
                        ),
            ),
          ],
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

class _BookList extends StatelessWidget {
  final List<Book> books;
  const _BookList({required this.books});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
              );
            },
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
            );
          },
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
                      Text(book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: colorScheme.onSurfaceVariant)),
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