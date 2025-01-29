import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel {
  bool isDarkMode;

  SettingsModel({required this.isDarkMode});

  static Future<SettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    return SettingsModel(isDarkMode: isDarkMode);
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}
