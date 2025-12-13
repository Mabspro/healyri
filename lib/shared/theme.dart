import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Updated with more vibrant, trustworthy colors
  static const Color primaryColor = Color(0xFF1A73E8);  // Vibrant blue
  static const Color secondaryColor = Color(0xFF6C63FF); // Complementary purple
  static const Color accentColor = Color(0xFF00BFA5);   // Warmer teal
  static const Color backgroundColor = Color(0xFFF8F9FD);
  static const Color textColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF4A4A4A);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFB300);
  static const Color infoColor = Color(0xFF039BE5);
  
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFEEEEEE);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [Color(0xFF1A73E8), Color(0xFF5393FF)];
  static const List<Color> secondaryGradient = [Color(0xFF6C63FF), Color(0xFF8F88FF)];
  static const List<Color> accentGradient = [Color(0xFF00BFA5), Color(0xFF4CDFBC)];
  static const List<Color> errorGradient = [Color(0xFFE53935), Color(0xFFFF6B67)];
  static const List<Color> successGradient = [Color(0xFF43A047), Color(0xFF76C979)];
  
  // Shadow Styles
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 0,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.15),
      spreadRadius: 1,
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      spreadRadius: 2,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.25),
      spreadRadius: 0,
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Text Styles - Updated with Montserrat for headings and refined sizes
  static TextStyle get heading1 => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textColor,
    height: 1.2,
  );

  static TextStyle get heading2 => GoogleFonts.montserrat(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textColor,
    height: 1.2,
  );

  static TextStyle get heading3 => GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textColor,
    height: 1.3,
  );

  static TextStyle get heading4 => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
    height: 1.3,
  );

  static TextStyle get subtitle => GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
    height: 1.4,
  );

  static TextStyle get bodyText => GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textColor,
    height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    height: 1.4,
  );

  static TextStyle get buttonText => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  // Gradient Shader Methods
  static Shader primaryLinearGradient({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    return LinearGradient(
      colors: primaryGradient,
      begin: begin,
      end: end,
    ).createShader(const Rect.fromLTWH(0, 0, 200, 70));
  }
  
  static Shader secondaryLinearGradient({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    return LinearGradient(
      colors: secondaryGradient,
      begin: begin,
      end: end,
    ).createShader(const Rect.fromLTWH(0, 0, 200, 70));
  }
  
  static Shader accentLinearGradient({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    return LinearGradient(
      colors: accentGradient,
      begin: begin,
      end: end,
    ).createShader(const Rect.fromLTWH(0, 0, 200, 70));
  }

  // Light Theme - Enhanced with new styling
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onError: Colors.white,
      onSurface: textColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: heading3.copyWith(color: primaryColor),
      iconTheme: const IconThemeData(color: primaryColor),
      shadowColor: Colors.grey.withOpacity(0.1),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shadowColor: Colors.grey.withOpacity(0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade300;
          }
          return accentColor;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        textStyle: WidgetStateProperty.all(buttonText),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        elevation: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.pressed)) {
            return 2;
          }
          return 4;
        }),
        shadowColor: WidgetStateProperty.all(accentColor.withOpacity(0.4)),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.black.withOpacity(0.1);
          }
          return Colors.transparent;
        }),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade400;
          }
          return primaryColor;
        }),
        textStyle: WidgetStateProperty.all(buttonText.copyWith(color: primaryColor)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        side: WidgetStateProperty.resolveWith<BorderSide>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: Colors.grey.shade300);
          }
          return const BorderSide(color: primaryColor);
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryColor.withOpacity(0.1);
          }
          return Colors.transparent;
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade400;
          }
          return primaryColor;
        }),
        textStyle: WidgetStateProperty.all(buttonText.copyWith(color: primaryColor)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryColor.withOpacity(0.1);
          }
          return Colors.transparent;
        }),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: subtitle.copyWith(color: textSecondaryColor),
      hintStyle: bodyText.copyWith(color: textSecondaryColor.withOpacity(0.7)),
      floatingLabelStyle: subtitle.copyWith(color: primaryColor),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return primaryColor;
        }
        return textSecondaryColor;
      }),
      suffixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return primaryColor;
        }
        return textSecondaryColor;
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[100]!,
      disabledColor: Colors.grey[200]!,
      selectedColor: primaryColor.withOpacity(0.15),
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: bodyText.copyWith(fontSize: 14),
      secondaryLabelStyle: bodyText.copyWith(color: Colors.white, fontSize: 14),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 0,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: textSecondaryColor,
      labelStyle: subtitle.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: subtitle,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryColor,
            width: 3,
          ),
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
      selectedLabelStyle: caption.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: caption,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      elevation: 6,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: cardColor,
      titleTextStyle: heading3,
      contentTextStyle: bodyText,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textColor,
      contentTextStyle: bodyText.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
    textTheme: TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      headlineMedium: heading4,
      titleLarge: subtitle,
      bodyLarge: bodyText,
      bodyMedium: bodyText,
      labelLarge: buttonText,
      bodySmall: caption,
    ),
    useMaterial3: true,
  );

  // Dark Theme (keeping this for reference, but we'll use light theme)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.light, // Changed to light theme
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light( // Changed to light theme
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onError: Colors.white,
      onSurface: textColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    // Rest of the theme is the same as lightTheme
    appBarTheme: lightTheme.appBarTheme,
    cardTheme: lightTheme.cardTheme,
    elevatedButtonTheme: lightTheme.elevatedButtonTheme,
    outlinedButtonTheme: lightTheme.outlinedButtonTheme,
    textButtonTheme: lightTheme.textButtonTheme,
    inputDecorationTheme: lightTheme.inputDecorationTheme,
    chipTheme: lightTheme.chipTheme,
    tabBarTheme: lightTheme.tabBarTheme,
    bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme,
    floatingActionButtonTheme: lightTheme.floatingActionButtonTheme,
    dividerTheme: lightTheme.dividerTheme,
    dialogTheme: lightTheme.dialogTheme,
    textTheme: lightTheme.textTheme,
    useMaterial3: true,
  );
  
  // Helper methods for creating gradient containers
  static BoxDecoration gradientBoxDecoration({
    required List<Color> colors,
    double radius = 20,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }
  
  static BoxDecoration cardBoxDecoration({
    Color? color,
    double radius = 20,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ?? lightShadow,
    );
  }
}
