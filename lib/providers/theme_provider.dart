import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Start with light mode by default
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // The constructor runs immediately when the app starts
  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Fetch the saved preference from the phone's memory
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // If no preference is found, default to false (light mode)
    final savedIsDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = savedIsDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggle the theme and save it to the phone instantly
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    // Save the new choice to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}