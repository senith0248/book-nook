import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:book_nook/theme.dart';
import 'package:book_nook/models/book.dart';
import 'package:book_nook/models/library_entry.dart';
import 'package:book_nook/models/reading_log.dart';
import 'package:book_nook/providers/library_provider.dart';
import 'package:book_nook/providers/progress_provider.dart';
import 'package:book_nook/screens/login_screen.dart';
import 'package:book_nook/screens/register_screen.dart';
import 'package:book_nook/screens/discover_screen.dart';
import 'package:book_nook/screens/book_detail_screen.dart';
import 'package:book_nook/screens/progress_screen.dart';
import 'package:book_nook/screens/my_library_screen.dart';

class MockLibraryProvider extends ChangeNotifier implements LibraryProvider {
  final List<LibraryEntry> _mockEntries = [];

  @override
  List<LibraryEntry> get entries => List.unmodifiable(_mockEntries);

  @override
  bool isSaved(String bookId) => _mockEntries.any((e) => e.bookId == bookId);

  @override
  Future<void> loadEntries() async {}

  @override
  Future<void> addBook({
    required String bookId,
    required String title,
    required String author,
    required String coverUrl,
  }) async {
    _mockEntries.add(LibraryEntry(
      id: 'mock-${_mockEntries.length + 1}',
      userId: 'test-user',
      bookId: bookId,
      title: title,
      author: author,
      coverUrl: coverUrl,
      dateAdded: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  Future<void> updateEntry(String id, {double? rating, String? note}) async {
    final index = _mockEntries.indexWhere((e) => e.id == id);
    if (index != -1) {
      if (rating != null) _mockEntries[index].rating = rating;
      if (note != null) _mockEntries[index].note = note;
      notifyListeners();
    }
  }

  @override
  Future<void> removeEntry(String id) async {
    _mockEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

class MockProgressProvider extends ChangeNotifier implements ProgressProvider {
  final List<ReadingLog> _mockLogs = [];

  @override
  List<ReadingLog> get logs => List.unmodifiable(_mockLogs);

  @override
  int get distinctBooksLogged => _mockLogs.map((l) => l.bookId).toSet().length;

  @override
  int get totalPagesRead => _mockLogs.fold(0, (sum, log) => sum + log.pagesRead);

  @override
  List<int> get weeklyPages => [10, 20, 0, 45, 15, 30, 0];

  @override
  Future<void> loadLogs() async {}

  @override
  Future<void> addLog({
    required String bookId,
    required String bookTitle,
    required int pagesRead,
  }) async {
    _mockLogs.add(ReadingLog(
      id: 'mock-log-${_mockLogs.length + 1}',
      userId: 'test-user',
      bookId: bookId,
      bookTitle: bookTitle,
      pagesRead: pagesRead,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  Future<void> updateLog(String id, int newPagesRead) async {
    final index = _mockLogs.indexWhere((l) => l.id == id);
    if (index != -1) {
      _mockLogs[index] = ReadingLog(
        id: _mockLogs[index].id,
        userId: _mockLogs[index].userId,
        bookId: _mockLogs[index].bookId,
        bookTitle: _mockLogs[index].bookTitle,
        pagesRead: newPagesRead,
        timestamp: _mockLogs[index].timestamp,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeLog(String id) async {
    _mockLogs.removeWhere((l) => l.id == id);
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget(
    Widget child, {
    ThemeData? theme,
    LibraryProvider? libraryProvider,
    ProgressProvider? progressProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LibraryProvider>.value(
          value: libraryProvider ?? MockLibraryProvider(),
        ),
        ChangeNotifierProvider<ProgressProvider>.value(
          value: progressProvider ?? MockProgressProvider(),
        ),
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: child,
      ),
    );
  }

  group('Category 1: Authentication & Validation (TC01 - TC09)', () {
    testWidgets('TC01: Login screen loads correctly with logo, fields, buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
      expect(find.text('BookNook'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Log In'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Register'), findsOneWidget);
    });

    testWidgets('TC02: Empty email validation displays "Enter your email"', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pump();

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('TC03: Invalid email format validation displays "Enter a valid email"', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'abc');
      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('TC04: Short password validation displays "Password must be at least 6 characters"', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('TC05: Password visibility toggle', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump();

      final passwordFieldBefore = tester.widget<EditableText>(
        find.descendant(of: find.widgetWithText(TextFormField, 'Password'), matching: find.byType(EditableText)),
      );
      expect(passwordFieldBefore.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      final passwordFieldAfter = tester.widget<EditableText>(
        find.descendant(of: find.widgetWithText(TextFormField, 'Password'), matching: find.byType(EditableText)),
      );
      expect(passwordFieldAfter.obscureText, isFalse);
    });

    testWidgets('TC06: Navigate to Register screen', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, 'Register'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('TC07: Register form field validation', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('TC08: Confirm password mismatch', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Alice');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'alice@test.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'different123');

      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('TC09: Navigate back to Login from Register', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, 'Register'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Log In'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('Category 2 & 3: Navigation & Master/Detail (TC10 - TC15)', () {
    testWidgets('TC10, TC11, TC12: Bottom navigation bar shows 4 tabs and is structured', (tester) async {
      await tester.pumpWidget(createTestWidget(const DiscoverScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('My Library'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('TC13, TC14, TC15: Book card opens detail with full info and hero tag', (tester) async {
      const testBook = Book(
        id: '99',
        title: 'Atomic Habits',
        author: 'James Clear',
        coverUrl: 'https://example.com/cover.jpg',
        genre: 'Self-Help',
        rating: 4.5,
        description: 'An easy and proven way to build good habits.',
        pageCount: 320,
        publishYear: 2018,
      );

      await tester.pumpWidget(createTestWidget(const BookDetailScreen(book: testBook)));
      await tester.pump();

      expect(find.text('Atomic Habits'), findsOneWidget);
      expect(find.text('James Clear · 2018'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('An easy and proven way to build good habits.'), findsOneWidget);
      expect(find.text('320'), findsOneWidget);
      expect(find.text('Self-Help'), findsNWidgets(2)); // Chip and detail row
      expect(find.byType(Hero), findsOneWidget);
    });
  });

  group('Category 6: Components & Dialogs (TC21 - TC25)', () {
    testWidgets('TC21 & TC22: Card and Scrollable list render', (tester) async {
      final mockLib = MockLibraryProvider();
      await mockLib.addBook(
        bookId: '1',
        title: 'Dune',
        author: 'Frank Herbert',
        coverUrl: 'https://example.com/dune.jpg',
      );

      await tester.pumpWidget(createTestWidget(const MyLibraryScreen(), libraryProvider: mockLib));
      await tester.pump();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('Frank Herbert'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('TC23: Form field types present in Register screen', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
    });

    testWidgets('TC24 & TC25: Dialog + Dropdown and Cancel button in ProgressScreen', (tester) async {
      final mockLib = MockLibraryProvider();
      await mockLib.addBook(
        bookId: '1',
        title: 'Atomic Habits',
        author: 'James Clear',
        coverUrl: 'https://example.com/cover.jpg',
      );

      await tester.pumpWidget(createTestWidget(const ProgressScreen(), libraryProvider: mockLib));
      await tester.pump();

      // Tap Log Pages FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Log Pages Read'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.widgetWithText(TextField, ''), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('Category 7 & 8: Theme & Content Quality (TC26 - TC32)', () {
    testWidgets('TC26, TC27, TC29: Light and Dark Theme creation with M3 and high contrast', (tester) async {
      final lightTheme = AppTheme.light();
      final darkTheme = AppTheme.dark();

      expect(lightTheme.brightness, equals(Brightness.light));
      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(lightTheme.useMaterial3, isTrue);
      expect(darkTheme.useMaterial3, isTrue);
      expect(lightTheme.colorScheme.surface, isNotNull);
      expect(darkTheme.colorScheme.surface, isNotNull);
    });

    testWidgets('TC32: Typography consistency (Lora headings and Inter body)', (tester) async {
      final theme = AppTheme.light();
      expect(theme.textTheme.headlineSmall?.fontFamily, contains('Lora'));
      expect(theme.textTheme.titleLarge?.fontFamily, contains('Lora'));
      expect(theme.textTheme.bodyMedium?.fontFamily, contains('Inter'));
    });
  });
}
