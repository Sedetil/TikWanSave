import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SettingsScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _saveToGallery = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _saveToGallery = prefs.getBool('saveToGallery') ?? false;
    });
  }

  Future<void> _saveThemeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    widget.onThemeChanged(value);
  }

  Future<void> _saveGallerySetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saveToGallery', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSettingsTile(
            icon: Icons.palette,
            iconColor: Colors.blue,
            title: 'Tema',
            onTap: () => _navigateToThemeSettings(context),
          ),
          SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.save,
            iconColor: Colors.green,
            title: 'Penyimpanan',
            onTap: () => _navigateToStorageSettings(context),
          ),
          SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            iconColor: Colors.red,
            title: 'Privacy & Policy',
            onTap: () => _navigateToPrivacyPolicy(context),
          ),
          SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.info,
            iconColor: Colors.orange,
            title: 'Tentang',
            onTap: () => _navigateToAbout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).disabledColor),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _navigateToThemeSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemeSettingsScreen(
          isDarkMode: _isDarkMode,
          onThemeChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
            _saveThemeSetting(value);
          },
        ),
      ),
    );
  }

  void _navigateToStorageSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorageSettingsScreen(
          saveToGallery: _saveToGallery,
          onSaveToGalleryChanged: (value) {
            setState(() {
              _saveToGallery = value;
            });
            _saveGallerySetting(value);
          },
        ),
      ),
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivacyPolicyScreen(),
      ),
    );
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutScreen(),
      ),
    );
  }
}

class ThemeSettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ThemeSettingsScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tema'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tema Gelap', style: TextStyle(fontSize: 18)),
                Switch.adaptive(
                  value: isDarkMode,
                  onChanged: onThemeChanged,
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StorageSettingsScreen extends StatelessWidget {
  final bool saveToGallery;
  final Function(bool) onSaveToGalleryChanged;

  const StorageSettingsScreen({
    Key? key,
    required this.saveToGallery,
    required this.onSaveToGalleryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penyimpanan'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Simpan ke Galeri', style: TextStyle(fontSize: 18)),
                Switch.adaptive(
                  value: saveToGallery,
                  onChanged: onSaveToGalleryChanged,
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  static const String currentVersion = '1.2.0';

  Future<void> _checkForUpdates(BuildContext context) async {
    try {
      final latestVersion = await _fetchLatestVersion();
      if (latestVersion != currentVersion) {
        _showUpdateDialog(context, latestVersion);
      } else {
        _showLatestVersionDialog(context);
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  Future<String> _fetchLatestVersion() async {
    const apiUrl = 'https://api.github.com/repos/Sedetil/TikWanSave/releases/latest';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['tag_name'];
    } else {
      throw Exception('Failed to fetch latest version');
    }
  }

  void _showUpdateDialog(BuildContext context, String latestVersion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pembaruan Tersedia'),
        content: Text('Versi terbaru ($latestVersion) tersedia. Apakah Anda ingin memperbarui?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () => _openGitHubPage(context),
            child: Text('Perbarui'),
          ),
        ],
      ),
    );
  }

  void _showLatestVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sudah Versi Terbaru'),
        content: Text('Aplikasi Anda sudah versi terbaru ($currentVersion).'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kesalahan'),
        content: Text('Gagal memeriksa pembaruan: $error'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openGitHubPage(BuildContext context) async {
    const githubUrl = 'https://github.com/Sedetil/TikWanSave/releases';
    final Uri url = Uri.parse(githubUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.inAppWebView);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka URL $githubUrl'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 72, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Versi Aplikasi $currentVersion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _checkForUpdates(context),
              icon: Icon(Icons.update, color: Colors.blue),
              label: Text(
                'Periksa Pembaruan',
                style: TextStyle(color: Colors.blue),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy & Policy'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Terakhir diperbarui: 28/01/2025',
              style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor),
            ),
            SizedBox(height: 24),
            _buildPolicySection(
              title: '1. Informasi yang Kami Kumpulkan',
              content: 'Kami mungkin mengumpulkan informasi pribadi seperti nama, alamat email, dan informasi lainnya yang Anda berikan kepada kami saat mendaftar atau menggunakan aplikasi.',
            ),
            _buildPolicySection(
              title: '2. Penggunaan Informasi',
              content: 'Informasi yang kami kumpulkan digunakan untuk: \n'
                  '- Meningkatkan pengalaman pengguna. \n'
                  '- Mengirimkan informasi dan pembaruan tentang aplikasi. \n'
                  '- Menanggapi pertanyaan dan permintaan Anda.',
            ),
            _buildPolicySection(
              title: '3. Keamanan Informasi',
              content: 'Kami mengambil langkah-langkah yang sesuai untuk melindungi informasi pribadi Anda dari akses yang tidak sah, pengungkapan, perubahan, atau perusakan.',
            ),
            _buildPolicySection(
              title: '4. Perubahan Kebijakan Privasi',
              content: 'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan tersebut dengan memposting kebijakan privasi yang baru di halaman ini.',
            ),
            _buildPolicySection(
              title: '5. Kontak',
              content: 'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, silakan hubungi kami di alwanpriyanto@gmail.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}