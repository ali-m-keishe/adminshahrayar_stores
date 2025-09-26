import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Theme Colors (from your CSS variables)
  static const Color bgDark = Color(0xFF111827);
  static const Color bgSecondaryDark = Color(0xFF1F2937);
  static const Color bgTertiaryDark = Color(0xFF374151);
  static const Color textLight = Color(0xFFD1D5DB);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color borderDark = Color(0xFF374151);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);

  // Light Theme Colors
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color bgSecondaryLight = Color(0xFFFFFFFF);
  static const Color bgTertiaryLight = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color borderLight = Color(0xFFD1D5DB);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentBlue,
    scaffoldBackgroundColor: bgDark,
    cardColor: bgSecondaryDark,
    dividerColor: borderDark,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: textLight, displayColor: textWhite),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textLight),
    ),
    colorScheme: const ColorScheme.dark(
      primary: accentBlue,
      secondary: accentGreen,
      background: bgDark,
      surface: bgSecondaryDark,
      onBackground: textLight,
      onSurface: textWhite,
      tertiary: bgTertiaryDark,
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: MaterialStateProperty.all(bgTertiaryDark),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: borderDark),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentBlue),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentBlue,
        foregroundColor: textWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: accentBlue,
    scaffoldBackgroundColor: bgLight,
    cardColor: bgSecondaryLight,
    dividerColor: borderLight,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).apply(bodyColor: textDark, displayColor: textDark),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgLight,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
    ),
    colorScheme: const ColorScheme.light(
      primary: accentBlue,
      secondary: accentGreen,
      background: bgLight,
      surface: bgSecondaryLight,
      onBackground: textDark,
      onSurface: textDark,
      tertiary: bgTertiaryLight,
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: MaterialStateProperty.all(bgTertiaryLight),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: borderLight),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentBlue),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentBlue,
        foregroundColor: textWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
  );
}
