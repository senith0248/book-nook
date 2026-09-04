import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import 'discover_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class MyLibraryScreen extends StatelessWidget {
  const MyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, _) {
          final savedBooks = libraryProvider.entries;

          if (savedBooks.isEmpty) {
            return const Center(child: Text('No books saved yet'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              return OrientationBuilder(
                builder: (context, orientation) {
                  final isLandscape = orientation == Orientation.landscape;
                  final useGrid = isWide || isLandscape;

                  if (useGrid) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 4 : 3,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: savedBooks.length,
                      itemBuilder: (context, index) {
                        final entry = savedBooks[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      entry.coverUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: colorScheme.surfaceContainerHighest,
                                        child: const Icon(Icons.menu_book_outlined),
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                        color: Colors.white,
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black45,
                                          minimumSize: const Size(28, 28),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () {
                                          libraryProvider.removeEntry(entry.id);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        entry.author,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: savedBooks.length,
                    itemBuilder: (context, index) {
                      final entry = savedBooks[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              entry.coverUrl,
                              width: 48,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 72,
                                color: colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.menu_book_outlined),
                              ),
                            ),
                          ),
                          title: Text(entry.title),
                          subtitle: Text(entry.author),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              libraryProvider.removeEntry(entry.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Removed from library')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 1) return;
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