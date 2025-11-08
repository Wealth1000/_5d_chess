import 'package:flutter/material.dart';
import 'package:chess_5d/core/constants.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.tabletSmall;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.tabletSmall && width < Breakpoints.desktopSmall;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.desktopSmall;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < Breakpoints.tabletSmall) {
      return width * 0.9;
    } else if (width < Breakpoints.tabletLarge) {
      return width * 0.7;
    } else {
      return 600.0;
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final padding = ResponsiveSpacing.getPadding(getScreenWidth(context));
    return EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5);
  }

  static double getSpacing(BuildContext context) {
    return ResponsiveSpacing.getSpacing(getScreenWidth(context));
  }
}
