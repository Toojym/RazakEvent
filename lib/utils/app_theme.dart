import 'package:flutter/material.dart';

/// RazakEvent global theme & colour constants.
class AppTheme {
  AppTheme._();

  // ── Brand colours ──────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2E6BE6); // button blue
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDark = Color(0xFF212121);

  // ── Background gradient (approximates the Figma texture) ───────
  // To use the real texture instead:
  //   1. Export the background from Figma as PNG → assets/images/bg_texture.png
  //   2. Wrap your Scaffold body in a Stack and add:
  //      Image.asset('assets/images/bg_texture.png', fit: BoxFit.cover)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A0800), // dark warm black
      Color(0xFF3D1500), // deep brown
      Color(0xFFB85C1A), // burnt orange highlight
      Color(0xFF3D1500), // back to deep brown
      Color(0xFF0D0400), // almost black
    ],
    stops: [0.0, 0.2, 0.5, 0.75, 1.0],
  );

  // ── MaterialApp ThemeData ──────────────────────────────────────
  static ThemeData get theme => ThemeData(
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: const Color(0xFF1A0800),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
  );
}
