import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSoundEnabled = true;
  double _soundVolume = 0.15;

  // 액션바 관련 상태
  double _actionBarBlur = 28.0;
  List<String> _actionBarOrder = [
    'btnAIChat',
    'btnToggleAI',
    'btnReset',
    'btnSave',
    'btnCloudSync',
    'btnLoginLogout',
    'btnPrint',
  ];
  Set<String> _actionBarHidden = {};

  ThemeMode get themeMode => _themeMode;
  bool get isSoundEnabled => _isSoundEnabled;
  double get soundVolume => _soundVolume;

  double get actionBarBlur => _actionBarBlur;
  List<String> get actionBarOrder => _actionBarOrder;

  bool isButtonVisible(String id) => !_actionBarHidden.contains(id);

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

    _actionBarBlur = prefs.getDouble('actionBarBlur') ?? 28.0;

    final savedOrder = prefs.getStringList('actionBarOrder');
    if (savedOrder != null) {
      final defaultButtons = [
        'btnAIChat',
        'btnToggleAI',
        'btnReset',
        'btnSave',
        'btnCloudSync',
        'btnLoginLogout',
        'btnPrint',
      ];
      final merged = <String>[];
      for (final id in savedOrder) {
        if (defaultButtons.contains(id)) {
          merged.add(id);
        }
      }
      for (final id in defaultButtons) {
        if (!merged.contains(id)) {
          merged.add(id);
        }
      }
      _actionBarOrder = merged;
    }

    final savedHidden = prefs.getStringList('actionBarHidden');
    if (savedHidden != null) {
      _actionBarHidden = savedHidden.toSet();
    }

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

  Future<void> setActionBarBlur(double value) async {
    _actionBarBlur = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('actionBarBlur', value);
  }

  Future<void> toggleButtonVisibility(String id, bool visible) async {
    if (visible) {
      _actionBarHidden.remove(id);
    } else {
      _actionBarHidden.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('actionBarHidden', _actionBarHidden.toList());
  }

  Future<void> reorderActionBar(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = _actionBarOrder.removeAt(oldIndex);
    _actionBarOrder.insert(newIndex, item);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('actionBarOrder', _actionBarOrder);
  }
}
