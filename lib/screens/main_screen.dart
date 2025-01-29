import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(bool) onThemeChanged; // Tambahkan parameter ini

  const MainScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens;

  _MainScreenState() : _screens = [
    HomeScreen(),
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 2 // Jika indexnya 2, ganti dengan SettingsScreen yang baru
          ? SettingsScreen(onThemeChanged: widget.onThemeChanged)
          : _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
