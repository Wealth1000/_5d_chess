import 'package:chess_5d/core/theme.dart';
import 'package:chess_5d/core/theme_provider.dart';
import 'package:chess_5d/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, child) {
        return MaterialApp(
          title: '5D Chess',
          theme: getAppTheme(_themeProvider),
          home: HomeScreen(themeProvider: _themeProvider),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
