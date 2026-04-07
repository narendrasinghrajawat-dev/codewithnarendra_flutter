import 'package:flutter/material.dart';

class AppTheme {
  static const String fontInter = 'Inter';
  
  // Light Theme Colors
  static const Color lightPrimaryColor = Color(0xFF6366F1);
  static const Color lightSecondaryColor = Color(0xFF8B5CF6);
  static const Color lightBackgroundColor = Color(0xFFFAFAFA);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightOnSurfaceColor = Color(0xFF1F2937);
  static const Color lightOnBackgroundColor = Color(0xFF1F2937);
  
  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF6366F1);
  static const Color darkSecondaryColor = Color(0xFF8B5CF6);
  static const Color darkBackgroundColor = Color(0xFF0F172A);
  static const Color darkSurfaceColor = Color(0xFF1E293B);
  static const Color darkOnSurfaceColor = Color(0xFFF1F5F9);
  static const Color darkOnBackgroundColor = Color(0xFFF1F5F9);
  
  // Text Styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: fontInter,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: fontInter,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: fontInter,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: fontInter,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: fontInter,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: fontInter,
  );
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  
  // Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: lightPrimaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurfaceColor,
      foregroundColor: lightOnSurfaceColor,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: lightSurfaceColor,
      shadowColor: Colors.black12,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLarge,
          vertical: spacingMedium,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: headline1,
      headlineMedium: headline2,
      headlineSmall: headline3,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPrimaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurfaceColor,
      foregroundColor: darkOnSurfaceColor,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: darkSurfaceColor,
      shadowColor: Colors.black12,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLarge,
          vertical: spacingMedium,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: headline1,
      headlineMedium: headline2,
      headlineSmall: headline3,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
    ),
  );
}
