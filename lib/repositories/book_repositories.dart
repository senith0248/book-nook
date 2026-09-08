import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/book.dart';

/// Handles all reads of book reference data: live search against the
/// public Open Library API, and a bundled local JSON fallback for
/// when the device is offline.
class BookRepository {
  static const _baseUrl = 'https://openlibrary.org';

  Future<List<Book>> searchBooks(String query) async {
    final uri = Uri.parse(
      '$_baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}&limit=20',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Open Library request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['docs'] as List<dynamic>? ?? [];
    return docs
        .map((doc) => Book.fromSearchJson(doc as Map<String, dynamic>))
        .toList();
  }

  /// Loads the bundled local JSON file used when there is no internet
  /// connection.
  Future<List<Book>> loadOfflineBooks() async {
    final raw = await rootBundle.loadString('assets/offline_books.json');
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((item) => Book.fromOfflineJson(item as Map<String, dynamic>))
        .toList();
  }
  /// Fetches a genuinely external, hosted JSON file (distinct from the
/// public API search) — a static "Featured Picks" list hosted on GitHub.
Future<List<Book>> fetchFeaturedBooks() async {
    final uri = Uri.parse(
      'https://raw.githubusercontent.com/senith0248/book-nook/main/lib/data/featured_book.json',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch featured books: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Book.fromOfflineJson(item as Map<String, dynamic>))
        .toList();
  }
}
