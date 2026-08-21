import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'providers/library_provider.dart';
import 'providers/progress_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // required before async setup
  runApp(const BookNookApp());
}

class BookNookApp extends StatelessWidget {
  const BookNookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()..loadLogs()),
      ],
      child: MaterialApp(
        title: 'BookNook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}