import 'package:flutter/material.dart';
import 'package:chess_5d/core/theme_provider.dart';

ThemeData getAppTheme(ThemeProvider themeProvider) {
  final colorScheme = themeProvider.colorScheme;
  
  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    useMaterial3: true,
  appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    elevation: 0,
      centerTitle: true,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
  ),
  cardTheme: CardThemeData(
      color: colorScheme.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
            ? colorScheme.secondary
            : const Color(0xFF9C27B0), // Stronger purple for off state
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
            ? colorScheme.secondary.withValues(alpha: 0.5)
            : colorScheme.secondary.withValues(
                alpha: 0.15,
              ), // Lighter track for better contrast
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.secondary.withValues(alpha: 0.2),
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
);
}
