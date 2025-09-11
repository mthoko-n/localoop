import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colours.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPurple,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.accentPurple,
        onSecondary: AppColors.pureWhite,
        tertiary: AppColors.primaryPurpleLight,
        onTertiary: AppColors.gray900,
        surface: AppColors.pureWhite,
        onSurface: AppColors.gray900,
        surfaceContainerHighest: AppColors.gray100,
        onSurfaceVariant: AppColors.gray700,
        error: AppColors.error,
        onError: AppColors.pureWhite,
        outline: AppColors.gray300,
        outlineVariant: AppColors.gray200,
        shadow: AppColors.gray900,
        scrim: AppColors.pureBlack,
        inverseSurface: AppColors.gray800,
        onInverseSurface: AppColors.gray100,
        inversePrimary: AppColors.primaryPurpleLight,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.gray200,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(textStyle: AppTextStyles.appBarTitle),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryPurpleLight.withOpacity(0.2),
       labelTextStyle: WidgetStateProperty.all(AppTextStyles.navLabel),

      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(textStyle: AppTextStyles.bottomNavSelected),
        unselectedLabelStyle: GoogleFonts.inter(textStyle: AppTextStyles.bottomNavUnselected),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: AppColors.gray900.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.pureWhite,
          elevation: 2,
          shadowColor: AppColors.primaryPurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(textStyle: AppTextStyles.buttonText),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          textStyle: GoogleFonts.inter(textStyle: AppTextStyles.buttonText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side: const BorderSide(color: AppColors.primaryPurple),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(textStyle: AppTextStyles.buttonText),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(textStyle: AppTextStyles.inputLabel),
        hintStyle: GoogleFonts.inter(textStyle: AppTextStyles.inputHint),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(AppTextStyles.lightTextTheme),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurpleLight,
        onPrimary: AppColors.gray900,
        secondary: AppColors.accentPurpleLight,
        onSecondary: AppColors.gray900,
        tertiary: AppColors.primaryPurple,
        onTertiary: AppColors.pureWhite,
        surface: AppColors.gray800,
        onSurface: AppColors.gray100,
        surfaceContainerHighest: AppColors.gray700,
        onSurfaceVariant: AppColors.gray300,
        error: AppColors.error,
        onError: AppColors.pureWhite,
        outline: AppColors.gray600,
        outlineVariant: AppColors.gray700,
        shadow: AppColors.pureBlack,
        scrim: AppColors.pureBlack,
        inverseSurface: AppColors.gray200,
        onInverseSurface: AppColors.gray800,
        inversePrimary: AppColors.primaryPurple,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.gray800,
        foregroundColor: AppColors.gray100,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.pureBlack,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(textStyle: AppTextStyles.appBarTitleDark),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.gray800,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryPurpleLight.withOpacity(0.3),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.inter(textStyle: AppTextStyles.navLabel),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.gray800,
        selectedItemColor: AppColors.primaryPurpleLight,
        unselectedItemColor: AppColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(textStyle: AppTextStyles.bottomNavSelected),
        unselectedLabelStyle: GoogleFonts.inter(textStyle: AppTextStyles.bottomNavUnselected),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.gray800,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: AppColors.pureBlack.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurpleLight,
          foregroundColor: AppColors.gray900,
          elevation: 4,
          shadowColor: AppColors.primaryPurpleLight.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(textStyle: AppTextStyles.buttonText),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurpleLight,
          textStyle: GoogleFonts.inter(textStyle: AppTextStyles.buttonText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurpleLight,
          side: const BorderSide(color: AppColors.primaryPurpleLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(textStyle: AppTextStyles.buttonText),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryPurpleLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(textStyle: AppTextStyles.inputLabelDark),
        hintStyle: GoogleFonts.inter(textStyle: AppTextStyles.inputHintDark),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(AppTextStyles.darkTextTheme),
    );
  }

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primaryPurple, AppColors.accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [AppColors.primaryPurpleLight, AppColors.accentPurpleLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [AppColors.primaryPurpleDark, Color(0xFF5B21B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
