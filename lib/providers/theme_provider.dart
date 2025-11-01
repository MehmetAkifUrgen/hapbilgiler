import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.orange,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF9800),
        secondary: Color(0xFFFF5722),
        surface: Colors.white,
        error: Color(0xFFD32F2F),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFF9800),
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.orange,
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardColor: const Color(0xFF16213E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF9800),
        secondary: Color(0xFFFF5722),
        surface: Color(0xFF16213E),
        error: Color(0xFFEF5350),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF16213E),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}
