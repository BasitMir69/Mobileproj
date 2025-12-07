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
    // Light mode uses dark yellow (golden) accents with black text for contrast
    scaffoldBackgroundColor: const Color(0xFFFFFBF0), // warm cream
    primaryColor: const Color(0xFFB8860B), // dark goldenrod (accent)
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFB8860B), // dark yellow/golden accent
      onPrimary: Colors.black,
      secondary: Color(0xFFFFD54F), // lighter amber
      surface: Colors.white,
      // background/onBackground deprecated; use surface/onSurface
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFBF0),
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );

  static final _darkTheme = ThemeData.dark().copyWith(
    // Dark mode: near-black background with dark yellow accents
    scaffoldBackgroundColor: const Color(0xFF0B0B0B), // near black
    primaryColor: const Color(0xFFB8860B), // dark yellow/goldenrod accent
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB8860B), // golden accent
      onPrimary: Colors.black,
      secondary: Color(0xFFFFD54F), // lighter amber accent
      surface: Color(0xFF121212), // slightly lighter surface for cards
      // background/onBackground deprecated; use surface/onSurface
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B0B0B),
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
            Color(0xFF0B0B0B), // near black
            Color(0xFF1A1A1A),
            Color(0xFF2A2A2A),
          ],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFBF0), // warm cream
            Color(0xFFFFF3D6),
            Color(0xFFFFE9B8),
          ],
        );

  // Text colors based on theme
  Color get primaryTextColor => _isDarkMode ? Colors.white : Colors.black;
  Color get secondaryTextColor => _isDarkMode ? Colors.white70 : Colors.black87;
  Color get inputFillColor =>
      _isDarkMode ? const Color(0x14FFFFFF) : const Color(0xFFFFF6EA);
}
