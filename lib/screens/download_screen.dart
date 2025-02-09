import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadScreen extends StatefulWidget {
  final Map<String, String> links;

  const DownloadScreen({Key? key, required this.links}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _checkAndRequestPermissions();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/icon_notification');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      var storageStatus = await Permission.storage.status;
      var notificationStatus = await Permission.notification.status;

      if (!storageStatus.isGranted) {
        await Permission.storage.request();
      }

      if (await Permission.manageExternalStorage.isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        print("Izin manageExternalStorage diberikan");
      }

      if (!notificationStatus.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Izin Diperlukan"),
          content: const Text(
              "Izin penyimpanan dan notifikasi diperlukan untuk mengunduh file. Anda dapat memberikan izin melalui pengaturan aplikasi."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text("Pengaturan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptAndDownload(BuildContext context, String url, String defaultFilename) async {
    final String? customFilename = await _showFilenameInputDialog(context, defaultFilename);

    if (customFilename != null && customFilename.isNotEmpty) {
      String fullFilename = "$customFilename.${defaultFilename.split('.').last}";
      _download(context, url, fullFilename);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama file tidak boleh kosong.")),
      );
    }
  }

  Future<String?> _showFilenameInputDialog(BuildContext context, String defaultFilename) async {
    String baseFilename = defaultFilename.substring(0, defaultFilename.lastIndexOf('.'));
    TextEditingController controller = TextEditingController(text: baseFilename);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Masukkan Nama File"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nama file"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _download(BuildContext context, String url, String filename) async {
    try {
      final Directory saveDir = Directory("/storage/emulated/0/Download/TikWanSave");
      if (!saveDir.existsSync()) {
        saveDir.createSync(recursive: true);
      }

      String savePath = "${saveDir.path}/$filename";
      savePath = _getUniqueFilePath(savePath);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      Dio dio = Dio();
      int lastProgress = 0;

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            int progress = ((received / total) * 100).toInt();
            if (progress != lastProgress) {
              lastProgress = progress;
              if (progress < 100) {
                await _showDownloadProgressNotification(progress, filename);
              } else {
                await _flutterLocalNotificationsPlugin.cancel(0);
              }
            }
          }
        },
      );

      Navigator.pop(context);
      await _saveDownloadHistory(savePath); // Simpan riwayat unduhan
      await _showDownloadCompletedNotification(filename);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$filename berhasil diunduh di $savePath")),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengunduh file: $e")),
      );
    }
  }

  // Fungsi untuk menyimpan riwayat unduhan ke SharedPreferences
  Future<void> _saveDownloadHistory(String filePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('download_history') ?? [];
    if (!history.contains(filePath)) {
      history.add(filePath);
      await prefs.setStringList('download_history', history);
    }
  }

  Future<void> _showDownloadProgressNotification(int progress, String filename) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'download_channel',
      'Download Notifications',
      channelDescription: 'Notifikasi untuk proses unduhan',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      onlyAlertOnce: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Mengunduh: $filename',
      'Progress: $progress%',
      platformChannelSpecifics,
    );
  }

  Future<void> _showDownloadCompletedNotification(String filename) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'download_channel',
      'Download Notifications',
      channelDescription: 'Notifikasi untuk unduhan selesai',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      1,
      'TikWanSave',
      '$filename berhasil diunduh',
      platformChannelSpecifics,
    );
  }

  String _getUniqueFilePath(String filePath) {
    File file = File(filePath);
    if (!file.existsSync()) {
      return filePath;
    }

    String dir = file.parent.path;
    String fileName = file.uri.pathSegments.last;
    String baseName = fileName.substring(0, fileName.lastIndexOf('.'));
    String extension = fileName.substring(fileName.lastIndexOf('.'));

    int counter = 1;
    while (file.existsSync()) {
      filePath = "$dir/${baseName}($counter)$extension";
      file = File(filePath);
      counter++;
    }

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Format Unduhan"),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.video_file, color: Colors.blueAccent),
                title: const Text("Download Video MP4"),
                onTap: () => _promptAndDownload(context, widget.links['video']!, "TikWanSave.mp4"),
              ),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.music_note, color: Colors.blueAccent),
                title: const Text("Download Audio MP3"),
                onTap: () => _promptAndDownload(context, widget.links['audio']!, "TikWanSave.mp3"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
