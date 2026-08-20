import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central Material 3 theme for BookNook.
/// A single warm brown seed color generates a full, accessible tonal
/// palette for both light and dark mode via ColorScheme.fromSeed.
/// Typography pairs a serif for headings (book-like feel) with a
/// clean sans-serif for body text.
class AppTheme {
  static const _seedColor = Color(0xFF6B4226); // warm library brown

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final headingFont = GoogleFonts.lora; // serif, book-like

    final textTheme = baseTextTheme.copyWith(
      displaySmall: headingFont(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      headlineSmall: headingFont(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleLarge: headingFont(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        height: 1.4,
        color: colorScheme.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        color: colorScheme.onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingFont(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        labelStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: GoogleFonts.inter(color: colorScheme.onSurface),
        shape: StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );
  }
}