import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.pink,
      scaffoldBackgroundColor: const Color(0xFFFFF0F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFB6C1),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB6C1),
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 2,
      ),
    );
  }
}
