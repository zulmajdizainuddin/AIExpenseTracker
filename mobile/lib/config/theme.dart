import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6366F1),
        brightness: Brightness.light,
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6366F1),
        brightness: Brightness.dark,
      );
}
