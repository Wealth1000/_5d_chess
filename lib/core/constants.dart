class Breakpoints {
  // Mobile breakpoints
  static const double mobileSmall = 360;
  static const double mobileMedium = 480;
  static const double mobileLarge = 600;

  // Tablet breakpoints
  static const double tabletSmall = 768;
  static const double tabletLarge = 1024;

  // Desktop breakpoints
  static const double desktopSmall = 1280;
  static const double desktopLarge = 1920;
}

class ResponsiveSpacing {
  static double getSpacing(double screenWidth) {
    if (screenWidth < Breakpoints.mobileMedium) {
      return 8.0;
    } else if (screenWidth < Breakpoints.tabletSmall) {
      return 12.0;
    } else if (screenWidth < Breakpoints.tabletLarge) {
      return 16.0;
    } else {
      return 24.0;
    }
  }

  static double getPadding(double screenWidth) {
    if (screenWidth < Breakpoints.mobileMedium) {
      return 16.0;
    } else if (screenWidth < Breakpoints.tabletSmall) {
      return 24.0;
    } else if (screenWidth < Breakpoints.tabletLarge) {
      return 32.0;
    } else {
      return 48.0;
    }
  }
}

class ResponsiveFontSize {
  static double getTitleSize(double screenWidth) {
    if (screenWidth < Breakpoints.mobileMedium) {
      return 24.0;
    } else if (screenWidth < Breakpoints.tabletSmall) {
      return 28.0;
    } else if (screenWidth < Breakpoints.tabletLarge) {
      return 32.0;
    } else {
      return 36.0;
    }
  }

  static double getBodySize(double screenWidth) {
    if (screenWidth < Breakpoints.mobileMedium) {
      return 14.0;
    } else if (screenWidth < Breakpoints.tabletSmall) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  static double getButtonSize(double screenWidth) {
    if (screenWidth < Breakpoints.mobileMedium) {
      return 16.0;
    } else if (screenWidth < Breakpoints.tabletSmall) {
      return 18.0;
    } else {
      return 20.0;
    }
  }
}
