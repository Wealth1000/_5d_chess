import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: appColorScheme,
  scaffoldBackgroundColor: appColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: appColorScheme.primary,
    foregroundColor: appColorScheme.onPrimary,
    elevation: 0,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: appColorScheme.secondary,
    foregroundColor: appColorScheme.onSecondary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: appColorScheme.secondary,
      foregroundColor: appColorScheme.onSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: appColorScheme.secondary),
  ),
  cardTheme: CardThemeData(
    color: appColorScheme.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? appColorScheme.secondary
          : appColorScheme.surfaceContainerHighest, // soft neutral tone
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? appColorScheme.secondary.withValues(alpha: 0.5)
          : appColorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    ),
  ),
);

const Color primaryColor = Color(0xFFFFF5F5);
const Color secondaryColor = Color(0xFF673AB7);

final ColorScheme appColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: secondaryColor,
  onPrimary: Colors.white,
  secondary: secondaryColor.withValues(alpha: 0.85),
  onSecondary: Colors.white,
  surface: primaryColor,
  onSurface: Colors.black87,
  error: Colors.red.shade600,
  onError: Colors.white,
);
