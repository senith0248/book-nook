import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'discover_screen.dart';
import 'my_library_screen.dart';
import 'progress_screen.dart';
import 'login_screen.dart';
import '../providers/library_provider.dart';
import '../providers/progress_provider.dart';
import '../services/shake_detector.dart';
import '../models/book.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ShakeDetector _shakeDetector;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector(onShake: _showRandomBookSuggestion);
    _shakeDetector.start();
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    super.dispose();
  }

  void _showRandomBookSuggestion() {
    final random = sampleBooks[Random().nextInt(sampleBooks.length)];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shuffle, size: 32, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'How about this one?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  random.coverUrl,
                  height: 160,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    width: 110,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.menu_book_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(random.title, style: Theme.of(context).textTheme.titleMedium),
              Text(random.author,
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(BuildContext context, ColorScheme colorScheme, User? user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.person, size: 40, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? 'Reader',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          user?.email ?? '',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Theme'),
                subtitle: const Text('Follows device setting'),
                trailing: Switch(value: false, onChanged: (_) {}),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Shake for a random book'),
                subtitle: const Text('Shake your phone anytime'),
                onTap: _showRandomBookSuggestion,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text('Log Out', style: TextStyle(color: colorScheme.error)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;
              await context.read<LibraryProvider>().loadEntries();
              await context.read<ProgressProvider>().loadLogs();

              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return OrientationBuilder(
              builder: (context, orientation) {
                final isLandscape = orientation == Orientation.landscape;
                final useSideBySide = isWide || isLandscape;

                if (useSideBySide) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _buildAvatarSection(context, colorScheme, user),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 6,
                          child: _buildSettingsSection(context, colorScheme),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(child: _buildAvatarSection(context, colorScheme, user)),
                    const SizedBox(height: 24),
                    _buildSettingsSection(context, colorScheme),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3, // Profile
        onDestinationSelected: (index) {
          if (index == 3) return;

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