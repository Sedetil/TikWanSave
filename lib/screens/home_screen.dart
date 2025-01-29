import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'download_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool isLoading = false;

  void _fetchLinks() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan URL TikTok yang valid!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final links = await ApiService().fetchDownloadLinks(url);
    setState(() {
      isLoading = false;
    });

    if (links != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DownloadScreen(links: links)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mendapatkan tautan unduhan.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TikTok Downloader")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Masukkan URL TikTok",
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0), // Border saat fokus
                ),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blue)) // Ubah warna progress menjadi biru
                : ElevatedButton(
              onPressed: _fetchLinks,
              child: const Text(
                "Proses",
                style: TextStyle(color: Colors.blue), // Ubah warna tulisan tombol menjadi putih
              ),
            ),
          ],
        ),
      ),
    );
  }
}
