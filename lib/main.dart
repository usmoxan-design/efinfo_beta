import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:efinfo_beta/Pages/SplashPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eFootball Hub',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        fontFamily: GoogleFonts.outfit().fontFamily,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
          iconTheme: const IconThemeData(color: AppColors.textWhite),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        textTheme:
            GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: const TextStyle(color: AppColors.textWhite),
          bodyMedium: const TextStyle(color: AppColors.textGrey),
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
