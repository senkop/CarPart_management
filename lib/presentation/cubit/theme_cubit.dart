import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

  ThemeCubit(this._prefs) : super(ThemeMode.light) {
    _loadTheme();
  }

  // Load theme from storage
  void _loadTheme() {
    final isDark = _prefs.getBool(_themeKey) ?? false;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  // Toggle between light and dark
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool(_themeKey, newMode == ThemeMode.dark);
    emit(newMode);
  }

  // Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.setBool(_themeKey, mode == ThemeMode.dark);
    emit(mode);
  }

  // Check if dark mode
  bool get isDarkMode => state == ThemeMode.dark;
}
