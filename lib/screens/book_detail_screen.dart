import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/library_provider.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  Widget _buildCover(BuildContext context, ColorScheme colorScheme) {
    return Hero(
      tag: 'book-cover-${book.id}',
      child: Image.network(
        book.coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.menu_book_outlined, size: 64),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.author} · ${book.publishYear}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(book.genre),
              backgroundColor: colorScheme.secondaryContainer,
              labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: Colors.amber),
            const SizedBox(width: 6),
            Text(
              '${book.rating}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Text(
              'rating',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Consumer<LibraryProvider>(
            builder: (context, libraryProvider, _) {
              final alreadySaved = libraryProvider.isSaved(book.id);
              return FilledButton.icon(
                onPressed: alreadySaved
                    ? null
                    : () {
                        libraryProvider.addBook(
                          bookId: book.id,
                          title: book.title,
                          author: book.author,
                          coverUrl: book.coverUrl,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to your library')),
                        );
                      },
                icon: Icon(alreadySaved
                    ? Icons.bookmark_added
                    : Icons.bookmark_add_outlined),
                label: Text(alreadySaved ? 'In Your Library' : 'Add to Library'),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text('Description', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(book.description, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 24),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(label: 'Genre', value: book.genre),
                const Divider(height: 20),
                _DetailRow(label: 'Pages', value: '${book.pageCount}'),
                const Divider(height: 20),
                _DetailRow(label: 'Published', value: '${book.publishYear}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return OrientationBuilder(
              builder: (context, orientation) {
                final isLandscape = orientation == Orientation.landscape;
                final useSideBySide = isWide || isLandscape;

                if (useSideBySide) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Stack(
                          children: [
                            SizedBox.expand(child: _buildCover(context, colorScheme)),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black45,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _buildInfo(context, colorScheme),
                        ),
                      ),
                    ],
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 320,
                      pinned: true,
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildCover(context, colorScheme),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildInfo(context, colorScheme),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}