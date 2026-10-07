import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesService {
  LocalPreferencesService(this._prefs);

  final SharedPreferences _prefs;
  static const _themeKey = 'theme_mode';

  String get themeMode => _prefs.getString(_themeKey) ?? 'system';

  Future<void> setThemeMode(String value) => _prefs.setString(_themeKey, value);
}
