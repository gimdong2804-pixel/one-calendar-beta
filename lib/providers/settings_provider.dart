import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSoundEnabled = true;
  double _soundVolume = 0.15;

  ThemeMode get themeMode => _themeMode;
  bool get isSoundEnabled => _isSoundEnabled;
  double get soundVolume => _soundVolume;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString('dailyThemeMode');
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    _isSoundEnabled = prefs.getBool('isTouchSoundEnabled') ?? true;
    _soundVolume = prefs.getDouble('touchSoundVolume') ?? 0.15;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString('dailyThemeMode', 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString('dailyThemeMode', 'dark');
    } else {
      await prefs.setString('dailyThemeMode', 'auto');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTouchSoundEnabled', enabled);
  }

  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('touchSoundVolume', volume);
  }
}
