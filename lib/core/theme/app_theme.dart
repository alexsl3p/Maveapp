import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.accentBrown,
        onPrimary: AppColors.lightCream,
        primaryContainer: Color(0xFFEDDDD6),
        onPrimaryContainer: AppColors.deepText,
        secondary: AppColors.sageGreen,
        onSecondary: AppColors.lightCream,
        secondaryContainer: Color(0xFFE2E8DF),
        onSecondaryContainer: AppColors.deepText,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.background,
        onSurface: AppColors.deepText,
        surfaceContainerHighest: AppColors.cardBackground,
        outline: AppColors.divider,
        outlineVariant: AppColors.surfaceVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.cardBackground,
      dividerColor: AppColors.divider,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.deepText,
        displayColor: AppColors.deepText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.deepText,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.deepText,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightCream,
        indicatorColor: const Color(0xFFEDDDD6),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentBrown, size: 22);
          }
          return const IconThemeData(color: AppColors.mutedText, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentBrown,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.mutedText,
          );
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadow,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accentBrown,
        disabledColor: AppColors.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.deepText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentBrown, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.mutedText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBrown,
          foregroundColor: AppColors.lightCream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentBrown,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.accentBrown,
        onPrimary: AppColors.lightCream,
        primaryContainer: Color(0xFF3A2820),
        onPrimaryContainer: Color(0xFFEDDDD6),
        secondary: AppColors.sageGreen,
        onSecondary: AppColors.lightCream,
        secondaryContainer: Color(0xFF2A3028),
        onSecondaryContainer: Color(0xFFD8E8D4),
        error: AppColors.error,
        onError: Colors.white,
        surface: Color(0xFF1E1A18),
        onSurface: Color(0xFFEDE3DA),
        surfaceContainerHighest: Color(0xFF2A2420),
        outline: Color(0xFF4A3E38),
        outlineVariant: Color(0xFF3A2E28),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1612),
    );
  }
}
