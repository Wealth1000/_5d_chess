import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = const Color(0xFFFFF5F5);
  Color _secondaryColor = const Color(0xFF673AB7);

  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setSecondaryColor(Color color) {
    _secondaryColor = color;
    notifyListeners();
  }

  ColorScheme get colorScheme => ColorScheme(
        brightness: Brightness.light,
        primary: _secondaryColor, // Note: primary in theme is actually the secondary color (purple)
        onPrimary: Colors.white,
        secondary: _secondaryColor.withValues(alpha: 0.85),
        onSecondary: Colors.white,
        surface: _primaryColor, // This is the light pink/cream color
        onSurface: Colors.black87,
        error: Colors.red.shade600,
        onError: Colors.white,
      );
}

