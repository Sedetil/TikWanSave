import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> downloadedFiles = [];
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isAudioPlaying = false;
  bool isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      downloadedFiles = prefs.getStringList('download_history') ?? [];
    });
  }

  void _playMedia(String filePath) {
    File file = File(filePath);
    if (!file.existsSync()) {
      setState(() {
        downloadedFiles.remove(filePath);
      });
      _updateHistory();
      _showSnackbar("File tidak ditemukan!", Colors.redAccent);
      return;
    }

    String extension = filePath.split('.').last.toLowerCase();

    if (['mp4', 'mkv', 'avi'].contains(extension)) {
      _playVideo(file);
    } else if (['mp3', 'wav', 'aac', 'ogg'].contains(extension)) {
      _playAudio(file);
    } else {
      _showSnackbar("Format file tidak didukung!", Colors.orangeAccent);
    }
  }

  void _playVideo(File file) {
    _stopAudio();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          isVideoPlaying = true;
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
            allowFullScreen: true,
          );
        });
      });
  }

  void _playAudio(File file) async {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _stopAudio();
    await _audioPlayer.play(DeviceFileSource(file.path));
    setState(() {
      isAudioPlaying = true;
    });
  }

  void _stopAudio() {
    _audioPlayer.stop();
    setState(() {
      isAudioPlaying = false;
    });
  }

  Future<void> _updateHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('download_history', downloadedFiles);
  }

  Future<void> _deleteFile(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    setState(() {
      downloadedFiles.remove(filePath);
    });
    await _updateHistory();

    _showSnackbar("File berhasil dihapus!", Colors.greenAccent);
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isVideoPlaying) {
          setState(() {
            isVideoPlaying = false;
            _videoPlayerController?.dispose();
            _chewieController?.dispose();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat Unduhan"),
        ),
        body: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isVideoPlaying ? 250 : 0,
              child: isVideoPlaying && _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
                  : SizedBox.shrink(),
            ),
            if (isAudioPlaying)
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sedang Memutar Audio", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.stop, color: Colors.red),
                      onPressed: _stopAudio,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: downloadedFiles.isEmpty
                  ? Center(
                child: Text(
                  'Belum ada media yang diunduh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              )
                  : ListView.builder(
                itemCount: downloadedFiles.length,
                itemBuilder: (context, index) {
                  String filePath = downloadedFiles[index];
                  String fileName = filePath.split('/').last;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(Icons.file_present, color: Colors.deepPurple),
                      title: Text(fileName, style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(filePath, style: TextStyle(color: Colors.grey.shade600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.play_arrow, color: Colors.green),
                            onPressed: () => _playMedia(filePath),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteFile(filePath),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}