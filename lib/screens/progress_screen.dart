import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/library_provider.dart';
import 'discover_screen.dart';
import 'my_library_screen.dart';
import 'profile_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Widget _buildStatsCard(BuildContext context, ThemeData theme, ColorScheme colorScheme,
      ProgressProvider progressProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(
            value: '${progressProvider.distinctBooksLogged}',
            label: 'Books Read',
            colorScheme: colorScheme,
          ),
          _StatColumn(
            value: '${(progressProvider.totalPagesRead / 1000).toStringAsFixed(1)}k',
            label: 'Pages Read',
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, ThemeData theme, ColorScheme colorScheme,
      List<int> weeklyPages, List<String> weekLabels) {
    final maxVal = weeklyPages.isEmpty
        ? 1
        : weeklyPages.reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pages Read This Week', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(weeklyPages.length, (i) {
                  final barHeight = (weeklyPages[i] / maxVal) * 90;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          '${weeklyPages[i]}',
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: barHeight < 4 ? 4 : barHeight,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        child: Text(
                          weekLabels[i],
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsSection(BuildContext context, ThemeData theme, ColorScheme colorScheme,
      ProgressProvider progressProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Logs', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (progressProvider.logs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('No reading logged yet')),
          )
        else
          ...progressProvider.logs.map((log) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(Icons.menu_book_outlined,
                      color: colorScheme.onSecondaryContainer),
                ),
                title: Text(log.bookTitle),
                subtitle: Text('Read ${log.pagesRead} pages'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => progressProvider.removeLog(log.id),
                ),
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Progress')),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, _) {
          final weeklyPages = progressProvider.weeklyPages;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                return OrientationBuilder(
                  builder: (context, orientation) {
                    final isLandscape = orientation == Orientation.landscape;
                    final useSideBySide = isWide || isLandscape;

                    if (useSideBySide) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatsCard(context, theme, colorScheme, progressProvider),
                                  const SizedBox(height: 16),
                                  _buildChartCard(context, theme, colorScheme, weeklyPages, weekLabels),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 5,
                              child: _buildLogsSection(context, theme, colorScheme, progressProvider),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildStatsCard(context, theme, colorScheme, progressProvider),
                        const SizedBox(height: 16),
                        _buildChartCard(context, theme, colorScheme, weeklyPages, weekLabels),
                        const SizedBox(height: 16),
                        _buildLogsSection(context, theme, colorScheme, progressProvider),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogPagesDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 2) return;
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

  void _showLogPagesDialog(BuildContext context) {
    final libraryProvider = context.read<LibraryProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final savedBooks = libraryProvider.entries;

    if (savedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a book to your library first')),
      );
      return;
    }

    String? selectedBookId = savedBooks.first.bookId;
    String selectedBookTitle = savedBooks.first.title;
    final pagesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Log Pages Read'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedBookId,
                    decoration: const InputDecoration(labelText: 'Book'),
                    items: savedBooks.map((entry) {
                      return DropdownMenuItem(
                        value: entry.bookId,
                        child: Text(entry.title, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBookId = value;
                        selectedBookTitle =
                            savedBooks.firstWhere((e) => e.bookId == value).title;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pagesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Pages read'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final pages = int.tryParse(pagesController.text);
                    if (pages == null || pages <= 0 || selectedBookId == null) return;

                    progressProvider.addLog(
                      bookId: selectedBookId!,
                      bookTitle: selectedBookTitle,
                      pagesRead: pages,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final ColorScheme colorScheme;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
        ),
      ],
    );
  }
}