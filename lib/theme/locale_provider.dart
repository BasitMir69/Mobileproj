import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'ur'].contains(locale.languageCode)) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}
