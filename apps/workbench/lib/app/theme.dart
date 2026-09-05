import 'package:flutter/material.dart';

const leadRed = Color(0xFFC93030);
const leadGreen = Color(0xFF2E8B46);
const leadBlue = Color(0xFF2B5FB8);

const tracePalette = [
  Color(0xFFC93030),
  Color(0xFF2B5FB8),
  Color(0xFF2E8B46),
  Color(0xFFB3541E),
  Color(0xFF6A3FB0),
  Color(0xFF8A7A1E),
  Color(0xFF1E8A8A),
  Color(0xFF666666),
];

ThemeData buildTheme(Brightness b) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2B5FB8),
    brightness: b,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    fontFamilyFallback: const ['Helvetica Neue', 'Segoe UI', 'Roboto'],
    cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
    dividerTheme: const DividerThemeData(space: 1, thickness: 1),
  );
}
