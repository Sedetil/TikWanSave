import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikwansave/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // State untuk tema gelap

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Muat tema saat aplikasi dimulai
  }

  // Memuat tema dari SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false; // Gunakan nilai default false
    });
  }

  // Menyimpan tema ke SharedPreferences
  Future<void> _toggleTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode); // Simpan tema yang dipilih
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TikTok Downloader',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(), // Ganti tema berdasarkan state
      home: MainScreen(onThemeChanged: _toggleTheme), // Oper fungsi callback
    );
  }
}
