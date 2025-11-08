import 'package:chess_5d/core/utils.dart';
import 'package:chess_5d/core/constants.dart';
import 'package:chess_5d/ui/widgets/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

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
          'Credits',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: spacing),
                  CustomDialogBox(
                    width: double.infinity,
                    padding: EdgeInsets.all(spacing * 2),
                    children: [
                      _buildSectionTitle(
                        'Multiverse Chess',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      Text(
                        'Flutter Edition',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: bodySize,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        'Version 1.0.0',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: bodySize - 2,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  CustomDialogBox(
                    width: double.infinity,
                    padding: EdgeInsets.all(spacing * 2),
                    children: [
                      _buildSectionTitle(
                        'Acknowledgement',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildCreditItem(
                        'Multiverse Chess',
                        'by L0laapk3',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        'This project is a Flutter-based adaptation of the open-source project Multiverse Chess by L0laapk3.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: bodySize - 1,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        'Full credit for the original mechanics, rule systems, and implementation ideas goes to the original developers.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: bodySize - 1,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: spacing),
                      _buildLinkItem(
                        'GitHub Repository',
                        'github.com/L0laapk3/multiverse-chess',
                        bodySize,
                        spacing,
                        context,
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  CustomDialogBox(
                    width: double.infinity,
                    padding: EdgeInsets.all(spacing * 2),
                    children: [
                      _buildSectionTitle(
                        'Development',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildCreditItem(
                        'Flutter Implementation',
                        'Cross-platform mobile and desktop',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildCreditItem(
                        'Flutter Team',
                        'Amazing cross-platform framework',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildCreditItem(
                        'Google Fonts',
                        'Beautiful typography',
                        bodySize,
                        spacing,
                        context,
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  CustomDialogBox(
                    width: double.infinity,
                    padding: EdgeInsets.all(spacing * 2),
                    children: [
                      _buildSectionTitle('License', bodySize, spacing, context),
                      SizedBox(height: spacing),
                      Text(
                        'MIT License',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: bodySize + 1,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        'Copyright (c) 2025 Wealth1000',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: bodySize - 1,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        'This Flutter version is released under the same MIT License, in full respect of the original project\'s open-source terms.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: bodySize - 2,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 2),
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
    double spacing,
    BuildContext context,
  ) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: fontSize + 4,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCreditItem(
    String title,
    String description,
    double fontSize,
    double spacing,
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: fontSize + 1,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: spacing * 0.3),
        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: fontSize - 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkItem(
    String title,
    String link,
    double fontSize,
    double spacing,
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: spacing * 0.2),
        Text(
          link,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: fontSize - 1,
            color: Theme.of(context).colorScheme.secondary,
            decoration: TextDecoration.underline,
            decorationColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
