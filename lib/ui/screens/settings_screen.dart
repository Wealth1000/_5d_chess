import 'package:chess_5d/core/utils.dart';
import 'package:chess_5d/core/constants.dart';
import 'package:chess_5d/core/theme_provider.dart';
import 'package:chess_5d/ui/widgets/custom_dialog_box.dart';
import 'package:chess_5d/ui/widgets/color_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const SettingsScreen({super.key, required this.themeProvider});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _notificationsEnabled = false;
  bool _animationsEnabled = true;
  bool _hapticFeedback = true;

  void _showColorPicker(String colorType) {
    final currentColor = colorType == 'Primary'
        ? widget.themeProvider.primaryColor
        : widget.themeProvider.secondaryColor;

    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: currentColor,
        title: 'Select $colorType Color',
      ),
    ).then((selectedColor) {
      if (selectedColor != null && selectedColor is Color) {
        if (colorType == 'Primary') {
          widget.themeProvider.setPrimaryColor(selectedColor);
        } else {
          widget.themeProvider.setSecondaryColor(selectedColor);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.getScreenWidth(context);
    final spacing = Responsive.getSpacing(context);
    final padding = Responsive.getScreenPadding(context);
    final titleSize = ResponsiveFontSize.getTitleSize(screenWidth);
    final bodySize = ResponsiveFontSize.getBodySize(screenWidth);
    final maxWidth = Responsive.getMaxContentWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.orbitron(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: titleSize * 0.7,
            letterSpacing: 1.0,
          ),
        ),
        toolbarHeight: screenWidth < Breakpoints.mobileMedium ? 60 : 70,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: padding,
            child: SingleChildScrollView(
              child: CustomDialogBox(
                width: double.infinity,
                padding: EdgeInsets.all(spacing * 2),
                children: [
                  _buildSectionTitle(
                    'Audio & Notifications',
                    bodySize,
                    context,
                  ),
                  SizedBox(height: spacing),
                  _buildSwitchTile(
                    'Enable Sound',
                    _soundEnabled,
                    (value) => setState(() => _soundEnabled = value),
                    context,
                  ),
                  Divider(height: spacing),
                  _buildSwitchTile(
                    'Enable Notifications',
                    _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                    context,
                  ),
                  SizedBox(height: spacing * 2),
                  _buildSectionTitle('Appearance', bodySize, context),
                  SizedBox(height: spacing),
                  // Primary Color Checkbox
                  _buildColorCheckboxTile(
                    'Primary Color',
                    widget.themeProvider.primaryColor,
                    () => _showColorPicker('Primary'),
                    context,
                    bodySize,
                    spacing,
                  ),
                  SizedBox(height: spacing),
                  // Secondary Color Checkbox
                  _buildColorCheckboxTile(
                    'Secondary Color',
                    widget.themeProvider.secondaryColor,
                    () => _showColorPicker('Secondary'),
                    context,
                    bodySize,
                    spacing,
                  ),
                  SizedBox(height: spacing * 2),
                  _buildSectionTitle('Preferences', bodySize, context),
                  SizedBox(height: spacing),
                  _buildSwitchTile(
                    'Animations',
                    _animationsEnabled,
                    (value) => setState(() => _animationsEnabled = value),
                    context,
                  ),
                  Divider(height: spacing),
                  _buildSwitchTile(
                    'Haptic Feedback',
                    _hapticFeedback,
                    (value) => setState(() => _hapticFeedback = value),
                    context,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    double fontSize,
    BuildContext context,
  ) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: fontSize + 2,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    BuildContext context,
  ) {
    final bodySize = ResponsiveFontSize.getBodySize(
      Responsive.getScreenWidth(context),
    );

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.getSpacing(context),
        vertical: Responsive.getSpacing(context) * 0.5,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: bodySize,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildColorCheckboxTile(
    String title,
    Color color,
    VoidCallback onTap,
    BuildContext context,
    double bodySize,
    double spacing,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing * 0.8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: true, // Always checked to indicate it's selectable
            onChanged: (value) => onTap(), // Opens color picker when clicked
            activeColor: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: bodySize,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap, // Also allow tapping the color preview
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
