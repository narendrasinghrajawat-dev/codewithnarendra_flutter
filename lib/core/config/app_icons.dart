import 'package:flutter/material.dart';

/// Centralized icon/logo management
/// Change logo paths here to update across the entire app
class AppIcons {
  AppIcons._();

  // =====================================================
  // APP LOGO - Change this path to update logo everywhere
  // =====================================================
  static const String appLogo = 'assets/icons/codewithnarendra.png';

  // =====================================================
  // ICON SIZES - Adjust sizes here for consistency
  // =====================================================
  static const double logoSizeSmall = 32.0;
  static const double logoSizeMedium = 64.0;
  static const double logoSizeLarge = 128.0;
  static const double logoSizeXL = 256.0;

  // =====================================================
  // LOGO WIDGETS - Pre-configured logo widgets
  // =====================================================

  /// Small logo widget (32x32)
  static Widget logoSmall({Color? color}) {
    return Image.asset(
      appLogo,
      width: logoSizeSmall,
      height: logoSizeSmall,
      color: color,
    );
  }

  /// Medium logo widget (64x64)
  static Widget logoMedium({Color? color}) {
    return Image.asset(
      appLogo,
      width: logoSizeMedium,
      height: logoSizeMedium,
      color: color,
    );
  }

  /// Large logo widget (128x128)
  static Widget logoLarge({Color? color}) {
    return Image.asset(
      appLogo,
      width: logoSizeLarge,
      height: logoSizeLarge,
      color: color,
    );
  }

  /// Extra large logo widget (256x256)
  static Widget logoXL({Color? color}) {
    return Image.asset(
      appLogo,
      width: logoSizeXL,
      height: logoSizeXL,
      color: color,
    );
  }

  /// Custom size logo widget
  static Widget logoCustom({
    required double size,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.asset(
      appLogo,
      width: size,
      height: size,
      color: color,
      fit: fit,
    );
  }

  /// Logo with container and shadow (for splash screen)
  static Widget logoWithContainer({
    double size = logoSizeLarge,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      width: size + 32,
      height: size + 32,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Image.asset(
          appLogo,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
