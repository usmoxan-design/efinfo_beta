import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:efinfo_beta/Pages/SplashPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eFootball Hub',
      theme: themeProvider.getTheme().copyWith(
            textTheme: GoogleFonts.outfitTextTheme(
              themeProvider.isDarkMode
                  ? ThemeData.dark().textTheme
                  : ThemeData.light().textTheme,
            ).copyWith(
              bodyLarge: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              bodyMedium: const TextStyle(color: Colors.grey),
            ),
          ),
      home: const SplashPage(),
    );
  }
}
