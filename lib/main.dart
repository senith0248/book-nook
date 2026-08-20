import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const BookNookApp());
}

class BookNookApp extends StatelessWidget {
  const BookNookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookNook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // follows the device's light/dark setting
      home: const LoginScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}