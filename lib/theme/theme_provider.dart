import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = "isDarkMode";
  static const String _glassKey = "isGlassMode";

  bool _isDarkMode = false;
  bool _isGlassMode = false;

  bool get isDarkMode => _isDarkMode;
  bool get isGlassMode => _isGlassMode;

  ThemeProvider() {
    _loadFromPrefs();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleGlassMode() {
    _isGlassMode = !_isGlassMode;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    _isGlassMode = prefs.getBool(_glassKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    await prefs.setBool(_glassKey, _isGlassMode);
  }

  ThemeData getTheme() {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    primaryColor: const Color(0xFF06DF5D),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF06DF5D),
      secondary: Color(0xFF00F294),
      surface: Color(0xFF161616),
    ),
    useMaterial3: true,
  );

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),
    primaryColor: const Color(0xFF06DF5D),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF06DF5D),
      secondary: Color(0xFF00F294),
      surface: Colors.white,
    ),
    useMaterial3: true,
  );
}
