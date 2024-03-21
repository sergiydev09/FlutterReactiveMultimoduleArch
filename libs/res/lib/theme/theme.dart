import 'package:flutter/material.dart';

class MarvelTheme {
  static ThemeData get themeData {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFD32F2F), // Spider-Man Red
      onPrimary: Colors.white, // Text/icon color on primary color
      primaryContainer: Color(0xFFE57373), // Lighter Red
      onPrimaryContainer: Colors.white, // Text/icon color on primary container
      secondary: Color(0xFF1976D2), // Captain America Blue
      onSecondary: Colors.white, // Text/icon color on secondary color
      secondaryContainer: Color(0xFF64B5F6), // Lighter Blue
      onSecondaryContainer: Colors.white, // Text/icon color on secondary container
      error: Color(0xFFB00020), // Default Material Error
      onError: Colors.white, // Text/icon color on error color
      background: Colors.white, // Background color for components
      onBackground: Colors.black, // Text/icon color on background color
      surface: Colors.white, // Surface color for components like Card
      onSurface: Colors.black, // Text/icon color on surface color
      surfaceVariant: Color(0xFFEDE7F6), // A slight variant for surface
      onSurfaceVariant: Colors.black, // Text/icon color on surface variant
      outline: Color(0xFFBDBDBD), // Color for outlines and dividers
      shadow: Color(0xFF000000), // Shadow color
      inverseSurface: Color(0xFF121212), // Color for surfaces in dark theme
      onInverseSurface: Colors.white, // Text/icon color on inverse surfaces
      inversePrimary: Color(0xFFFFCDD2), // Inverse of the primary color
      tertiary: Color(0xFF4CAF50), // Additional color, Green for success messages
      onTertiary: Colors.white, // Text/icon color on tertiary color
      tertiaryContainer: Color(0xFFA5D6A7), // Lighter Green
      onTertiaryContainer: Colors.black, // Text/icon color on tertiary container
    );

    return ThemeData.from(colorScheme: colorScheme).copyWith(
      useMaterial3: true, // Ensures Material 3 features are enabled
    );
  }
}
