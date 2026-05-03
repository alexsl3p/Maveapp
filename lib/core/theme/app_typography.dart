import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: AppColors.deepText,
        letterSpacing: -0.8,
        height: 1.15,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        color: AppColors.deepText,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.deepText,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.deepText,
        letterSpacing: -0.2,
        height: 1.35,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.deepText,
        letterSpacing: -0.1,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.deepText,
        letterSpacing: 0,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.deepText,
        letterSpacing: 0,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedText,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.deepText,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedText,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get priceDisplay => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w200,
        color: AppColors.deepText,
        letterSpacing: -1.0,
        height: 1.1,
      );

  static TextStyle get kpiValue => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w300,
        color: AppColors.deepText,
        letterSpacing: -0.6,
        height: 1.1,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.mutedText,
        letterSpacing: 1.2,
        height: 1.4,
      );
}
