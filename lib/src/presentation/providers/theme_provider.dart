import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/config/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider(this.prefs) {
    _loadAppTheme();
  }

  ThemeMode get currentThemeMode => _themeMode;
  ThemeData get lightTheme => AppTheme.light;
  ThemeData get darkTheme => AppTheme.dark;

  Future<void> _loadAppTheme() async {
    // Load current theme mode
    String themeModeString = prefs.getString('themeMode') ?? 'light';

    switch (themeModeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    await prefs.setString(
      'themeMode',
      mode == ThemeMode.light ? 'light' : 'dark',
    );

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}
