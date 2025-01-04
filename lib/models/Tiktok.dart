class Tiktok {
  final String author;
  final String videoUrl;
  final String audioUrl;
  final String thumbnail;
  final String title;

  Tiktok({
    required this.author,
    required this.videoUrl,
    required this.audioUrl,
    required this.thumbnail,
    required this.title,
  });

  factory Tiktok.fromJson(Map<String, dynamic> json) {
    return Tiktok(
      author: json['auhtor'] ?? 'Tidak diketahui',
      videoUrl: json['data']['play'] ?? '',
      audioUrl: json['data']['music'] ?? '',
      thumbnail: json['data']['cover'] ?? '',
      title: json['data']['title'] ?? 'Video TikTok',
    );
  }
}
