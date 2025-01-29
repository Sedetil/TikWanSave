import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.palette, color: Colors.blue),
            title: Text('Tema'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
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
            },
          ),
          ListTile(
            leading: Icon(Icons.save, color: Colors.green),
            title: Text('Penyimpanan'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
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
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: Colors.red),
            title: Text('Privacy & Policy'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.orange),
            title: Text('Tentang'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutScreen(),
                ),
              );
            },
          ),
        ],
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
      appBar: AppBar(title: Text('Tema')),
      body: ListTile(
        title: Text('Tema Gelap'),
        trailing: Switch(
          value: isDarkMode,
          onChanged: onThemeChanged,
          activeColor: Colors.blue,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.blue[100],
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
      appBar: AppBar(title: Text('Penyimpanan')),
      body: ListTile(
        title: Text('Simpan ke Galeri'),
        trailing: Switch(
          value: saveToGallery,
          onChanged: onSaveToGalleryChanged,
          activeColor: Colors.blue,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.blue[100],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<String> _fetchLatestVersion() async {
    const githubApiUrl =
        'https://api.github.com/repos/Sedetil/TikWanSave/releases/latest';
    final response = await http.get(Uri.parse(githubApiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['tag_name'];
    } else {
      throw Exception('Gagal mendapatkan versi terbaru');
    }
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    const currentVersion = '1.0.0';
    try {
      final latestVersion = await _fetchLatestVersion();
      if (latestVersion != currentVersion) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pembaruan Tersedia'),
            content: Text(
                'Versi terbaru ($latestVersion) tersedia. Apakah Anda ingin memperbarui?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Nanti'),
              ),
              TextButton(
                onPressed: () async {
                  const updateUrl = 'https://github.com/Sedetil/TikWanSave/releases';
                  if (await canLaunch(updateUrl)) {
                    await launch(updateUrl);
                  } else {
                    // Menangani kasus di mana URL tidak dapat diluncurkan
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tidak dapat membuka URL $updateUrl'))
                    );
                  }

                },
                child: Text('Perbarui'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sudah Versi Terbaru'),
            content: Text('Aplikasi Anda sudah versi terbaru ($currentVersion).'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Kesalahan'),
          content: Text('Gagal memeriksa pembaruan: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tentang')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Versi Aplikasi 1.0.0'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _checkForUpdates(context),
              child: const Text(
                  'Periksa Pembaruan',
                style: TextStyle(color: Colors.blue),
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
      appBar: AppBar(title: Text('Privacy & Policy')),
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
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Kami sangat menghargai privasi Anda. Kebijakan ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat Anda menggunakan aplikasi kami.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '1. Informasi yang Kami Kumpulkan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Kami mungkin mengumpulkan informasi pribadi seperti nama, alamat email, dan informasi lainnya yang Anda berikan kepada kami saat mendaftar atau menggunakan aplikasi.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '2. Penggunaan Informasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Informasi yang kami kumpulkan digunakan untuk: \n'
                  '- Meningkatkan pengalaman pengguna. \n'
                  '- Mengirimkan informasi dan pembaruan tentang aplikasi. \n'
                  '- Menanggapi pertanyaan dan permintaan Anda.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '3. Keamanan Informasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Kami mengambil langkah-langkah yang sesuai untuk melindungi informasi pribadi Anda dari akses yang tidak sah, pengungkapan, perubahan, atau perusakan.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '4. Perubahan Kebijakan Privasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan tersebut dengan memposting kebijakan privasi yang baru di halaman ini.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '5. Kontak',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, silakan hubungi kami di alwanpriyanto@gmail.com.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
