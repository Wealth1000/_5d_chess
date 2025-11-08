import 'package:chess_5d/core/utils.dart';
import 'package:chess_5d/core/constants.dart';
import 'package:chess_5d/core/theme_provider.dart';
import 'package:chess_5d/ui/screens/new_game_screen.dart';
import 'package:chess_5d/ui/screens/settings_screen.dart';
import 'package:chess_5d/ui/screens/guide_screen.dart';
import 'package:chess_5d/ui/screens/credits_screen.dart';
import 'package:chess_5d/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final ThemeProvider themeProvider;

  const HomeScreen({super.key, required this.themeProvider});

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Exit Game',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          content: Text(
            'Are you sure you want to exit?',
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Exit the app
                // In a real app, you might want to use SystemNavigator.pop()
              },
              child: Text('Exit', style: GoogleFonts.inter()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.getScreenWidth(context);
    final spacing = Responsive.getSpacing(context);
    final padding = Responsive.getScreenPadding(context);
    final titleSize = ResponsiveFontSize.getTitleSize(screenWidth);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '5D Chess',
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: titleSize,
            letterSpacing: 1.5,
          ),
        ),
        toolbarHeight: screenWidth < Breakpoints.mobileMedium ? 60 : 70,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: Responsive.getMaxContentWidth(context),
            ),
            padding: padding,
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: spacing * 2),
                // New Game Button (primary action)
                CustomButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NewGameScreen(),
                      ),
                    );
                  },
                  text: 'New Game',
                  isSecondary: true,
                  width: Responsive.getMaxContentWidth(context) * 0.5,
                ),
                SizedBox(height: spacing),
                // Guide Button
                CustomButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GuideScreen(),
                      ),
                    );
                  },
                  text: 'Guide',
                  width: Responsive.getMaxContentWidth(context) * 0.5,
                ),
                SizedBox(height: spacing),
                // Settings Button
                CustomButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SettingsScreen(themeProvider: themeProvider),
                      ),
                    );
                  },
                  text: 'Settings',
                  width: Responsive.getMaxContentWidth(context) * 0.5,
                ),
                SizedBox(height: spacing),
                // Credits Button
                CustomButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreditsScreen(),
                      ),
                    );
                  },
                  text: 'Credits',
                  width: Responsive.getMaxContentWidth(context) * 0.5,
                ),
                SizedBox(height: spacing),
                // Exit Button
                CustomButton(
                  onPressed: () => _showExitDialog(context),
                  text: 'Exit',
                  width: Responsive.getMaxContentWidth(context) * 0.5,
                ),
                SizedBox(height: spacing * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
