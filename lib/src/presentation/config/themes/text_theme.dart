import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/config/themes/dark_theme.dart';
import 'package:flutter_whatsapp_clon/src/presentation/config/themes/light_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  static TextTheme get light => GoogleFonts.spaceGroteskTextTheme()
      .apply(
        displayColor: LightTheme.titleTextColor,
        bodyColor: LightTheme.primaryTextColor,
      )
      .copyWith(
        displayLarge: const TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      );

  static TextTheme get dark => GoogleFonts.spaceGroteskTextTheme()
      .apply(
        displayColor: DarkTheme.titleTextColor,
        bodyColor: DarkTheme.primaryTextColor,
      )
      .copyWith(
        displayLarge: const TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: const TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      );
}
