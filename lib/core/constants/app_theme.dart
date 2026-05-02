import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.blue600,
          secondary: AppColors.green500,
          surface: AppColors.white,
          error: AppColors.red500,
        ),
        scaffoldBackgroundColor: AppColors.contentBg,
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          bodyMedium: GoogleFonts.dmSans(fontSize: 13, color: AppColors.gray700),
          bodySmall: GoogleFonts.dmSans(fontSize: 11.5, color: AppColors.gray500),
          titleMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900),
          titleLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900),
        ),
        dividerColor: AppColors.gray200,
        dividerTheme: const DividerThemeData(color: AppColors.gray200, thickness: 1),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.gray50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.gray200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.gray200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.blue500, width: 1.5),
          ),
          hintStyle: GoogleFonts.dmSans(fontSize: 12.5, color: AppColors.gray400),
          labelStyle: GoogleFonts.dmSans(fontSize: 12.5, color: AppColors.gray600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue600,
            foregroundColor: AppColors.white,
            textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gray700,
            side: const BorderSide(color: AppColors.gray200),
            textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.white,
          titleTextStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900),
        ),
      );

  static TextStyle mono({double size = 12, FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.dmMono(fontSize: size, fontWeight: weight, color: color ?? AppColors.gray700);

  static TextStyle sans({double size = 13, FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color ?? AppColors.gray700);
}
