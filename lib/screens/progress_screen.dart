import 'package:flutter/material.dart';
import 'discover_screen.dart';
import 'my_library_screen.dart';
import 'profile_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Static sample data for the layout-only prototype stage
    const booksRead = 12;
    const pagesRead = 3800;
    final weeklyPages = [30, 15, 45, 60, 20, 10, 35];
    final weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final recentLogs = [
      ('The Midnight Library', 24, 'Today, 8:15 AM'),
      ('Project Hail Mary', 42, 'Yesterday, 9:30 PM'),
      ('Atomic Habits', 15, 'Oct 24, 7:10 AM'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  value: '$booksRead',
                  label: 'Books Read',
                  colorScheme: colorScheme,
                ),
                _StatColumn(
                  value: '${(pagesRead / 1000).toStringAsFixed(1)}k',
                  label: 'Pages Read',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
         const SizedBox(height: 16),
          Card(
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
                        final maxVal = weeklyPages.reduce((a, b) => a > b ? a : b);
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
                              height: barHeight,
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
          ),
          const SizedBox(height: 16),
          Text('Recent Logs', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...recentLogs.map((log) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(Icons.menu_book_outlined,
                      color: colorScheme.onSecondaryContainer),
                ),
                title: Text(log.$1),
                subtitle: Text('Read ${log.$2} pages'),
                trailing: Text(log.$3, style: theme.textTheme.bodySmall),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2, // Progress
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