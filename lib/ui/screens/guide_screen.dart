import 'package:chess_5d/core/utils.dart';
import 'package:chess_5d/core/constants.dart';
import 'package:chess_5d/ui/widgets/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

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
          'Guide',
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
                        'Introduction to 5D Chess',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildParagraph(
                        '5D Chess is a variant of chess that adds time travel and parallel timelines to the classic game. Pieces can move through time as well as space, creating a unique strategic experience.',
                        bodySize,
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
                        'Basic Rules',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildRuleItem(
                        '1. Standard Chess Rules',
                        'All standard chess rules apply within each timeline.',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildRuleItem(
                        '2. Time Travel',
                        'Pieces can move between timelines, allowing you to affect past and future board states.',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildRuleItem(
                        '3. Parallel Timelines',
                        'Creating new timelines splits the board, allowing parallel gameplay.',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildRuleItem(
                        '4. Checkmate',
                        'Win by checkmating the opponent\'s king in any timeline.',
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
                        'Tips for Beginners',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildTipItem(
                        'Start Simple',
                        'Begin with basic moves before experimenting with time travel.',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildTipItem(
                        'Protect Your King',
                        'Your king can be in danger across multiple timelines.',
                        bodySize,
                        spacing,
                        context,
                      ),
                      SizedBox(height: spacing),
                      _buildTipItem(
                        'Think in Multiple Dimensions',
                        'Consider how moves affect past, present, and future board states.',
                        bodySize,
                        spacing,
                        context,
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
      style: GoogleFonts.inter(
        fontSize: fontSize + 4,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildParagraph(String text, double fontSize, BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.6,
      ),
    );
  }

  Widget _buildRuleItem(
    String title,
    String description,
    double fontSize,
    double spacing,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(height: spacing * 0.5),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(
    String title,
    String description,
    double fontSize,
    double spacing,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: spacing * 0.3, right: spacing),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: fontSize + 1,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: spacing * 0.3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: fontSize - 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
