import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isGrayscale = false;
  bool _isDarkMode = false;

  bool get isGrayscale => _isGrayscale;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadSetting();
  }

  void toggleGrayscale() {
    _isGrayscale = !_isGrayscale;
    _saveSetting();
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveSetting();
    notifyListeners();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isGrayscale = prefs.getBool('isGrayscale') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveSetting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGrayscale', _isGrayscale);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}
