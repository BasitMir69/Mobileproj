import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const _prefKey = 'isDarkMode';

  bool _isDarkMode = true;

  ThemeProvider({bool? isDarkMode}) {
    _isDarkMode = isDarkMode ?? true;
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isDarkMode);
    notifyListeners();
  }

  static final _lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF1F5F4), // light emerald tint
    primaryColor: const Color(0xFF0F766E), // emerald 700
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0F766E), // emerald 700
      secondary: Color(0xFF34D399), // emerald 400
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );

  static final _darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF06281F), // dark emerald base
    primaryColor: const Color(0xFF10B981), // emerald 500 accent
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF10B981), // emerald 500
      secondary: Color(0xFF34D399), // emerald 400
      surface: Color(0xFF0B3B2C), // deeper emerald for cards
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF06281F),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  // Gradient colors based on theme
  LinearGradient get backgroundGradient => _isDarkMode
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF06281F), // dark emerald
            Color(0xFF0B3B2C),
            Color(0xFF115E4A),
          ],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFE6F5F2), // very light emerald tint
            Color(0xFFCFF0E7),
          ],
        );

  // Text colors based on theme
  Color get primaryTextColor => _isDarkMode ? Colors.white : Colors.black;
  Color get secondaryTextColor => _isDarkMode ? Colors.white70 : Colors.black87;
  Color get inputFillColor =>
      _isDarkMode ? const Color(0x1AFFFFFF) : const Color(0xFFF0F5F4);
}
