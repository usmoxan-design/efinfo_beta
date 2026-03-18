import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:efinfo_beta/Pages/SplashPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "YOUR_API_KEY",
          authDomain: "yourapp.firebaseapp.com",
          projectId: "yourapp",
          storageBucket: "yourapp.firebasestorage.app",
          messagingSenderId: "123456789",
          appId: "1:802735861500:web:123456789"),
    );
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

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
