import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class ResponsiveUtils {
  // Breakpoint constants
  static const double smallPhone = 360;
  static const double mediumPhone = 480;
  static const double largePhone = 600;
  static const double smallTablet = 768;
  static const double largeTablet = 1024;
  static const double desktop = 1200;
  static const double largeDesktop = 1440;

  /// Determine device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < largePhone) {
      return DeviceType.mobile;
    } else if (width < desktop) {
      return DeviceType.tablet;
    } else if (width < largeDesktop) {
      return DeviceType.desktop;
    }
    return DeviceType.largeDesktop;
  }

  /// Get responsive font size based on screen width with more granular control
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? smallTablet,
    double? largeTablet,
    double? desktop,
    double? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    final _smallTablet = smallTablet ?? tablet;
    final _largeTablet = largeTablet ?? tablet;
    
    if (width >= 1440) {
      return largeDesktop ?? desktop ?? mobile * 1.3;
    } else if (width >= 1200) {
      return desktop ?? mobile * 1.2;
    } else if (width >= 1024) {
      return _largeTablet ?? mobile * 1.15;
    } else if (width >= 768) {
      return _smallTablet ?? mobile * 1.1;
    }
    return mobile;
  }

  /// Get responsive padding based on screen width with more granular control
  static double responsivePadding(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? smallTablet,
    double? largeTablet,
    double? desktop,
    double? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    final _smallTablet = smallTablet ?? tablet;
    final _largeTablet = largeTablet ?? tablet;
    
    if (width >= 1440) {
      return largeDesktop ?? desktop ?? mobile * 3;
    } else if (width >= 1200) {
      return desktop ?? mobile * 2.4;
    } else if (width >= 1024) {
      return _largeTablet ?? mobile * 2;
    } else if (width >= 768) {
      return _smallTablet ?? mobile * 1.5;
    }
    return mobile;
  }

  /// Get screen width
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is mobile (width < 600)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < largePhone;
  }

  /// Check if device is small mobile (width < 480)
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mediumPhone;
  }

  /// Check if device is tablet (width between 600 and 1200)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= largePhone && width < desktop;
  }

  /// Check if device is desktop (width >= 1200)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Check if device is large desktop (width >= 1440)
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }

  /// Check if device is in landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get grid column count based on screen size
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= largeDesktop) {
      return 4;
    } else if (width >= desktop) {
      return 3;
    } else if (width >= largeTablet) {
      return 2;
    }
    return 1;
  }

  /// Get responsive width for content (with max width)
  static double getContentWidth(
    BuildContext context, {
    double maxWidth = 1200,
  }) {
    final width = MediaQuery.of(context).size.width;
    return width > maxWidth ? maxWidth : width;
  }

  /// Get responsive spacing based on screen size
  static double getSpacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? smallTablet,
    double? largeTablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return responsivePadding(
      context,
      mobile: mobile,
      tablet: tablet,
      smallTablet: smallTablet,
      largeTablet: largeTablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= desktop) {
      return 56;
    } else if (width >= smallTablet) {
      return 52;
    }
    return 48;
  }

  /// Get responsive icon size
  static double getIconSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? smallTablet,
    double? largeTablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return responsiveFontSize(
      context,
      mobile: mobile,
      tablet: tablet,
      smallTablet: smallTablet,
      largeTablet: largeTablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= desktop) {
      return 20;
    } else if (width >= smallTablet) {
      return 16;
    }
    return 12;
  }

  /// Get safe area padding (accounts for notches, status bar, etc.)
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get view insets (keyboard, etc.)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  /// Get responsive horizontal margin
  static double getHorizontalMargin(BuildContext context) {
    return responsivePadding(
      context,
      mobile: 16,
      tablet: 24,
      largeTablet: 32,
      desktop: 48,
      largeDesktop: 64,
    );
  }

  /// Get responsive vertical margin
  static double getVerticalMargin(BuildContext context) {
    return responsivePadding(
      context,
      mobile: 12,
      tablet: 16,
      largeTablet: 20,
      desktop: 24,
      largeDesktop: 32,
    );
  }
}

/// Device type enum
enum DeviceType { mobile, tablet, desktop, largeDesktop }
