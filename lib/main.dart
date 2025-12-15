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
      title: 'eFootball Info Hub',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF117340)),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF06DF5D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              // fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
