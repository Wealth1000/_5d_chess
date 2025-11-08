import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess_5d/core/utils.dart';
import 'package:chess_5d/core/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.isSecondary = false,
  });

  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.getScreenWidth(context);
    final buttonWidth = width ?? Responsive.getMaxContentWidth(context) * 0.65;
    final buttonHeight =
        height ?? (screenWidth < Breakpoints.mobileMedium ? 48 : 56);
    final fontSize = ResponsiveFontSize.getButtonSize(screenWidth);

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: isSecondary
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isSecondary
            ? null
            : Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.3),
                width: 2,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                color: isSecondary
                    ? Theme.of(context).colorScheme.onSecondary
                    : Theme.of(context).colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
