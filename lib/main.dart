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
          apiKey: "AIzaSyDooKufViiKuIw5Q_8g8iK0qWYjuzR_ZWM",
          authDomain: "efinfo-hub.firebaseapp.com",
          projectId: "efinfo-hub",
          storageBucket: "efinfo-hub.firebasestorage.app",
          messagingSenderId: "802735861500",
          appId: "1:802735861500:web:8785b5f4d6f1797691b179"),
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
