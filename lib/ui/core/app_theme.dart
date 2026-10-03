import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // =========================================================================
  // 🎬 AUTHENTIC NETFLIX DESIGN SYSTEM TOKENS
  // CINEMAX PRIME Flagship Streaming Palette
  // =========================================================================

  // Canvases & Surfaces (Netflix Pitch Black & Charcoal Surfaces)
  static const Color canvas = Color(0xFF141414);          // Netflix Canvas Deep Black
  static const Color surface = Color(0xFF181818);         // Netflix Elevated Card Surface
  static const Color surfaceElevated = Color(0xFF222222); // Hovered / Elevated Card Surface
  static const Color surfaceHighlight = Color(0xFF2F2F2F);// Modal & Scrubber Track

  // Netflix Signature Brand Red
  static const Color netflixRed = Color(0xFFE50914);      // Official Netflix Signature Red
  static const Color primary = netflixRed;                // Alias for primary brand color
  static const Color redHover = Color(0xFFB80710);        // Deep Red hover state

  // Netflix Match & Rating Indicators
  static const Color matchGreen = Color(0xFF46D369);      // Netflix "98% Match" Bright Green
  static const Color goldCeremony = Color(0xFFFFB800);    // Star rating gold

  // Netflix Billboard Buttons
  static const Color playButtonBg = Colors.white;         // Netflix Solid White Play Button
  static const Color playButtonText = Colors.black;       // Netflix Black Play Button Text
  static const Color infoButtonBg = Color(0xB36D6D6E);    // rgba(109, 109, 110, 0.7) More Info Button

  // Typography Neutrals
  static const Color textPrimary = Color(0xFFFFFFFF);     // Pure Crisp White
  static const Color textSecondary = Color(0xFFAAAAAA);   // 65% White / Silver Metadata
  static const Color textMuted = Color(0xFF757575);       // Muted Dark Slate Gray

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF2A2A2A);    // 1px Dark Divider
  static const Color borderHighlight = Color(0xFF3E3E3E);

  // Common UI Aliases for backward-compatibility
  static const Color starbucksGreen = netflixRed;
  static const Color greenAccent = netflixRed;
  static const Color houseGreen = Color(0xFFFFFFFF);
  static const Color greenMint = Color(0x33E50914);
  static const Color appleBlue = Color(0xFF0071EB);
  static const Color appleBlueLight = Color(0x330071EB);
  static const Color cyanAccent = netflixRed;
  static const Color goldWash = Color(0x22FFB800);
  static const Color canvasCeramic = surface;
  static const Color surfacePearl = surface;

  // Geometry (Netflix 4px subtle rounded corners & 50px pill buttons)
  static final BorderRadius cardRadius = BorderRadius.circular(4);
  static final BorderRadius pillRadius = BorderRadius.circular(50);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: canvas,
      primaryColor: netflixRed,
      colorScheme: const ColorScheme.dark(
        primary: netflixRed,
        secondary: matchGreen,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: textSecondary,
          height: 1.45,
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
    );
  }

  // Alias lightTheme to darkTheme so any existing callers get the authentic Netflix dark UI
  static ThemeData get lightTheme => darkTheme;
}
