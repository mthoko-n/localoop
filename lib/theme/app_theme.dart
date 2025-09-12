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

      // Color Scheme - Emphasizing black/white with purple highlights
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPurple,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.primaryPurple, // Use purple for secondary too
        onSecondary: AppColors.pureWhite,
        tertiary: AppColors.accentPurple,
        onTertiary: AppColors.pureWhite,
        surface: AppColors.pureWhite, // Pure white surfaces
        onSurface: AppColors.pureBlack, // Pure black text on white
        surfaceContainerHighest: AppColors.gray100, // Very light gray for containers
        onSurfaceVariant: AppColors.gray600, // Darker gray for secondary text
        error: AppColors.error,
        onError: AppColors.pureWhite,
        outline: AppColors.gray400, // Medium gray for outlines
        outlineVariant: AppColors.gray200, // Light gray for subtle outlines
        shadow: AppColors.pureBlack,
        scrim: AppColors.pureBlack,
        inverseSurface: AppColors.pureBlack, // Pure black for inverse
        onInverseSurface: AppColors.pureWhite,
        inversePrimary: AppColors.primaryPurpleLight,
      ),

      // AppBar Theme - Clean white with black text
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.pureBlack,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.gray300,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.appBarTitle.copyWith(
            color: AppColors.pureBlack,
          ),
        ),
      ),

      // Navigation Bar Theme - White background, purple highlights
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryPurple.withOpacity(0.15), // Subtle purple indicator
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navLabel.copyWith(color: AppColors.primaryPurple);
          }
          return AppTextStyles.navLabel.copyWith(color: AppColors.gray600);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryPurple);
          }
          return const IconThemeData(color: AppColors.gray600);
        }),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.bottomNavSelected.copyWith(
            color: AppColors.primaryPurple,
          ),
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.bottomNavUnselected.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ),

      // Card Theme - Pure white with subtle shadows
      cardTheme: CardTheme(
        color: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: AppColors.pureBlack.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.gray200, // Subtle border for definition
            width: 1,
          ),
        ),
      ),

      // Button Themes - Purple highlights on white/black base
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.pureWhite,
          elevation: 2,
          shadowColor: AppColors.primaryPurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonText.copyWith(
              color: AppColors.pureWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonText.copyWith(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          backgroundColor: AppColors.pureWhite,
          side: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonText.copyWith(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // Input Decoration Theme - White fields with gray borders, purple focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.inputLabel.copyWith(
            color: AppColors.gray600,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.inputHint.copyWith(
            color: AppColors.gray400,
          ),
        ),
      ),

      // Text Theme - Black text on white background
      textTheme: GoogleFonts.interTextTheme(
        AppTextStyles.lightTextTheme.copyWith(
          bodyLarge: AppTextStyles.lightTextTheme.bodyLarge?.copyWith(
            color: AppColors.pureBlack,
          ),
          bodyMedium: AppTextStyles.lightTextTheme.bodyMedium?.copyWith(
            color: AppColors.pureBlack,
          ),
          bodySmall: AppTextStyles.lightTextTheme.bodySmall?.copyWith(
            color: AppColors.gray600,
          ),
          headlineLarge: AppTextStyles.lightTextTheme.headlineLarge?.copyWith(
            color: AppColors.pureBlack,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: AppTextStyles.lightTextTheme.headlineMedium?.copyWith(
            color: AppColors.pureBlack,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: AppTextStyles.lightTextTheme.headlineSmall?.copyWith(
            color: AppColors.pureBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme - Black background with white text and purple highlights
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurpleLight,
        onPrimary: AppColors.pureBlack,
        secondary: AppColors.primaryPurpleLight,
        onSecondary: AppColors.pureBlack,
        tertiary: AppColors.accentPurpleLight,
        onTertiary: AppColors.pureBlack,
        surface: AppColors.pureBlack, // Pure black surfaces
        onSurface: AppColors.pureWhite, // Pure white text on black
        surfaceContainerHighest: AppColors.gray900, // Very dark gray for containers
        onSurfaceVariant: AppColors.gray300, // Light gray for secondary text
        error: AppColors.error,
        onError: AppColors.pureWhite,
        outline: AppColors.gray600, // Medium gray for outlines
        outlineVariant: AppColors.gray700, // Dark gray for subtle outlines
        shadow: AppColors.pureBlack,
        scrim: AppColors.pureBlack,
        inverseSurface: AppColors.pureWhite, // Pure white for inverse
        onInverseSurface: AppColors.pureBlack,
        inversePrimary: AppColors.primaryPurple,
      ),

      // AppBar Theme - Pure black with white text
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.pureBlack,
        foregroundColor: AppColors.pureWhite,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.gray700,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.appBarTitleDark.copyWith(
            color: AppColors.pureWhite,
          ),
        ),
      ),

      // Navigation Bar Theme - Black background, purple highlights
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.pureBlack,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryPurpleLight.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navLabel.copyWith(color: AppColors.primaryPurpleLight);
          }
          return AppTextStyles.navLabel.copyWith(color: AppColors.gray400);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryPurpleLight);
          }
          return const IconThemeData(color: AppColors.gray400);
        }),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureBlack,
        selectedItemColor: AppColors.primaryPurpleLight,
        unselectedItemColor: AppColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.bottomNavSelected.copyWith(
            color: AppColors.primaryPurpleLight,
          ),
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.bottomNavUnselected.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ),

      // Card Theme - Pure black with subtle borders
      cardTheme: CardTheme(
        color: AppColors.pureBlack,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: AppColors.pureBlack.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.gray700, // Subtle border for definition
            width: 1,
          ),
        ),
      ),

      // Button Themes - Purple highlights on black/white base
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurpleLight,
          foregroundColor: AppColors.pureBlack,
          elevation: 4,
          shadowColor: AppColors.primaryPurpleLight.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonText.copyWith(
              color: AppColors.pureBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurpleLight,
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonText.copyWith(
              color: AppColors.primaryPurpleLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurpleLight,
          backgroundColor: AppColors.pureBlack,
          side: const BorderSide(color: AppColors.primaryPurpleLight, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            textStyle: AppTextStyles.buttonText.copyWith(
              color: AppColors.primaryPurpleLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // Input Decoration Theme - Black fields with gray borders, purple focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray600, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray600, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryPurpleLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.inputLabelDark.copyWith(
            color: AppColors.gray300,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          textStyle: AppTextStyles.inputHintDark.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ),

      // Text Theme - White text on black background
      textTheme: GoogleFonts.interTextTheme(
        AppTextStyles.darkTextTheme.copyWith(
          bodyLarge: AppTextStyles.darkTextTheme.bodyLarge?.copyWith(
            color: AppColors.pureWhite,
          ),
          bodyMedium: AppTextStyles.darkTextTheme.bodyMedium?.copyWith(
            color: AppColors.pureWhite,
          ),
          bodySmall: AppTextStyles.darkTextTheme.bodySmall?.copyWith(
            color: AppColors.gray300,
          ),
          headlineLarge: AppTextStyles.darkTextTheme.headlineLarge?.copyWith(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: AppTextStyles.darkTextTheme.headlineMedium?.copyWith(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: AppTextStyles.darkTextTheme.headlineSmall?.copyWith(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Gradients - Refined for black/white/purple theme
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

  // Additional utility gradients for your black/white/purple theme
  static const LinearGradient blackToGrayGradient = LinearGradient(
    colors: [AppColors.pureBlack, AppColors.gray800],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient whiteToGrayGradient = LinearGradient(
    colors: [AppColors.pureWhite, AppColors.gray100],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}