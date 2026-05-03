import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF7F2EA);
  static const Color cardBackground = Color(0xFFE9DED3);
  static const Color deepText = Color(0xFF2B1E1A);
  static const Color mutedText = Color(0xFF7A6A60);
  static const Color accentBrown = Color(0xFF8A6A58);
  static const Color sageGreen = Color(0xFF6F7766);
  static const Color lightCream = Color(0xFFFFFDF8);

  static const Color surface = Color(0xFFEFE8DF);
  static const Color surfaceVariant = Color(0xFFDDD3C8);
  static const Color divider = Color(0xFFD9CEC6);

  static const Color success = Color(0xFF5E8F6A);
  static const Color successLight = Color(0xFFE8F2EA);
  static const Color error = Color(0xFFAF5050);
  static const Color errorLight = Color(0xFFF5E8E8);

  static const Color shadow = Color(0x1A2B1E1A);
  static const Color shadowLight = Color(0x0D2B1E1A);

  // Category palette for product placeholders
  static const Map<String, List<Color>> categoryGradients = {
    'KOSMETIK': [Color(0xFFD4A4A4), Color(0xFFB87878)],
    'PROFESSIONAL': [Color(0xFF8A9E88), Color(0xFF5E7A5C)],
    'INSTRUMENT': [Color(0xFF9AA0A8), Color(0xFF6A7280)],
    'FRÄSER': [Color(0xFFA8A090), Color(0xFF787060)],
    'KÖRPER': [Color(0xFF9EAA98), Color(0xFF6E8468)],
  };

  static List<Color> gradientForCategory(String category) {
    return categoryGradients[category] ??
        [const Color(0xFFA89888), const Color(0xFF7A6858)];
  }
}
