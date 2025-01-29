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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File tidak ditemukan!")),
      );
      return;
    }

    String extension = filePath.split('.').last.toLowerCase();

    if (['mp4', 'mkv', 'avi'].contains(extension)) {
      _playVideo(file);
    } else if (['mp3', 'wav', 'aac', 'ogg'].contains(extension)) {
      _playAudio(file);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Format file tidak didukung!")),
      );
    }
  }

  void _playVideo(File file) {
    _stopAudio();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("File berhasil dihapus!")),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Unduhan")),
      body: downloadedFiles.isEmpty
          ? Center(
        child: Text(
          'Belum ada media yang diunduh',
          style: TextStyle(fontSize: 18),
        ),
      )
          : Column(
        children: [
          if (_chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized)
            AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            ),
          if (isAudioPlaying)
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sedang Memutar Audio"),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: _stopAudio,
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: downloadedFiles.length,
              itemBuilder: (context, index) {
                String filePath = downloadedFiles[index];
                String fileName = filePath.split('/').last;
                return ListTile(
                  title: Text(fileName),
                  subtitle: Text(filePath),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () => _playMedia(filePath),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteFile(filePath),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
